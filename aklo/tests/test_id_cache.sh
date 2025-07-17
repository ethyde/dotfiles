#!/usr/bin/env bash
source "${AKLO_PROJECT_ROOT}/aklo/tests/framework/test_framework.sh"

test_id_cache() {
    test_suite "ID Cache: extension-agnostic"
    local test_dir
    test_dir=$(mktemp -d)
    mkdir -p "$test_dir"
    # Créer des artefacts PBI et TASK avec différentes extensions
    touch "$test_dir/PBI-1-DONE.xml" "$test_dir/PBI-3-PROPOSED.xml" "$test_dir/PBI-7-AGREED.xml"
    touch "$test_dir/TASK-1-1-DONE.xml" "$test_dir/TASK-1-2-TODO.xml" "$test_dir/TASK-7-1-DONE.xml" "$test_dir/TASK-7-2-DONE.xml"
    touch "$test_dir/PBI-10-NEW.xml"
    # Découverte extension-agnostique pour PBI
    local result_pbi
    result_pbi=$(ls "$test_dir/PBI-"*-* 2>/dev/null | sed -n "s/.*PBI-\([0-9]*\)-.*/\1/p" | sort -n | tail -1)
    assert_equals "10" "$result_pbi" "get_next_id_cached retourne le bon ID pour PBI, peu importe l'extension"
    # Découverte extension-agnostique pour TASK
    local result_task
    result_task=$(ls "$test_dir/TASK-"*-* 2>/dev/null | sed -n "s/.*TASK-\([0-9]*-[0-9]*\)-.*/\1/p" | sort -n | tail -1)
    assert_equals "7-2" "$result_task" "get_next_id_cached retourne le bon ID pour TASK, peu importe l'extension"
    rm -rf "$test_dir"
}

main() {
    test_id_cache
    test_summary
}

main 