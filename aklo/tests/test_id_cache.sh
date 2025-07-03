#!/bin/bash

# Tests pour le cache des IDs de la fonction get_next_id
# TASK-7-3: Test-Driven Development pour optimisation des IDs

# Source des fonctions à tester
script_dir="$(dirname "$0")"
source "${script_dir}/../modules/cache/cache_functions.sh"
source "${script_dir}/../modules/cache/id_cache.sh"

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
    local test_dir="/tmp/aklo_id_test"
    mkdir -p "$test_dir"
    
    # Créer des fichiers d'artefacts simulés
    touch "$test_dir/PBI-1-DONE.md"
    touch "$test_dir/PBI-3-PROPOSED.md"
    touch "$test_dir/PBI-7-AGREED.md"
    touch "$test_dir/TASK-1-1-DONE.md"
    touch "$test_dir/TASK-1-2-TODO.md"
    touch "$test_dir/TASK-7-1-DONE.md"
    touch "$test_dir/TASK-7-2-DONE.md"
    
    echo "$test_dir"
}

cleanup_test_files() {
    local test_dir="$1"
    rm -rf "$test_dir"
}

echo "=== Tests pour le cache des IDs ==="
echo

# Test 1: Vérifier l'existence de la fonction get_next_id_cached
echo "Test 1: Fonction get_next_id_cached existe"
assert_function_exists "get_next_id_cached" "get_next_id_cached function exists"
echo

# Test 2: Vérifier l'existence de la fonction invalidate_id_cache
echo "Test 2: Fonction invalidate_id_cache existe"
assert_function_exists "invalidate_id_cache" "invalidate_id_cache function exists"
echo

# Test 3: Vérifier l'existence de la fonction update_id_cache
echo "Test 3: Fonction update_id_cache existe"
assert_function_exists "update_id_cache" "update_id_cache function exists"
echo

# Test 4: Test de get_next_id_cached avec PBI
echo "Test 4: get_next_id_cached calcule le bon ID pour PBI"
test_dir=$(setup_test_files)

if command -v get_next_id_cached >/dev/null 2>&1; then
    result=$(get_next_id_cached "$test_dir" "PBI" 2>/dev/null)
    expected="8"  # Le prochain ID après PBI-7
    
    assert_equals "$expected" "$result" "get_next_id_cached returns correct PBI ID"
    total_tests=$((total_tests + 1))
else
    echo -e "${YELLOW}⚠${NC} get_next_id_cached function not implemented yet"
fi

cleanup_test_files "$test_dir"
echo

# Test 5: Test de get_next_id_cached avec TASK
echo "Test 5: get_next_id_cached calcule le bon ID pour TASK"
test_dir=$(setup_test_files)

if command -v get_next_id_cached >/dev/null 2>&1; then
    result=$(get_next_id_cached "$test_dir" "TASK" 2>/dev/null)
    expected="8"  # Le prochain ID après TASK-7-2
    
    assert_equals "$expected" "$result" "get_next_id_cached returns correct TASK ID"
    total_tests=$((total_tests + 1))
else
    echo -e "${YELLOW}⚠${NC} get_next_id_cached function not implemented yet"
fi

cleanup_test_files "$test_dir"
echo

# Test 6: Test du cache - deuxième appel doit être plus rapide
echo "Test 6: Cache améliore les performances sur appels répétitifs"
test_dir=$(setup_test_files)

if command -v get_next_id_cached >/dev/null 2>&1; then
    # Premier appel (sans cache)
    start_time=$(date +%s%N)
    first_result=$(get_next_id_cached "$test_dir" "PBI" 2>/dev/null)
    end_time=$(date +%s%N)
    first_duration=$(( (end_time - start_time) / 1000000 )) # en ms
    
    # Deuxième appel (avec cache)
    start_time=$(date +%s%N)
    second_result=$(get_next_id_cached "$test_dir" "PBI" 2>/dev/null)
    end_time=$(date +%s%N)
    second_duration=$(( (end_time - start_time) / 1000000 )) # en ms
    
    # Les résultats doivent être identiques
    assert_equals "$first_result" "$second_result" "Cache returns consistent results"
    
    # Le deuxième appel doit être plus rapide (ou au moins pas plus lent)
    if [ $second_duration -le $first_duration ]; then
        echo -e "${GREEN}✓${NC} Cache improves or maintains performance"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}✗${NC} Cache improves or maintains performance"
        echo "  First call: ${first_duration}ms, Second call: ${second_duration}ms"
        failed_tests=$((failed_tests + 1))
    fi
    total_tests=$((total_tests + 1))
else
    echo -e "${YELLOW}⚠${NC} get_next_id_cached function not implemented yet"
fi

cleanup_test_files "$test_dir"
echo

# Test 7: Test d'invalidation du cache
echo "Test 7: invalidate_id_cache fonctionne correctement"
test_dir=$(setup_test_files)

if command -v get_next_id_cached >/dev/null 2>&1 && command -v invalidate_id_cache >/dev/null 2>&1; then
    # Premier appel pour mettre en cache
    first_result=$(get_next_id_cached "$test_dir" "PBI" 2>/dev/null)
    
    # Ajouter un nouveau fichier (simulation de changement externe)
    touch "$test_dir/PBI-10-NEW.md"
    
    # Invalider le cache
    invalidate_id_cache "$test_dir" "PBI"
    
    # Deuxième appel doit refléter le changement
    second_result=$(get_next_id_cached "$test_dir" "PBI" 2>/dev/null)
    expected="11"  # Le prochain ID après PBI-10
    
    assert_equals "$expected" "$second_result" "Cache invalidation works correctly"
    total_tests=$((total_tests + 1))
else
    echo -e "${YELLOW}⚠${NC} Cache invalidation functions not implemented yet"
fi

cleanup_test_files "$test_dir"
echo

# Test 8: Test des métriques de cache
echo "Test 8: Métriques de cache disponibles"
if command -v get_id_cache_metrics >/dev/null 2>&1; then
    result=$(get_id_cache_metrics 2>/dev/null)
    
    if echo "$result" | grep -q "Hits\|Misses\|Cache"; then
        echo -e "${GREEN}✓${NC} Cache metrics are available"
        passed_tests=$((passed_tests + 1))
    else
        echo -e "${RED}✗${NC} Cache metrics are available"
        echo "  Result: $result"
        failed_tests=$((failed_tests + 1))
    fi
    total_tests=$((total_tests + 1))
else
    echo -e "${YELLOW}⚠${NC} get_id_cache_metrics function not implemented yet"
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