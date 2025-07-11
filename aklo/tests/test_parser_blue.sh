#!/usr/bin/env bash

# Source des dépendances
# Pour accéder aux fonctions internes si nécessaire

# Variables globales
TEST_PROJECT_DIR=""
ORIGINAL_PWD=""

setup() {
    TEST_PROJECT_DIR=$(mktemp -d "/tmp/aklo_parser_blue_test.XXXXXX")
    ORIGINAL_PWD=$(pwd)
    
    # Isoler le test dans un nouveau projet
    cd "$TEST_PROJECT_DIR"
    
    # Copier l'application
    mkdir -p aklo/bin
    cp "$ORIGINAL_PWD/aklo/bin/aklo" aklo/bin/
    cp -r "$ORIGINAL_PWD/aklo/modules" aklo/
    cp -r "$ORIGINAL_PWD/aklo/charte" aklo/
    
    # Créer les répertoires pour les artefacts de test
    mkdir -p pbi tasks arch debug journal
    
    # Créer une configuration .aklo.conf locale et temporaire
    cat > .aklo.conf << EOF
PBI_DIR=pbi
TASKS_DIR=tasks
ARCH_DIR=arch
DEBUG_DIR=debug
JOURNAL_DIR=journal
CACHE_ENABLED=true
CACHE_DEBUG=true
EOF
    
    # Créer le répertoire de cache
    mkdir -p .aklo_cache
    export AKLO_CACHE_DIR="$TEST_PROJECT_DIR/.aklo_cache"
}

teardown() {
    cd "$ORIGINAL_PWD"
    rm -rf "$TEST_PROJECT_DIR"
    unset AKLO_CACHE_DIR
}

# NOTE: Les tests de performance réels sont peu fiables dans un environnement CI.
# Ces tests vérifient principalement le comportement (hit/miss) plutôt que des ms précises.
test_parser_performance_behavior() {
    # 1. Exécution sans cache pour établir une baseline comportementale
    echo "CACHE_ENABLED=false" > .aklo.conf
    local no_cache_log
    no_cache_log=$(./aklo/bin/aklo propose-pbi "Test Perf No Cache" 2>&1)
    assert_contains "Le log (sans cache) doit indiquer que le cache est désactivé" "$no_cache_log" "DISABLED"

    # 2. Exécution avec cache (miss)
    echo "CACHE_ENABLED=true" > .aklo.conf
    local miss_log
    miss_log=$(./aklo/bin/aklo propose-pbi "Test Perf Cache Miss" 2>&1)
    assert_contains "Le log (miss) doit indiquer un cache miss" "$miss_log" "MISS"

    # 3. Exécution avec cache (hit)
    local hit_log
    hit_log=$(./aklo/bin/aklo propose-pbi "Test Perf Cache Hit" 2>&1)
    assert_contains "Le log (hit) doit indiquer un cache hit" "$hit_log" "HIT"
}

test_parser_robustness_invalid_protocol() {
    local result
    result=$(./aklo/bin/aklo propose-pbi "Test Invalid Protocol" --protocol="INEXISTANT" 2>&1)
    local exit_code=$?
    
    assert_exit_code "Doit échouer avec un protocole inexistant" 1 ${exit_code}
    assert_contains "Le message d'erreur pour protocole invalide est incorrect" "$result" "Protocole 'INEXISTANT' non trouvé"
}

test_parser_robustness_corrupted_cache() {
    # Pré-condition: Créer un cache corrompu
    local cache_dir
    cache_dir=$(find . -type d -name "aklo_cache")
    local pbi_protocol_name="00-PRODUCT-OWNER" # Nom basé sur la config par défaut
    local cache_file="$cache_dir/protocol_${pbi_protocol_name}_PBI.parsed"
    
    # On crée le cache via une première exécution
    ./aklo/bin/aklo propose-pbi "Dummy pour créer cache" >/dev/null 2>&1
    
    # On corrompt le fichier cache
    echo "CACHE_CORRUPTED_DATA" > "$cache_file"

    # Exécution: devrait utiliser le fallback
    local result
    result=$(./aklo/bin/aklo propose-pbi "Test Corrupted Cache" 2>&1)
    local exit_code=$?

    assert_exit_code "Doit réussir en utilisant le fallback" 0 ${exit_code}
    assert_contains "Le log doit indiquer un fallback suite au cache corrompu" "$result" "FALLBACK"
} 