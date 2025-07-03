#!/bin/bash

# Tests pour les fonctions d'optimisation I/O par batch
# TASK-7-2: Test-Driven Development pour optimisations I/O

# Source des fonctions à tester
script_dir="$(dirname "$0")"
source "${script_dir}/../bin/aklo_cache_functions.sh"
source "${script_dir}/../bin/aklo_batch_io.sh"

# Couleurs pour les tests
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs de tests
total_tests=0
passed_tests=0
failed_tests=0

# Fonction utilitaire pour les tests
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    total_tests=$((total_tests + 1))
    
    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        failed_tests=$((failed_tests + 1))
    fi
}

assert_function_exists() {
    local function_name="$1"
    local test_name="$2"
    
    total_tests=$((total_tests + 1))
    
    if command -v "$function_name" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $test_name"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Function '$function_name' does not exist"
        failed_tests=$((failed_tests + 1))
    fi
}

# Setup des fichiers de test temporaires
setup_test_files() {
    local test_dir="/tmp/aklo_batch_test"
    mkdir -p "$test_dir"
    
    # Créer des fichiers de test
    echo "content1" > "$test_dir/file1.txt"
    echo "content2" > "$test_dir/file2.txt"
    echo "content3" > "$test_dir/file3.txt"
    
    echo "$test_dir"
}

cleanup_test_files() {
    local test_dir="$1"
    rm -rf "$test_dir"
}

echo "=== Tests pour les fonctions d'optimisation I/O par batch ==="
echo

# Test 1: Vérifier l'existence de la fonction batch_read_files
echo "Test 1: Fonction batch_read_files existe"
assert_function_exists "batch_read_files" "batch_read_files function exists"
echo

# Test 2: Vérifier l'existence de la fonction batch_check_existence
echo "Test 2: Fonction batch_check_existence existe"
assert_function_exists "batch_check_existence" "batch_check_existence function exists"
echo

# Test 3: Vérifier l'existence de la fonction batch_file_operations
echo "Test 3: Fonction batch_file_operations existe"
assert_function_exists "batch_file_operations" "batch_file_operations function exists"
echo

# Test 4: Test de batch_read_files avec fichiers multiples
echo "Test 4: batch_read_files lit plusieurs fichiers"
test_dir=$(setup_test_files)

if command -v batch_read_files >/dev/null 2>&1; then
    result=$(batch_read_files "$test_dir/file1.txt" "$test_dir/file2.txt" "$test_dir/file3.txt" 2>/dev/null)
    expected_pattern="content1.*content2.*content3"
    
    if echo "$result" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✓${NC} batch_read_files reads multiple files correctly"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}✗${NC} batch_read_files reads multiple files correctly"
        echo "  Expected pattern: $expected_pattern"
        echo "  Actual result: $result"
        failed_tests=$((failed_tests + 1))
    fi
    total_tests=$((total_tests + 1))
else
    echo -e "${YELLOW}⚠${NC} batch_read_files function not implemented yet"
fi

cleanup_test_files "$test_dir"
echo

# Test 5: Test de batch_check_existence avec fichiers existants et non-existants
echo "Test 5: batch_check_existence vérifie l'existence de fichiers"
test_dir=$(setup_test_files)

if command -v batch_check_existence >/dev/null 2>&1; then
    result=$(batch_check_existence "$test_dir/file1.txt" "$test_dir/nonexistent.txt" "$test_dir/file2.txt" 2>/dev/null)
    
    # Le résultat devrait indiquer que file1.txt et file2.txt existent, mais pas nonexistent.txt
    if echo "$result" | grep -q "file1.txt.*exists" && echo "$result" | grep -q "file2.txt.*exists" && echo "$result" | grep -q "nonexistent.txt.*not.*exist"; then
        echo -e "${GREEN}✓${NC} batch_check_existence verifies file existence correctly"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}✗${NC} batch_check_existence verifies file existence correctly"
        echo "  Result: $result"
        failed_tests=$((failed_tests + 1))
    fi
    total_tests=$((total_tests + 1))
else
    echo -e "${YELLOW}⚠${NC} batch_check_existence function not implemented yet"
fi

cleanup_test_files "$test_dir"
echo

# Test 6: Test des métriques de performance
echo "Test 6: Métriques de performance disponibles"
if command -v get_io_metrics >/dev/null 2>&1; then
    result=$(get_io_metrics 2>/dev/null)
    
    if echo "$result" | grep -q "syscalls\|operations\|performance"; then
        echo -e "${GREEN}✓${NC} Performance metrics are available"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}✗${NC} Performance metrics are available"
        echo "  Result: $result"
        failed_tests=$((failed_tests + 1))
    fi
    total_tests=$((total_tests + 1))
else
    echo -e "${YELLOW}⚠${NC} get_io_metrics function not implemented yet"
fi

echo

# Résumé des tests
echo "=== Résumé des tests ==="
echo "Total: $total_tests"
echo -e "Réussis: ${GREEN}$passed_tests${NC}"
echo -e "Échoués: ${RED}$failed_tests${NC}"

if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}Tous les tests sont passés!${NC}"
    exit 0
else
    echo -e "${RED}$failed_tests test(s) ont échoué.${NC}"
    exit 1
fi