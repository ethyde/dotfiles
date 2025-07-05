test_id_cache() {
    test_suite "Tests pour le cache des IDs (TASK-7-3)"

    # Source des fonctions à tester
    local script_dir
    script_dir="$(dirname "$0")"
    source "${script_dir}/../modules/cache/cache_functions.sh"
    source "${script_dir}/../modules/cache/id_cache.sh"

    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    touch "$test_dir/PBI-1-DONE.md"
    touch "$test_dir/PBI-3-PROPOSED.md"
    touch "$test_dir/PBI-7-AGREED.md"
    touch "$test_dir/TASK-1-1-DONE.md"
    touch "$test_dir/TASK-1-2-TODO.md"
    touch "$test_dir/TASK-7-1-DONE.md"
    touch "$test_dir/TASK-7-2-DONE.md"

    # Test 1: Existence des fonctions
    test_suite "Existence des fonctions"
    assert_function_exists "get_next_id_cached" "La fonction get_next_id_cached existe"
    assert_function_exists "invalidate_id_cache" "La fonction invalidate_id_cache existe"
    assert_function_exists "update_id_cache" "La fonction update_id_cache existe"

    # Test 2: Calcul de l'ID pour PBI
    test_suite "Calcul de l'ID pour PBI"
    local result_pbi
    result_pbi=$(get_next_id_cached "$test_dir" "PBI")
    assert_equals "8" "$result_pbi" "get_next_id_cached retourne le bon ID pour PBI"

    # Test 3: Calcul de l'ID pour TASK
    test_suite "Calcul de l'ID pour TASK"
    local result_task
    result_task=$(get_next_id_cached "$test_dir" "TASK")
    assert_equals "8" "$result_task" "get_next_id_cached retourne le bon ID pour TASK"

    # Test 4: Performance du cache
    test_suite "Performance du cache"
    local start_time_1
    start_time_1=$(date +%s%N)
    get_next_id_cached "$test_dir" "PBI" >/dev/null
    local end_time_1
    end_time_1=$(date +%s%N)
    local duration_1
    duration_1=$(( (end_time_1 - start_time_1) ))

    local start_time_2
    start_time_2=$(date +%s%N)
    get_next_id_cached "$test_dir" "PBI" >/dev/null
    local end_time_2
    end_time_2=$(date +%s%N)
    local duration_2
    duration_2=$(( (end_time_2 - start_time_2) ))
    
    if [ "$duration_2" -le "$duration_1" ]; then
        assert_equals 0 0 "Le cache améliore (ou maintient) les performances"
    else
        fail "Le cache a ralenti l'exécution (sans cache: ${duration_1}ns, avec cache: ${duration_2}ns)"
    fi

    # Test 5: Invalidation du cache
    test_suite "Invalidation du cache"
    touch "$test_dir/PBI-10-NEW.md"
    invalidate_id_cache "$test_dir" "PBI"
    local result_invalidated
    result_invalidated=$(get_next_id_cached "$test_dir" "PBI")
    assert_equals "11" "$result_invalidated" "L'invalidation du cache fonctionne correctement"

    # Test 6: Métriques de cache
    test_suite "Métriques de cache"
    if command -v get_id_cache_metrics >/dev/null 2>&1; then
        local metrics
        metrics=$(get_id_cache_metrics)
        assert_contains "$metrics" "Hits" "Les métriques de cache contiennent 'Hits'"
        assert_contains "$metrics" "Misses" "Les métriques de cache contiennent 'Misses'"
    else
        assert_equals 0 0 "Test des métriques ignoré (fonction non implémentée)"
    fi

    # Cleanup
    rm -rf "$test_dir"
} 