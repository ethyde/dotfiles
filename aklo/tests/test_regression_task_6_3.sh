#!/bin/bash

# Test de régression pour TASK-6-3
# Vérifie que toutes les commandes aklo fonctionnent avec le cache.
# Entièrement refactorisé pour utiliser le framework de test et l'isolation.

source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"

AKLO_EXEC=""
ORIGINAL_CONFIG=""

setup() {
    setup_artefact_test_env
    AKLO_EXEC="${TEST_PROJECT_DIR}/aklo/bin/aklo"
    
    # Sauvegarder la config si elle existe, sinon la créer
    if [ -f "aklo/.aklo.conf" ]; then
        ORIGINAL_CONFIG=$(cat "aklo/.aklo.conf")
    fi
    # Activer le cache debug pour les logs
    echo "CACHE_DEBUG=true" >> .aklo.conf
}

teardown() {
    teardown_artefact_test_env
}

test_command_with_cache() {
    local cmd_name="$1"
    local aklo_args="$2"
    local artefact_type_for_cache="$3"
    
    test_suite "Régression Cache - Commande: $cmd_name"

    # Exécution de la commande
    local output
    output=$($AKLO_EXEC "$cmd_name" $aklo_args 2>&1)
    local exit_code=$?
    
    assert_equals "0" "$exit_code" "La commande '$cmd_name' doit s'exécuter sans erreur"
    
    # Vérifier le cache
    local cache_file
    cache_file=$(find . -type f -name "*_${artefact_type_for_cache}.parsed" 2>/dev/null)
    assert_not_empty "$cache_file" "Le cache pour le type '$artefact_type_for_cache' doit être créé"
}

test_cache_disabled() {
    test_suite "Régression Cache - Cache Désactivé"
    
    # Désactiver le cache
    echo "CACHE_ENABLED=false" >> .aklo.conf
    
    $AKLO_EXEC propose-pbi "Test Cache Disabled" >/dev/null 2>&1
    local exit_code=$?
    assert_equals "0" "$exit_code" "La commande doit fonctionner avec le cache désactivé"

    # Vérifier qu'aucun cache n'est créé
    local cache_dir_path="$TEST_PROJECT_DIR/.aklo_cache"
    assert_true "[ ! -d '$cache_dir_path' ] || [ -z '$(ls -A '$cache_dir_path')' ]" "Aucun fichier cache ne doit être créé lorsque le cache est désactivé"
}


main() {
    # Exécuter les tests dans un sous-shell pour garantir le cleanup
    # même en cas d'erreur avec `set -e` implicite du framework.
    (
        setup
        trap teardown EXIT

        test_command_with_cache "status" "--brief" "N/A" # Status ne crée pas de cache
        test_command_with_cache "propose-pbi" "'Test Regression PBI'" "PBI"
        test_command_with_cache "plan" "1 --no-agent" "TASK"
        test_command_with_cache "debug" "'Test regression debug' --no-agent" "DEBUG"
        test_command_with_cache "arch" "1 --no-agent" "ARCH"
        test_cache_disabled
    )
    
    test_summary
}

main