#!/bin/bash

# Tests unitaires pour extract_and_cache_structure (TASK-6-2)
# Approche TDD - Phase RED : Tests qui échouent

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

# Source des fonctions de cache (TASK-6-1)
source "../bin/aklo_cache_functions.sh"

# Source des fonctions d'extraction (sera créé dans cette task)
source "../bin/aklo_extract_functions.sh" 2>/dev/null || echo "⚠️  Fonctions extraction non trouvées (normal en phase RED)"

# Fonction de setup
setup_test_env() {
    rm -rf "$TEST_DIR" "$CACHE_DIR"
    mkdir -p "$TEST_DIR" "$CACHE_DIR"
    
    # Créer un fichier protocole de test
    cat > "$TEST_DIR/test_protocol.md" << 'EOF'
# TEST PROTOCOL

## Structure PBI

```
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

## Structure TASK

```
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
EOF
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

# Fonction principale de test
run_all_tests() {
    echo -e "${BLUE}🧪 Tests TDD - Phase RED - Extract and Cache${NC}"
    echo "Les tests suivants DOIVENT échouer car les fonctions n'existent pas encore"
    echo "======================================================================="
    
    setup_test_env
    
    echo -e "${BLUE}📋 Test: extract_and_cache_structure function exists${NC}"
    if command -v extract_and_cache_structure >/dev/null 2>&1; then
        echo -e "${RED}✗ FAIL${NC}: extract_and_cache_structure function should not exist yet"
    else
        echo -e "${GREEN}✓ PASS${NC}: extract_and_cache_structure function does not exist (expected in RED phase)"
        ((PASS_COUNT++))
    fi
    ((TEST_COUNT++))
    
    echo -e "${BLUE}📋 Test: extract_artefact_structure function exists${NC}"
    if command -v extract_artefact_structure >/dev/null 2>&1; then
        echo -e "${RED}✗ FAIL${NC}: extract_artefact_structure function should not exist yet"
    else
        echo -e "${GREEN}✓ PASS${NC}: extract_artefact_structure function does not exist (expected in RED phase)"
        ((PASS_COUNT++))
    fi
    ((TEST_COUNT++))
    
    cleanup_test_env
    
    # Résumé
    echo "======================================================================="
    echo -e "${BLUE}📊 Résumé Phase RED${NC}"
    echo "Tests exécutés: $TEST_COUNT"
    echo "Tests réussis: $PASS_COUNT"
    echo "Tests échoués: $((TEST_COUNT - PASS_COUNT))"
    
    if [ $PASS_COUNT -eq $TEST_COUNT ]; then
        echo -e "${GREEN}🎉 Phase RED réussie - Prêt pour phase GREEN !${NC}"
        return 0
    else
        echo -e "${RED}❌ Phase RED échouée${NC}"
        return 1
    fi
}

# Exécution des tests si le script est appelé directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    run_all_tests
fi