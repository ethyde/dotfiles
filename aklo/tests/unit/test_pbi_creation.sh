#!/usr/bin/env bash
source "${AKLO_PROJECT_ROOT}/aklo/tests/framework/test_framework.sh"

test_get_next_id() {
    test_suite "Unit Test: get_next_id logic (extension-agnostic)"
    
    local test_dir
    test_dir=$(mktemp -d)
    mkdir -p "$test_dir/pbi"
    touch "$test_dir/pbi/PBI-1-test.xml"
    touch "$test_dir/pbi/PBI-5-test.xml"
    
    local last_id
    last_id=$(ls "$test_dir/pbi/PBI-"*-* 2>/dev/null | sed -n "s/.*PBI-\([0-9]*\)-.*/\1/p" | sort -n | tail -1)
    assert_equals "5" "$last_id" "Doit trouver le plus grand ID existant (5)"
    
    rm -rf "$test_dir"
}

test_aklo_new_pbi_command() {
    test_suite "Command: aklo new pbi (Full Integration)"
    
    setup_artefact_test_env
    trap teardown_artefact_test_env EXIT

    "${TEST_PROJECT_DIR}/aklo/bin/aklo" new pbi "My Test PBI" >/dev/null 2>&1
    local exit_code=$?
    assert_equals "0" "$exit_code" "'aklo new pbi' doit s'exécuter sans erreur"
    
    local pbi_file
    pbi_file=$(find "${TEST_PROJECT_DIR}/docs/backlog/00-pbi" -name "PBI-1-my-test-pbi-*.xml" 2>/dev/null)
    assert_not_empty "$pbi_file" "Le fichier PBI doit être créé dans le répertoire de test"

    # --- DEBUG : copie le fichier généré pour inspection après le test ---
    if [ -n "$pbi_file" ]; then
        cp "$pbi_file" /tmp/aklo_pbi_debug.xml
        echo "[DEBUG] Copie du PBI généré dans /tmp/aklo_pbi_debug.xml" >&2
    fi

    assert_file_contains "$pbi_file" 'title="My Test PBI"' "Le PBI .xml doit contenir l'attribut title"
    assert_file_contains "$pbi_file" '<status>PROPOSED</status>' "Le PBI .xml doit avoir le statut PROPOSED"
}

main() {
    test_get_next_id
    test_aklo_new_pbi_command
    
    test_summary
}

main
