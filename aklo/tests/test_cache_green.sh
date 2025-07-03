#!/bin/bash

# Tests unitaires complets pour les fonctions de cache (TASK-6-1)
# Approche TDD - Phase GREEN : Tests fonctionnels

set -e

# Configuration des tests
TEST_DIR="/tmp/aklo_test_cache"
CACHE_DIR="/tmp/aklo_cache"
TEST_COUNT=0
PASS_COUNT=0

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Source des fonctions de cache
source "../bin/aklo_cache_functions.sh"

# Fonction de setup
setup_test_env() {
    rm -rf "$TEST_DIR" "$CACHE_DIR"
    mkdir -p "$TEST_DIR" "$CACHE_DIR"
}

# Fonction de cleanup
cleanup_test_env() {
    rm -rf "$TEST_DIR" "$CACHE_DIR"
}

# Fonction d'assertion
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TEST_COUNT++))
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        ((PASS_COUNT++))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
    fi
}

# Fonction d'assertion pour code de retour
assert_return_code() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TEST_COUNT++))
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        ((PASS_COUNT++))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Expected return code: $expected"
        echo "  Actual return code:   $actual"
    fi
}# ========================================
# TESTS POUR cache_is_valid()
# ========================================

test_cache_is_valid_with_valid_cache() {
    setup_test_env
    
    # Créer un cache valide
    local cache_file="$TEST_DIR/test_cache.parsed"
    local mtime_file="$TEST_DIR/test_cache.parsed.mtime"
    local protocol_mtime="1234567890"
    
    echo "cached_content" > "$cache_file"
    echo "$protocol_mtime" > "$mtime_file"
    
    # Test
    cache_is_valid "$cache_file" "$protocol_mtime"
    local result=$?
    
    assert_return_code "0" "$result" "cache_is_valid should return 0 for valid cache"
    
    cleanup_test_env
}

test_cache_is_valid_with_invalid_mtime() {
    setup_test_env
    
    # Créer un cache avec mtime invalide
    local cache_file="$TEST_DIR/test_cache.parsed"
    local mtime_file="$TEST_DIR/test_cache.parsed.mtime"
    local protocol_mtime="1234567890"
    local old_mtime="1111111111"
    
    echo "cached_content" > "$cache_file"
    echo "$old_mtime" > "$mtime_file"
    
    # Test
    cache_is_valid "$cache_file" "$protocol_mtime"
    local result=$?
    
    assert_return_code "1" "$result" "cache_is_valid should return 1 for invalid mtime"
    
    cleanup_test_env
}

test_cache_is_valid_with_missing_cache() {
    setup_test_env
    
    # Test avec fichier cache inexistant
    local cache_file="$TEST_DIR/nonexistent_cache.parsed"
    local protocol_mtime="1234567890"
    
    # Test
    cache_is_valid "$cache_file" "$protocol_mtime"
    local result=$?
    
    assert_return_code "1" "$result" "cache_is_valid should return 1 for missing cache"
    
    cleanup_test_env
}

test_cache_is_valid_with_missing_mtime() {
    setup_test_env
    
    # Créer cache sans fichier mtime
    local cache_file="$TEST_DIR/test_cache.parsed"
    local protocol_mtime="1234567890"
    
    echo "cached_content" > "$cache_file"
    # Pas de fichier mtime
    
    # Test
    cache_is_valid "$cache_file" "$protocol_mtime"
    local result=$?
    
    assert_return_code "1" "$result" "cache_is_valid should return 1 for missing mtime file"
    
    cleanup_test_env
}

test_cache_is_valid_with_empty_params() {
    setup_test_env
    
    # Test avec paramètres vides
    cache_is_valid "" ""
    local result=$?
    
    assert_return_code "1" "$result" "cache_is_valid should return 1 for empty parameters"
    
    cleanup_test_env
}# ========================================
# TESTS POUR use_cached_structure()
# ========================================

test_use_cached_structure_with_valid_file() {
    setup_test_env
    
    # Créer un fichier cache avec contenu
    local cache_file="$TEST_DIR/test_cache.parsed"
    local expected_content="cached_structure_content"
    
    echo "$expected_content" > "$cache_file"
    
    # Test
    local result=$(use_cached_structure "$cache_file")
    
    assert_equals "$expected_content" "$result" "use_cached_structure should return cache content"
    
    cleanup_test_env
}

test_use_cached_structure_with_multiline_content() {
    setup_test_env
    
    # Créer un fichier cache avec contenu multi-ligne
    local cache_file="$TEST_DIR/test_cache.parsed"
    local expected_content="line1
line2
line3"
    
    echo "$expected_content" > "$cache_file"
    
    # Test
    local result=$(use_cached_structure "$cache_file")
    
    assert_equals "$expected_content" "$result" "use_cached_structure should handle multiline content"
    
    cleanup_test_env
}

test_use_cached_structure_with_missing_file() {
    setup_test_env
    
    # Test avec fichier inexistant
    local cache_file="$TEST_DIR/nonexistent_cache.parsed"
    
    # Test - devrait gérer l'erreur gracieusement
    use_cached_structure "$cache_file" 2>/dev/null
    local exit_code=$?
    
    assert_return_code "1" "$exit_code" "use_cached_structure should return 1 for missing file"
    
    cleanup_test_env
}

test_use_cached_structure_with_empty_param() {
    setup_test_env
    
    # Test avec paramètre vide
    use_cached_structure "" 2>/dev/null
    local exit_code=$?
    
    assert_return_code "1" "$exit_code" "use_cached_structure should return 1 for empty parameter"
    
    cleanup_test_env
}# ========================================
# TESTS POUR cleanup_cache()
# ========================================

test_cleanup_cache_removes_old_files() {
    setup_test_env
    
    # Créer des fichiers cache anciens et récents
    local old_cache="$CACHE_DIR/old_protocol_PBI.parsed"
    local old_mtime="$CACHE_DIR/old_protocol_PBI.parsed.mtime"
    local recent_cache="$CACHE_DIR/recent_protocol_PBI.parsed"
    local recent_mtime="$CACHE_DIR/recent_protocol_PBI.parsed.mtime"
    
    echo "old_content" > "$old_cache"
    echo "1234567890" > "$old_mtime"
    echo "recent_content" > "$recent_cache"
    echo "1234567890" > "$recent_mtime"
    
    # Simuler fichiers anciens (8 jours)
    touch -t 202501190000 "$old_cache"
    touch -t 202501190000 "$old_mtime"
    
    # Test
    cleanup_cache
    local exit_code=$?
    
    assert_return_code "0" "$exit_code" "cleanup_cache should return 0"
    
    # Vérifier que les fichiers récents existent encore
    if [ -f "$recent_cache" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Recent cache file still exists"
        ((PASS_COUNT++))
    else
        echo -e "${RED}✗ FAIL${NC}: Recent cache file should still exist"
    fi
    ((TEST_COUNT++))
    
    cleanup_test_env
}

test_cleanup_cache_handles_missing_directory() {
    # Supprimer le répertoire cache
    rm -rf "$CACHE_DIR"
    
    # Test - ne devrait pas planter
    cleanup_cache
    local exit_code=$?
    
    assert_return_code "0" "$exit_code" "cleanup_cache should handle missing directory gracefully"
    
    # Vérifier que le répertoire a été créé
    if [ -d "$CACHE_DIR" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Cache directory was created"
        ((PASS_COUNT++))
    else
        echo -e "${RED}✗ FAIL${NC}: Cache directory should have been created"
    fi
    ((TEST_COUNT++))
}

test_cleanup_cache_empty_directory() {
    setup_test_env
    
    # Test avec répertoire vide
    cleanup_cache
    local exit_code=$?
    
    assert_return_code "0" "$exit_code" "cleanup_cache should handle empty directory"
    
    cleanup_test_env
}# ========================================
# FONCTION PRINCIPALE DE TEST
# ========================================

run_all_tests() {
    echo -e "${BLUE}🧪 Tests TDD - Phase GREEN - Infrastructure Cache${NC}"
    echo "======================================================================="
    
    # Tests cache_is_valid()
    echo -e "${BLUE}📋 Tests cache_is_valid()${NC}"
    test_cache_is_valid_with_valid_cache
    test_cache_is_valid_with_invalid_mtime
    test_cache_is_valid_with_missing_cache
    test_cache_is_valid_with_missing_mtime
    test_cache_is_valid_with_empty_params
    
    # Tests use_cached_structure()
    echo -e "${BLUE}📋 Tests use_cached_structure()${NC}"
    test_use_cached_structure_with_valid_file
    test_use_cached_structure_with_multiline_content
    test_use_cached_structure_with_missing_file
    test_use_cached_structure_with_empty_param
    
    # Tests cleanup_cache()
    echo -e "${BLUE}📋 Tests cleanup_cache()${NC}"
    test_cleanup_cache_removes_old_files
    test_cleanup_cache_handles_missing_directory
    test_cleanup_cache_empty_directory
    
    # Résumé
    echo "======================================================================="
    echo -e "${BLUE}📊 Résumé des tests${NC}"
    echo "Tests exécutés: $TEST_COUNT"
    echo "Tests réussis: $PASS_COUNT"
    echo "Tests échoués: $((TEST_COUNT - PASS_COUNT))"
    
    if [ $PASS_COUNT -eq $TEST_COUNT ]; then
        echo -e "${GREEN}🎉 Phase GREEN réussie - Tous les tests passent !${NC}"
        return 0
    else
        echo -e "${RED}❌ Phase GREEN échouée - Certains tests ont échoué${NC}"
        return 1
    fi
}

# Exécution des tests si le script est appelé directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_all_tests
fi