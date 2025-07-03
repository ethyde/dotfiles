#!/bin/bash

# Tests unitaires pour extract_and_cache_structure (TASK-6-2)
# Phase GREEN - Tests fonctionnels

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

# Setup
setup_test() {
    rm -rf "$TEST_DIR" "$CACHE_DIR"
    mkdir -p "$TEST_DIR" "$CACHE_DIR"
    
    # Créer un fichier protocole de test réaliste
    cat > "$TEST_DIR/test_protocol.md" << 'EOF'
# PROTOCOLE DE TEST

## SECTION 1 - Introduction

### 2.3. Structure Obligatoire Du Fichier PBI

```markdown
# PBI-{{ID}} : {{TITLE}}

---
**Statut:** {{STATUS}}
**Date de création:** {{DATE}}
**Priorité:** {{PRIORITY}}
**Effort estimé:** {{EFFORT}} points
---

## 1. Description de la User Story

_En tant que **{{USER_ROLE}}**, je veux **{{FEATURE}}**, afin de **{{BENEFIT}}**._

## 2. Critères d'Acceptation

{{ACCEPTANCE_CRITERIA}}

## 3. Spécifications Techniques

{{TECHNICAL_SPECS}}
```

## SECTION 3 - Autre contenu

### 2.3. Structure Obligatoire Du Fichier Task

```markdown
# TASK-{{PBI_ID}}-{{TASK_ID}} : {{TITLE}}

---
**Statut:** {{STATUS}}
**Date de création:** {{DATE}}
**PBI Parent:** {{PBI_PARENT}}
**Effort estimé:** {{EFFORT}} points
---

## 1. Description Technique

{{DESCRIPTION}}

## 2. Definition of Done

{{DOD_ITEMS}}
```

## SECTION 3 - Fin
EOF
}

# Cleanup
cleanup_test() {
    rm -rf "$TEST_DIR" "$CACHE_DIR"
}

echo -e "${BLUE}🧪 Tests Phase GREEN - Extract and Cache Functions${NC}"
echo "======================================================================="

# Test 1: extract_artefact_structure avec PBI
echo -e "${BLUE}Test 1: extract_artefact_structure avec PBI${NC}"
setup_test
protocol_file="$TEST_DIR/test_protocol.md"
result=$(extract_artefact_structure "$protocol_file" "PBI")
if [[ "$result" == *"PBI-{{ID}} : {{TITLE}}"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: extract_artefact_structure extrait correctement la structure PBI"
else
    echo -e "${RED}✗ FAIL${NC}: extract_artefact_structure - structure PBI incorrecte"
    echo "Résultat: $result"
fi
cleanup_test

# Test 2: extract_artefact_structure avec TASK
echo -e "${BLUE}Test 2: extract_artefact_structure avec TASK${NC}"
setup_test
protocol_file="$TEST_DIR/test_protocol.md"
result=$(extract_artefact_structure "$protocol_file" "TASK")
if [[ "$result" == *"TASK-{{PBI_ID}}-{{TASK_ID}} : {{TITLE}}"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: extract_artefact_structure extrait correctement la structure TASK"
else
    echo -e "${RED}✗ FAIL${NC}: extract_artefact_structure - structure TASK incorrecte"
    echo "Résultat: $result"
fi
cleanup_test

# Test 3: extract_artefact_structure avec type inexistant
echo -e "${BLUE}Test 3: extract_artefact_structure avec type inexistant${NC}"
setup_test
protocol_file="$TEST_DIR/test_protocol.md"
extract_artefact_structure "$protocol_file" "NONEXISTENT" 2>/dev/null
exit_code=$?
if [ $exit_code -eq 1 ]; then
    echo -e "${GREEN}✓ PASS${NC}: extract_artefact_structure retourne 1 pour type inexistant"
else
    echo -e "${RED}✗ FAIL${NC}: extract_artefact_structure devrait retourner 1 pour type inexistant"
fi
cleanup_test

# Test 4: extract_and_cache_structure complet
echo -e "${BLUE}Test 4: extract_and_cache_structure complet${NC}"
setup_test
protocol_file="$TEST_DIR/test_protocol.md"
cache_file="$CACHE_DIR/test_cache.parsed"

result=$(extract_and_cache_structure "$protocol_file" "PBI" "$cache_file")
exit_code=$?

if [ $exit_code -eq 0 ] && [ -f "$cache_file" ] && [ -f "${cache_file}.mtime" ]; then
    echo -e "${GREEN}✓ PASS${NC}: extract_and_cache_structure crée les fichiers cache"
    
    # Vérifier le contenu
    cached_content=$(cat "$cache_file")
    if [[ "$cached_content" == *"PBI-{{ID}} : {{TITLE}}"* ]]; then
        echo -e "${GREEN}✓ PASS${NC}: Contenu cache correct"
    else
        echo -e "${RED}✗ FAIL${NC}: Contenu cache incorrect"
    fi
    
    # Vérifier le timestamp
    if [ -s "${cache_file}.mtime" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Fichier mtime créé"
    else
        echo -e "${RED}✗ FAIL${NC}: Fichier mtime manquant ou vide"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: extract_and_cache_structure a échoué"
fi
cleanup_test

# Test 5: Gestion d'erreur fichier inexistant
echo -e "${BLUE}Test 5: Gestion d'erreur fichier inexistant${NC}"
setup_test
nonexistent_file="$TEST_DIR/nonexistent.md"
cache_file="$CACHE_DIR/test_cache.parsed"

extract_and_cache_structure "$nonexistent_file" "PBI" "$cache_file" 2>/dev/null
exit_code=$?

if [ $exit_code -eq 1 ]; then
    echo -e "${GREEN}✓ PASS${NC}: extract_and_cache_structure gère les fichiers inexistants"
else
    echo -e "${RED}✗ FAIL${NC}: extract_and_cache_structure devrait retourner 1 pour fichier inexistant"
fi
cleanup_test

echo "======================================================================="
echo -e "${GREEN}🎉 Phase GREEN terminée !${NC}"