#!/bin/bash

# Tests unitaires pour l'intégration cache dans parse_and_generate_artefact (TASK-6-3)
# Approche TDD - Phase RED : Tests qui échouent

set -e

# Configuration des tests
TEST_DIR="/tmp/aklo_test_parser"
CACHE_DIR="/tmp/aklo_cache"
TEST_COUNT=0
PASS_COUNT=0

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Source des fonctions de cache et extraction
source "../bin/aklo_cache_functions.sh"
source "../bin/aklo_extract_functions.sh"

# Source de la fonction parser originale (sera modifiée dans cette task)
source "../bin/aklo" 2>/dev/null || echo "⚠️  Script aklo non sourcé (normal en phase RED)"

# Fonction de setup
setup_test_env() {
    rm -rf "$TEST_DIR" "$CACHE_DIR"
    mkdir -p "$TEST_DIR" "$CACHE_DIR"
    mkdir -p "$TEST_DIR/aklo/charte/PROTOCOLES"
    
    # Créer un protocole de test réaliste
    cat > "$TEST_DIR/aklo/charte/PROTOCOLES/03-DEVELOPPEMENT.md" << 'EOF'
# PROTOCOLE DÉVELOPPEMENT

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

## SECTION 3 - Fin

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
    echo -e "${BLUE}🧪 Tests TDD - Phase RED - Intégration Cache Parser${NC}"
    echo "Les tests suivants DOIVENT échouer car l'intégration cache n'existe pas encore"
    echo "======================================================================="
    
    setup_test_env
    
    # Test 1: Vérifier que la fonction parse_and_generate_artefact existe
    echo -e "${BLUE}📋 Test: parse_and_generate_artefact function exists${NC}"
    if command -v parse_and_generate_artefact >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}: parse_and_generate_artefact function exists"
        ((PASS_COUNT++))
    else
        echo -e "${RED}✗ FAIL${NC}: parse_and_generate_artefact function should exist"
    fi
    ((TEST_COUNT++))
    
    # Test 2: Vérifier que le cache n'est PAS encore intégré (phase RED)
    echo -e "${BLUE}📋 Test: Cache integration not yet implemented${NC}"
    cd "$TEST_DIR"
    output_file="$TEST_DIR/test_output.md"
    
    # Exécuter la fonction actuelle
    if parse_and_generate_artefact "03-DEVELOPPEMENT" "PBI" "full" "$output_file" ""; then
        # Vérifier qu'aucun fichier cache n'a été créé (car pas encore intégré)
        cache_file="/tmp/aklo_cache/protocol_03-DEVELOPPEMENT_PBI.parsed"
        if [ ! -f "$cache_file" ]; then
            echo -e "${GREEN}✓ PASS${NC}: Cache not yet integrated (expected in RED phase)"
            ((PASS_COUNT++))
        else
            echo -e "${RED}✗ FAIL${NC}: Cache should not be integrated yet"
        fi
    else
        echo -e "${RED}✗ FAIL${NC}: parse_and_generate_artefact should work without cache"
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