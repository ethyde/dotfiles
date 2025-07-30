#!/usr/bin/env bash
source "$(dirname "$0")/../framework/test_framework.sh"

AKLO_EXEC=""

# La fonction setup est appelée une fois pour toute la suite de tests
setup() {
    setup_artefact_test_env
    AKLO_EXEC="${TEST_PROJECT_DIR}/aklo/bin/aklo"
    
    # Charger les modules nécessaires depuis l'installation principale
    source "${TEST_PROJECT_DIR}/aklo/modules/cache/cache_monitoring.sh"
    source "${TEST_PROJECT_DIR}/aklo/modules/cache/cache_functions.sh"
    export CACHE_DIR="$TEST_PROJECT_DIR/.aklo_cache"
    mkdir -p "$CACHE_DIR"
}

# La fonction teardown sera appelée à la fin du script, quoi qu'il arrive
teardown() {
    teardown_artefact_test_env
    unset CACHE_DIR
}

test_cache_commands() {
    test_suite "Cache Commands"
    
    # Test `aklo cache status`
    local status_output
    status_output=$($AKLO_EXEC cache status 2>&1)
    assert_contains "$status_output" "STATUT DU CACHE AKLO" "La commande 'aklo cache status' fonctionne"

    # Test `aklo cache clear`
    echo "test" > "$CACHE_DIR/test.parsed"
    $AKLO_EXEC cache clear >/dev/null 2>&1
    assert_file_not_exists "$CACHE_DIR/test.parsed" "La commande 'aklo cache clear' vide bien le cache"

    # Test `aklo cache benchmark` (s'assure juste qu'elle ne crashe pas)
    $AKLO_EXEC cache benchmark >/dev/null 2>&1
    local exit_code=$?
    assert_equals "0" "$exit_code" "La commande 'aklo cache benchmark' s'exécute sans erreur"
}

# --- Exécution ---

setup
trap teardown EXIT # Le nettoyage se fera à la fin de l'exécution du script

test_cache_commands
# Ajoutez ici d'autres fonctions de test si nécessaire

test_summary
