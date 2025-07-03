#!/bin/bash

# Tests pour la version refactorisée (Phase BLUE)
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

echo -e "${BLUE}🧪 Tests Phase BLUE - Fonctions refactorisées${NC}"
echo "======================================================================="

# Test des fonctions utilitaires
echo -e "${BLUE}Test: generate_cache_filename${NC}"
result=$(generate_cache_filename "DEVELOPPEMENT" "PBI")
expected="/tmp/aklo_cache/protocol_DEVELOPPEMENT_PBI.parsed"
if [ "$result" = "$expected" ]; then
    echo -e "${GREEN}✓ PASS${NC}: generate_cache_filename fonctionne"
else
    echo -e "${RED}✗ FAIL${NC}: generate_cache_filename - Expected: $expected, Got: $result"
fi

echo -e "${BLUE}Test: get_file_mtime${NC}"
# Créer un fichier test
test_file="$TEST_DIR/test_mtime.txt"
mkdir -p "$TEST_DIR"
echo "test" > "$test_file"
mtime=$(get_file_mtime "$test_file")
if [ -n "$mtime" ] && [ "$mtime" -gt 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}: get_file_mtime retourne un timestamp valide"
else
    echo -e "${RED}✗ FAIL${NC}: get_file_mtime devrait retourner un timestamp valide"
fi

echo -e "${BLUE}Test: init_cache_dir${NC}"
rm -rf "$CACHE_DIR"
if init_cache_dir && [ -d "$CACHE_DIR" ]; then
    echo -e "${GREEN}✓ PASS${NC}: init_cache_dir crée le répertoire"
else
    echo -e "${RED}✗ FAIL${NC}: init_cache_dir devrait créer le répertoire"
fi

# Nettoyage
rm -rf "$TEST_DIR" "$CACHE_DIR"

echo "======================================================================="
echo -e "${GREEN}🎉 Phase BLUE terminée !${NC}"