#!/bin/bash

# Tests unitaires pour les fonctions de cache (TASK-6-1)
# Phase GREEN - Tests simples

set -e

# Configuration
TEST_DIR="/tmp/aklo_test_cache"
CACHE_DIR="/tmp/aklo_cache"
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Source des fonctions
source "../bin/aklo_cache_functions.sh"

# Setup
setup_test() {
    rm -rf "$TEST_DIR" "$CACHE_DIR"
    mkdir -p "$TEST_DIR" "$CACHE_DIR"
}

# Cleanup
cleanup_test() {
    rm -rf "$TEST_DIR" "$CACHE_DIR"
}

echo -e "${BLUE}🧪 Tests Phase GREEN - Infrastructure Cache${NC}"
echo "======================================================================="

# Test 1: cache_is_valid avec cache valide
echo -e "${BLUE}Test 1: cache_is_valid avec cache valide${NC}"
setup_test
cache_file="$TEST_DIR/test.parsed"
mtime_file="$TEST_DIR/test.parsed.mtime"
echo "content" > "$cache_file"
echo "1234567890" > "$mtime_file"

if cache_is_valid "$cache_file" "1234567890"; then
    echo -e "${GREEN}✓ PASS${NC}: cache_is_valid fonctionne avec cache valide"
else
    echo -e "${RED}✗ FAIL${NC}: cache_is_valid devrait retourner 0 pour cache valide"
fi
cleanup_test

# Test 2: cache_is_valid avec mtime invalide
echo -e "${BLUE}Test 2: cache_is_valid avec mtime invalide${NC}"
setup_test
cache_file="$TEST_DIR/test.parsed"
mtime_file="$TEST_DIR/test.parsed.mtime"
echo "content" > "$cache_file"
echo "1111111111" > "$mtime_file"

if ! cache_is_valid "$cache_file" "1234567890"; then
    echo -e "${GREEN}✓ PASS${NC}: cache_is_valid retourne 1 pour mtime invalide"
else
    echo -e "${RED}✗ FAIL${NC}: cache_is_valid devrait retourner 1 pour mtime invalide"
fi
cleanup_test

# Test 3: use_cached_structure
echo -e "${BLUE}Test 3: use_cached_structure${NC}"
setup_test
cache_file="$TEST_DIR/test.parsed"
expected="test_content"
echo "$expected" > "$cache_file"

result=$(use_cached_structure "$cache_file")
if [ "$result" = "$expected" ]; then
    echo -e "${GREEN}✓ PASS${NC}: use_cached_structure retourne le bon contenu"
else
    echo -e "${RED}✗ FAIL${NC}: use_cached_structure contenu incorrect"
fi
cleanup_test

# Test 4: cleanup_cache
echo -e "${BLUE}Test 4: cleanup_cache${NC}"
setup_test
if cleanup_cache; then
    echo -e "${GREEN}✓ PASS${NC}: cleanup_cache s'exécute sans erreur"
else
    echo -e "${RED}✗ FAIL${NC}: cleanup_cache a échoué"
fi
cleanup_test

echo "======================================================================="
echo -e "${GREEN}🎉 Phase GREEN terminée !${NC}"