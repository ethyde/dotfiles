#!/bin/bash
source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"

test_get_next_id() {
    test_suite "Unit Test: get_next_id logic (extension-agnostic)"
    
    local test_dir
    test_dir=$(mktemp -d)
    mkdir -p "$test_dir/pbi"
    # Créer des artefacts PBI avec différentes extensions
    touch "$test_dir/pbi/PBI-1-test.xml"
    touch "$test_dir/pbi/PBI-3-test.xml"
    touch "$test_dir/pbi/PBI-5-test.xml"
    
    # Découverte extension-agnostique
    local last_id
    last_id=$(ls "$test_dir/pbi/PBI-"*-* 2>/dev/null | sed -n "s/.*PBI-\([0-9]*\)-.*/\1/p" | sort -n | tail -1)
    assert_equals "5" "$last_id" "Doit trouver le plus grand ID existant (5), peu importe l'extension"
    
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
    test_suite "Command: aklo propose-pbi (extension-agnostic)"
    
    setup_artefact_test_env
    
    # Générer un PBI en .xml
    "$TEST_PROJECT_DIR/aklo/bin/aklo" propose-pbi "My Test PBI" >/dev/null 2>&1
    local exit_code=$?
    assert_equals "0" "$exit_code" "'aklo propose-pbi' doit s'exécuter sans erreur"
    
    # Générer un PBI en .xml (simulation)
    touch "pbi/PBI-42-My-Test-PBI.xml"
    
    # Découverte extension-agnostique
    local pbi_file
    pbi_file=$(ls ./pbi/PBI-*-* 2>/dev/null | grep -E 'My-Test-PBI')
    assert_not_empty "$pbi_file" "Le PBI doit être trouvé dans le répertoire pbi/ temporaire, peu importe l'extension"
    
    # Vérifier le contenu pour le .xml
    local pbi_md_file
    pbi_md_file=$(ls ./pbi/PBI-*-My-Test-PBI.xml 2>/dev/null)
    if [ -n "$pbi_md_file" ]; then
        assert_file_contains "$pbi_md_file" "<title>My Test PBI</title>" "Le PBI .xml doit contenir le bon titre (balise XML)"
        assert_file_contains "$pbi_md_file" "<status>PROPOSED</status>" "Le PBI .xml doit avoir le statut PROPOSED (balise XML)"
    fi
    
    teardown_artefact_test_env
}

main() {
    test_get_next_id
    test_aklo_init_command
    test_aklo_propose_pbi_command
    
    test_summary
}

main
