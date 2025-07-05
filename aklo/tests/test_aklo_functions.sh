#!/bin/bash
source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"

test_get_next_id() {
    test_suite "Unit Test: get_next_id logic"
    
    local test_dir
    test_dir=$(mktemp -d)
    mkdir -p "$test_dir/pbi"
    touch "$test_dir/pbi/PBI-1-test.md" "$test_dir/pbi/PBI-3-test.md" "$test_dir/pbi/PBI-5-test.md"
    
    local last_id
    last_id=$(ls "$test_dir/pbi/PBI-"*-*.md 2>/dev/null | sed -n "s/.*PBI-\([0-9]*\)-.*/\1/p" | sort -n | tail -1)
    assert_equals "5" "$last_id" "Doit trouver le plus grand ID existant (5)"
    
    local next_id=$((last_id + 1))
    assert_equals "6" "$next_id" "Le prochain ID doit être 6"

    rm -rf "$test_dir"
}

test_aklo_init_command() {
    test_suite "Command: aklo init"
    
    setup_artefact_test_env

    echo "y" | "$TEST_PROJECT_DIR/aklo/bin/aklo" init >/dev/null 2>&1
    local exit_code=$?
    
    assert_equals "0" "$exit_code" "'aklo init' doit s'exécuter sans erreur"
    assert_file_exists "pbi" "'aklo init' should create the 'pbi' directory"
    assert_file_exists ".aklo.conf" "'aklo init' doit créer le fichier .aklo.conf"
    assert_file_contains ".aklo.conf" "PBI_DIR=" ".aklo.conf doit contenir PBI_DIR"

    teardown_artefact_test_env
}

test_aklo_propose_pbi_command() {
    test_suite "Command: aklo propose-pbi"
    
    setup_artefact_test_env
    
    "$TEST_PROJECT_DIR/aklo/bin/aklo" propose-pbi "My Test PBI" >/dev/null 2>&1
    local exit_code=$?
    
    assert_equals "0" "$exit_code" "'aklo propose-pbi' doit s'exécuter sans erreur"
    
    local pbi_file
    pbi_file=$(find ./pbi -name "PBI-*-My-Test-PBI.md" -type f)
    assert_not_empty "$pbi_file" "Le PBI doit être créé dans le répertoire pbi/ temporaire"
    
    assert_file_contains "$pbi_file" "Titre: My Test PBI" "Le PBI doit contenir le bon titre"
    assert_file_contains "$pbi_file" "Statut: PROPOSED" "Le PBI doit avoir le statut PROPOSED"
    
    teardown_artefact_test_env
}

main() {
    test_get_next_id
    test_aklo_init_command
    test_aklo_propose_pbi_command
    
    test_summary
}

main
