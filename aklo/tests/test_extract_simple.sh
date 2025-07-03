#!/bin/bash

# Test simple pour extract_and_cache_structure
set -e

# Configuration
TEST_DIR="/tmp/aklo_test_extract"
CACHE_DIR="/tmp/aklo_cache"
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Source des fonctions
source "../bin/aklo_extract_functions.sh"

echo -e "${BLUE}🧪 Tests simples - Extract and Cache${NC}"
echo "======================================================================="

# Nettoyage et setup
rm -rf "$TEST_DIR" "$CACHE_DIR"
mkdir -p "$TEST_DIR" "$CACHE_DIR"

# Créer un fichier protocole minimal
cat > "$TEST_DIR/test_protocol.md" << 'EOF'
# PROTOCOLE DE TEST

### 2.3. Structure Obligatoire Du Fichier PBI

```markdown
# PBI-{{ID}} : {{TITLE}}

## 1. Description
{{DESCRIPTION}}
```

## SECTION 3 - Fin
EOF

# Test 1: extract_artefact_structure
echo -e "${BLUE}Test 1: extract_artefact_structure${NC}"
result=$(extract_artefact_structure "$TEST_DIR/test_protocol.md" "PBI")
if [[ "$result" == *"PBI-{{ID}} : {{TITLE}}"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Extraction PBI fonctionne"
else
    echo -e "${RED}✗ FAIL${NC}: Extraction PBI échoue"
    echo "Résultat: '$result'"
fi

# Test 2: extract_and_cache_structure
echo -e "${BLUE}Test 2: extract_and_cache_structure${NC}"
cache_file="$CACHE_DIR/test.parsed"
result=$(extract_and_cache_structure "$TEST_DIR/test_protocol.md" "PBI" "$cache_file")
exit_code=$?

if [ $exit_code -eq 0 ] && [ -f "$cache_file" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Cache créé avec succès"
    echo "Contenu cache: $(head -1 "$cache_file")"
else
    echo -e "${RED}✗ FAIL${NC}: Création cache échouée (code: $exit_code)"
fi

# Test 3: Validation cache
echo -e "${BLUE}Test 3: Validation cache${NC}"
protocol_mtime=$(get_file_mtime "$TEST_DIR/test_protocol.md")
if cache_is_valid "$cache_file" "$protocol_mtime"; then
    echo -e "${GREEN}✓ PASS${NC}: Cache valide"
else
    echo -e "${RED}✗ FAIL${NC}: Cache invalide"
fi

# Nettoyage
rm -rf "$TEST_DIR" "$CACHE_DIR"

echo "======================================================================="
echo -e "${GREEN}🎉 Tests simples terminés !${NC}"