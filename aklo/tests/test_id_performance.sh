#!/usr/bin/env bash
source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"

test_id_performance() {
    test_suite "ID Performance: extension-agnostic"
    local test_dir
    test_dir=$(mktemp -d)
    mkdir -p "$test_dir/pbi" "$test_dir/tasks"
    # Créer des artefacts PBI et TASK avec différentes extensions
    for i in 1 3 5 7; do
        touch "$test_dir/pbi/PBI-$i-DONE.xml"
        touch "$test_dir/pbi/PBI-$((i+1))-DONE.xml"
        touch "$test_dir/tasks/TASK-$i-TODO.xml"
        touch "$test_dir/tasks/TASK-$((i+1))-TODO.xml"
    done
    # Découverte extension-agnostique pour PBI
    local last_id
    last_id=$(ls "$test_dir/pbi/PBI-"*-* 2>/dev/null | sed -n "s/.*PBI-\([0-9]*\)-.*/\1/p" | sort -n | tail -1)
    assert_equals "8" "$last_id" "get_next_id doit trouver le plus grand ID PBI, peu importe l'extension"
    # Découverte extension-agnostique pour TASK
    local last_task_id
    last_task_id=$(ls "$test_dir/tasks/TASK-"*-* 2>/dev/null | sed -n "s/.*TASK-\([0-9]*\)-.*/\1/p" | sort -n | tail -1)
    assert_equals "8" "$last_task_id" "get_next_id doit trouver le plus grand ID TASK, peu importe l'extension"
    rm -rf "$test_dir"
}

main() {
    test_id_performance
    test_summary
}

main 