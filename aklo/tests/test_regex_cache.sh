#!/bin/bash

#==============================================================================
# TESTS UNITAIRES - CACHE REGEX SYSTEM
# Tests pour le système de cache des patterns regex
# 
# Partie de : PBI-7 TASK-7-1
# Date : 2025-07-03
#==============================================================================

# Chargement du système de cache
source "$(dirname "$0")/../modules/cache/regex_cache.sh"

# Variables de test
TEST_COUNT=0
PASSED_COUNT=0
FAILED_COUNT=0

#------------------------------------------------------------------------------
# Fonctions utilitaires de test
#------------------------------------------------------------------------------

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -n "Test $TEST_COUNT: $test_name ... "
    
    if $test_function; then
        echo "✅ PASS"
        PASSED_COUNT=$((PASSED_COUNT + 1))
    else
        echo "❌ FAIL"
        FAILED_COUNT=$((FAILED_COUNT + 1))
    fi
}

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    
    if [ "$expected" = "$actual" ]; then
        return 0
    else
        echo "    Expected: '$expected', Got: '$actual' ($message)" >&2
        return 1
    fi
}

assert_not_empty() {
    local value="$1"
    local message="$2"
    
    if [ -n "$value" ]; then
        return 0
    else
        echo "    Expected non-empty value ($message)" >&2
        return 1
    fi
}

assert_return_code() {
    local expected_code="$1"
    local actual_code="$2"
    local message="$3"
    
    if [ "$expected_code" -eq "$actual_code" ]; then
        return 0
    else
        echo "    Expected return code $expected_code, got $actual_code ($message)" >&2
        return 1
    fi
}

#------------------------------------------------------------------------------
# Tests d'initialisation
#------------------------------------------------------------------------------

test_cache_initialization() {
    # Reset pour test propre
    clear_regex_cache
    
    # Test initialisation
    init_regex_cache
    
    # Vérifier que le cache est marqué comme initialisé
    assert_equals "true" "$REGEX_CACHE_INITIALIZED" "Cache should be initialized"
}

test_cache_contains_expected_patterns() {
    init_regex_cache
    
    # Vérifier que les patterns essentiels sont présents
    local pbi_pattern
    pbi_pattern=$(get_cached_regex "PBI_ID")
    assert_not_empty "$pbi_pattern" "PBI_ID pattern should exist"
    
    local task_pattern
    task_pattern=$(get_cached_regex "TASK_ID")
    assert_not_empty "$task_pattern" "TASK_ID pattern should exist"
    
    local date_pattern
    date_pattern=$(get_cached_regex "DATE_YYYY_MM_DD")
    assert_not_empty "$date_pattern" "DATE pattern should exist"
}

#------------------------------------------------------------------------------
# Tests de récupération de patterns
#------------------------------------------------------------------------------

test_get_cached_regex_success() {
    init_regex_cache
    
    local pattern
    pattern=$(get_cached_regex "PBI_ID")
    local return_code=$?
    
    assert_return_code 0 $return_code "Should return 0 for existing pattern"
    assert_equals "PBI-[0-9]+" "$pattern" "Should return correct PBI pattern"
}

test_get_cached_regex_failure() {
    init_regex_cache
    
    local pattern
    pattern=$(get_cached_regex "NONEXISTENT_PATTERN")
    local return_code=$?
    
    assert_return_code 1 $return_code "Should return 1 for non-existing pattern"
}

test_use_regex_pattern_with_cache() {
    init_regex_cache
    
    local pattern
    pattern=$(use_regex_pattern "PBI_ID" "fallback-pattern")
    
    assert_equals "PBI-[0-9]+" "$pattern" "Should return cached pattern"
}

test_use_regex_pattern_with_fallback() {
    init_regex_cache
    
    local pattern
    pattern=$(use_regex_pattern "NONEXISTENT" "fallback-pattern")
    
    assert_equals "fallback-pattern" "$pattern" "Should return fallback pattern"
}

#------------------------------------------------------------------------------
# Tests des fonctions utilitaires
#------------------------------------------------------------------------------

test_extract_pbi_id() {
    init_regex_cache
    
    local pbi_id
    pbi_id=$(extract_pbi_id "PBI-42-PROPOSED.md")
    assert_equals "PBI-42" "$pbi_id" "Should extract PBI-42"
    
    pbi_id=$(extract_pbi_id "TASK-7-1-TODO.md")
    assert_equals "" "$pbi_id" "Should not extract from TASK filename"
}

test_extract_task_id() {
    init_regex_cache
    
    local task_id
    task_id=$(extract_task_id "TASK-7-1-TODO.md")
    assert_equals "TASK-7-1" "$task_id" "Should extract TASK-7-1"
    
    task_id=$(extract_task_id "PBI-42-PROPOSED.md")
    assert_equals "" "$task_id" "Should not extract from PBI filename"
}

test_validate_date_format() {
    init_regex_cache
    
    # Dates valides
    validate_date_format "2025-07-03"
    assert_return_code 0 $? "Should validate correct date format"
    
    validate_date_format "2025-12-31"
    assert_return_code 0 $? "Should validate correct date format"
    
    # Dates invalides
    validate_date_format "25-07-03"
    assert_return_code 1 $? "Should reject short year"
    
    validate_date_format "2025-7-3"
    assert_return_code 1 $? "Should reject single digit month/day"
    
    validate_date_format "not-a-date"
    assert_return_code 1 $? "Should reject non-date string"
}

test_validate_config_line() {
    init_regex_cache
    
    # Lignes de config valides
    validate_config_line "PROJECT_WORKDIR=/tmp/test"
    assert_return_code 0 $? "Should validate config line"
    
    validate_config_line "CACHE_ENABLED=true"
    assert_return_code 0 $? "Should validate boolean config"
    
    # Lignes invalides
    validate_config_line "invalid line"
    assert_return_code 1 $? "Should reject invalid config line"
    
    validate_config_line "# comment"
    assert_return_code 1 $? "Should reject comment line"
}

#------------------------------------------------------------------------------
# Tests de performance et statistiques
#------------------------------------------------------------------------------

test_statistics_tracking() {
    clear_regex_cache
    init_regex_cache
    
    # Faire quelques appels pour générer des stats
    get_cached_regex "PBI_ID" >/dev/null
    get_cached_regex "PBI_ID" >/dev/null
    get_cached_regex "NONEXISTENT" >/dev/null
    
    # Vérifier que les stats sont trackées (nouvelle implémentation avec fichiers)
    local hits
    hits=$(cat "$REGEX_CACHE_DIR/stats_PBI_ID_hits" 2>/dev/null || echo "0")
    local misses
    misses=$(cat "$REGEX_CACHE_DIR/stats_NONEXISTENT_misses" 2>/dev/null || echo "0")
    
    assert_equals "2" "$hits" "Should track 2 hits for PBI_ID"
    assert_equals "1" "$misses" "Should track 1 miss for NONEXISTENT"
}

test_clear_cache() {
    init_regex_cache
    
    # Faire quelques appels
    get_cached_regex "PBI_ID" >/dev/null
    
    # Nettoyer le cache
    clear_regex_cache
    
    assert_equals "false" "$REGEX_CACHE_INITIALIZED" "Cache should be marked as not initialized"
}

#------------------------------------------------------------------------------
# Exécution des tests
#------------------------------------------------------------------------------

main() {
    echo "🧪 Tests du Cache Regex - TASK-7-1"
    echo "===================================="
    echo ""
    
    # Tests d'initialisation
    run_test "Cache initialization" test_cache_initialization
    run_test "Cache contains expected patterns" test_cache_contains_expected_patterns
    
    # Tests de récupération
    run_test "Get cached regex - success" test_get_cached_regex_success
    run_test "Get cached regex - failure" test_get_cached_regex_failure
    run_test "Use regex pattern with cache" test_use_regex_pattern_with_cache
    run_test "Use regex pattern with fallback" test_use_regex_pattern_with_fallback
    
    # Tests des fonctions utilitaires
    run_test "Extract PBI ID" test_extract_pbi_id
    run_test "Extract TASK ID" test_extract_task_id
    run_test "Validate date format" test_validate_date_format
    run_test "Validate config line" test_validate_config_line
    
    # Tests de performance
    run_test "Statistics tracking" test_statistics_tracking
    run_test "Clear cache" test_clear_cache
    
    echo ""
    echo "📊 Résultats des Tests"
    echo "======================"
    echo "Total: $TEST_COUNT tests"
    echo "✅ Réussis: $PASSED_COUNT"
    echo "❌ Échoués: $FAILED_COUNT"
    
    if [ $FAILED_COUNT -eq 0 ]; then
        echo ""
        echo "🎉 Tous les tests sont passés !"
        return 0
    else
        echo ""
        echo "💥 $FAILED_COUNT test(s) ont échoué"
        return 1
    fi
}

# Exécution si appelé directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi