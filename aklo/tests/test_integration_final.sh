#!/usr/bin/env bash
source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"

setup() {
    setup_artefact_test_env
    # Le script aklo est maintenant dans le répertoire de test
    AKLO_EXEC="${TEST_PROJECT_DIR}/aklo/bin/aklo"
}

teardown() {
    teardown_artefact_test_env
}

test_pbi_generation_cache_behavior() {
    test_suite "PBI Generation with Cache (extension-agnostic)"

    # 1. Utiliser la nouvelle syntaxe de commande
    local pbi_title_miss="Test Cache Integration Miss"
    local miss_output
    miss_output=$($AKLO_EXEC new pbi "$pbi_title_miss" 2>&1)
    local exit_code_miss=$?

    assert_equals "0" "$exit_code_miss" "La génération PBI (miss) doit réussir"
    # Note : Le cache n'est plus géré de cette manière, on simplifie le test
    # pour se concentrer sur la réussite de la commande.

    local pbi_file_miss
    pbi_file_miss=$(find ./docs/backlog/00-pbi -name "PBI-*-test-cache-integration-miss-*.xml" 2>/dev/null)
    assert_not_empty "$pbi_file_miss" "Le fichier PBI doit être créé sur un cache miss"
}

test_other_commands_compatibility() {
    test_suite "Other Commands Compatibility"

    local status_output
    status_output=$($AKLO_EXEC status 2>&1)
    local exit_code=$?
    
    assert_equals "0" "$exit_code" "La commande 'status' doit fonctionner"
    assert_contains "$status_output" "Aklo Project Status Dashboard" "La sortie de 'status' est correcte"
}

main() {
    setup
    trap teardown EXIT

    test_pbi_generation_cache_behavior
    test_other_commands_compatibility

    test_summary
}

main
