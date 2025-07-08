#!/bin/bash
source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"

AKLO_EXEC=""

setup() {
    setup_artefact_test_env
    AKLO_EXEC="${TEST_PROJECT_DIR}/aklo/bin/aklo"
    
    # Charger les modules nécessaires depuis la VRAIE installation, pas le temp dir
    source "${AKLO_PROJECT_ROOT}/aklo/modules/cache/cache_monitoring.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/cache/cache_functions.sh"
    export CACHE_DIR="$TEST_PROJECT_DIR/.aklo_cache"
    mkdir -p "$CACHE_DIR"
}

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

    # Test `aklo cache benchmark`
    $AKLO_EXEC cache benchmark >/dev/null 2>&1
    local exit_code=$?
    assert_equals "0" "$exit_code" "La commande 'aklo cache benchmark' s'exécute sans erreur"
}

test_cache_metrics() {
    test_suite "Cache Metrics"

    record_cache_metric "hit" 50
    assert_file_exists "$CACHE_DIR/cache_metrics.json" "Le fichier de métriques est créé après enregistrement manuel"
    assert_file_contains "$CACHE_DIR/cache_metrics.json" '"hits"' "Les métriques manuelles sont enregistrées correctement"
}

test_metrics_integration_with_parser() {
    test_suite "Cache Metrics Integration with Parser"
    
    $AKLO_EXEC propose-pbi "Test Metrics Integration" >/dev/null 2>&1
    assert_file_exists "$CACHE_DIR/cache_metrics.json" "Les métriques sont automatiquement enregistrées lors de la génération d'un PBI"
    
    # Vérifier que l'artefact a été créé au bon endroit (dans le temp dir)
    local pbi_file
    pbi_file=$(find ./pbi -name "PBI-*-Test-Metrics-Integration.xml" -type f)
    assert_not_empty "$pbi_file" "Le PBI est créé dans le répertoire temporaire 'pbi'"
}

main() {
    setup
    trap teardown EXIT

    test_cache_commands
    test_cache_metrics
    test_metrics_integration_with_parser
    
    test_summary
}

main
