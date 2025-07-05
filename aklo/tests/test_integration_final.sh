#!/bin/bash
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
    test_suite "PBI Generation with Cache"

    # 1. Exécution avec cache MISS
    local pbi_title_miss="Test Cache Integration Miss"
    local miss_output
    miss_output=$($AKLO_EXEC propose-pbi "$pbi_title_miss" 2>&1)
    local exit_code_miss=$?

    assert_equals "0" "$exit_code_miss" "La génération PBI (miss) doit réussir"
    assert_contains "$miss_output" "MISS" "Le log doit indiquer un cache MISS"

    local pbi_file_miss
    pbi_file_miss=$(find ./pbi -type f -name "PBI-*-Test-Cache-Integration-Miss.md")
    assert_not_empty "$pbi_file_miss" "Le fichier PBI doit être créé sur un cache miss"

    # Vérifier que le cache a bien été créé
    local cache_file
    cache_file=$(find . -path "./.aklo_cache/protocol_*.parsed" -type f 2>/dev/null)
    assert_not_empty "$cache_file" "Un fichier cache doit être créé après un miss"

    # 2. Exécution avec cache HIT
    local pbi_title_hit="Test Cache Integration Miss" # Utilise le même titre pour un HIT
    local hit_output
    hit_output=$($AKLO_EXEC propose-pbi "$pbi_title_hit" 2>&1)
    local exit_code_hit=$?

    assert_equals "0" "$exit_code_hit" "La génération PBI (hit) doit réussir"
    assert_contains "$hit_output" "HIT" "Le log doit indiquer un cache HIT"
}

test_other_commands_compatibility() {
    test_suite "Other Commands Compatibility"

    # Vérifier qu'une commande qui n'utilise pas le parser fonctionne
    local status_output
    status_output=$($AKLO_EXEC status --brief 2>&1)
    local exit_code=$?
    
    assert_equals "0" "$exit_code" "La commande 'status' doit fonctionner"
    assert_contains "$status_output" "Aklo project status" "La sortie de 'status' est correcte"
}

main() {
    setup
    trap teardown EXIT

    test_pbi_generation_cache_behavior
    test_other_commands_compatibility

    test_summary
}

main
