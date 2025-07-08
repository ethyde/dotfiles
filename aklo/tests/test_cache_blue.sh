#!/bin/bash
source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"

AKLO_EXEC=""

setup() {
    setup_artefact_test_env
    AKLO_EXEC="${TEST_PROJECT_DIR}/aklo/bin/aklo"
}

teardown() {
    teardown_artefact_test_env
}

test_cache_performance_behavior() {
    test_suite "Cache Performance Behavior"

    $AKLO_EXEC cache clear >/dev/null 2>&1
    
    # Exécuter une première fois pour générer le cache
    $AKLO_EXEC propose-pbi "Test Perf Cache Gen" >/dev/null 2>&1
    
    # Mesurer le temps d'un "cache miss" (en générant un nouveau PBI)
    local start_miss=$(date +%s%N)
    $AKLO_EXEC propose-pbi "Test Perf Miss" >/dev/null 2>&1
    local end_miss=$(date +%s%N)
    local miss_time=$((end_miss - start_miss))

    # Mesurer le temps d'un "cache hit" (en utilisant un titre identique, déclenchant le cache)
    local start_hit=$(date +%s%N)
    $AKLO_EXEC propose-pbi "Test Perf Cache Gen" >/dev/null 2>&1
    local end_hit=$(date +%s%N)
    local hit_time=$((end_hit - start_hit))

    assert_true "[ $hit_time -lt $miss_time ]" "Le cache hit doit être plus rapide que le cache miss (hit: ${hit_time}ns, miss: ${miss_time}ns)"
}

test_cache_metrics_verification() {
    test_suite "Cache Metrics Verification"
    
    $AKLO_EXEC cache clear >/dev/null 2>&1
    $AKLO_EXEC propose-pbi "Test Metrics 1" >/dev/null 2>&1 # Miss
    $AKLO_EXEC propose-pbi "Test Metrics 1" >/dev/null 2>&1 # Hit
    $AKLO_EXEC propose-pbi "Test Metrics 2" >/dev/null 2>&1 # Miss
    
    local status_output
    status_output=$($AKLO_EXEC cache status 2>&1)
    
    assert_contains "$status_output" "Total requêtes: 3" "Les métriques de requêtes doivent être collectées (3)"
    assert_contains "$status_output" "Hits: 1" "Le nombre de hits doit être correct (1)"
    assert_contains "$status_output" "Miss: 2" "Le nombre de miss doit être correct (2)"
    assert_contains "$status_output" "(33%)" "Le ratio hit/miss doit être calculé"
}

test_cache_benchmark_command() {
    test_suite "Cache Benchmark Command"

    local benchmark_output
    benchmark_output=$($AKLO_EXEC cache benchmark 2>&1)
    
    assert_contains "$benchmark_output" "Cache miss:" "Le benchmark doit mesurer le cache miss"
    assert_contains "$benchmark_output" "Cache hit:" "Le benchmark doit mesurer le cache hit"
    assert_contains "$benchmark_output" "Gain:" "Le benchmark doit calculer le gain"
}


main() {
    setup
    trap teardown EXIT

    test_cache_performance_behavior
    test_cache_metrics_verification
    test_cache_benchmark_command
    
    test_summary
}

main
