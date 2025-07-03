#!/bin/bash

# Tests unitaires pour la version avec cache (TASK-6-3)
# Phase GREEN - Tests fonctionnels

set -e

# Configuration
TEST_DIR="/tmp/aklo_test_parser"
CACHE_DIR="/tmp/aklo_cache"
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Source des fonctions avec cache
source "../modules/parser/parser_cached.sh"

# Fonction pour simuler apply_intelligent_filtering (nécessaire pour les tests)
apply_intelligent_filtering() {
    local content="$1"
    local assistance_level="$2"
    local context_vars="$3"
    
    # Simulation simple - retourner le contenu tel quel
    echo "$content"
}

echo -e "${BLUE}🧪 Tests Phase GREEN - Parser avec Cache${NC}"
echo "======================================================================="

# Setup
setup_test() {
    rm -rf "$TEST_DIR" "$CACHE_DIR"
    mkdir -p "$TEST_DIR" "$CACHE_DIR"
    mkdir -p "$TEST_DIR/aklo/charte/PROTOCOLES"
    
    # Créer un protocole de test
    cat > "$TEST_DIR/aklo/charte/PROTOCOLES/03-DEVELOPPEMENT.md" << 'EOF'
# PROTOCOLE DÉVELOPPEMENT

### 2.3. Structure Obligatoire Du Fichier PBI

```markdown
# PBI-{{ID}} : {{TITLE}}

## 1. Description
{{DESCRIPTION}}
```

## SECTION 3 - Fin
EOF

    # Créer configuration cache
    cat > "$TEST_DIR/.aklo.conf" << 'EOF'
CACHE_ENABLED=true
CACHE_DEBUG=true
EOF
}

cleanup_test() {
    rm -rf "$TEST_DIR" "$CACHE_DIR"
}

# Test 1: Cache miss - première utilisation
echo -e "${BLUE}Test 1: Cache miss - première utilisation${NC}"
setup_test
cd "$TEST_DIR"
export AKLO_CACHE_DEBUG=true

output_file="$TEST_DIR/test_output.md"
result=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "PBI" "full" "$output_file" "")
exit_code=$?

if [ $exit_code -eq 0 ] && [ -f "$output_file" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Génération avec cache miss réussie"
    
    # Vérifier que le cache a été créé
    cache_file="/tmp/aklo_cache/protocol_03-DEVELOPPEMENT_PBI.parsed"
    if [ -f "$cache_file" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Fichier cache créé"
    else
        echo -e "${RED}✗ FAIL${NC}: Fichier cache non créé"
    fi
    
    # Vérifier le contenu
    if grep -q "PBI-{{ID}} : {{TITLE}}" "$output_file"; then
        echo -e "${GREEN}✓ PASS${NC}: Contenu généré correct"
    else
        echo -e "${RED}✗ FAIL${NC}: Contenu généré incorrect"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Échec génération avec cache miss"
fi
cleanup_test

# Test 2: Cache hit - réutilisation
echo -e "${BLUE}Test 2: Cache hit - réutilisation${NC}"
setup_test
cd "$TEST_DIR"
export AKLO_CACHE_DEBUG=true

# Première génération pour créer le cache
output_file1="$TEST_DIR/test_output1.md"
parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "PBI" "full" "$output_file1" "" >/dev/null 2>&1

# Deuxième génération - devrait utiliser le cache
output_file2="$TEST_DIR/test_output2.md"
result=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "PBI" "full" "$output_file2" "" 2>&1)
exit_code=$?

if [ $exit_code -eq 0 ] && [ -f "$output_file2" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Génération avec cache hit réussie"
    
    # Vérifier que les contenus sont identiques
    if diff "$output_file1" "$output_file2" >/dev/null; then
        echo -e "${GREEN}✓ PASS${NC}: Contenus identiques (cache hit)"
    else
        echo -e "${RED}✗ FAIL${NC}: Contenus différents"
    fi
    
    # Vérifier les logs de cache hit
    if echo "$result" | grep -q "HIT"; then
        echo -e "${GREEN}✓ PASS${NC}: Log cache hit détecté"
    else
        echo -e "${RED}✗ FAIL${NC}: Log cache hit manquant"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Échec génération avec cache hit"
fi
cleanup_test

# Test 3: Cache désactivé
echo -e "${BLUE}Test 3: Cache désactivé${NC}"
setup_test
cd "$TEST_DIR"
export AKLO_CACHE_DEBUG=true

# Créer configuration avec cache désactivé
cat > "$TEST_DIR/.aklo.conf" << 'EOF'
CACHE_ENABLED=false
CACHE_DEBUG=true
EOF

output_file="$TEST_DIR/test_output.md"
result=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "PBI" "full" "$output_file" "" 2>&1)
exit_code=$?

if [ $exit_code -eq 0 ] && [ -f "$output_file" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Génération sans cache réussie"
    
    # Vérifier qu'aucun cache n'a été créé
    cache_file="/tmp/aklo_cache/protocol_03-DEVELOPPEMENT_PBI.parsed"
    if [ ! -f "$cache_file" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Aucun cache créé (désactivé)"
    else
        echo -e "${RED}✗ FAIL${NC}: Cache créé malgré désactivation"
    fi
    
    # Vérifier les logs de cache désactivé
    if echo "$result" | grep -q "DISABLED"; then
        echo -e "${GREEN}✓ PASS${NC}: Log cache désactivé détecté"
    else
        echo -e "${RED}✗ FAIL${NC}: Log cache désactivé manquant"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Échec génération sans cache"
fi
cleanup_test

# Test 4: Fallback en cas d'erreur cache
echo -e "${BLUE}Test 4: Fallback en cas d'erreur cache${NC}"
setup_test
cd "$TEST_DIR"
export AKLO_CACHE_ENABLED=true
export AKLO_CACHE_DEBUG=true

# Créer un répertoire cache en lecture seule pour simuler une erreur
mkdir -p "$CACHE_DIR"
chmod 444 "$CACHE_DIR"

output_file="$TEST_DIR/test_output.md"
result=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "PBI" "full" "$output_file" "" 2>&1)
exit_code=$?

# Restaurer les permissions pour cleanup
chmod 755 "$CACHE_DIR" 2>/dev/null || true

if [ $exit_code -eq 0 ] && [ -f "$output_file" ]; then
    echo -e "${GREEN}✓ PASS${NC}: Fallback fonctionne en cas d'erreur cache"
    
    # Vérifier le contenu
    if grep -q "PBI-{{ID}} : {{TITLE}}" "$output_file"; then
        echo -e "${GREEN}✓ PASS${NC}: Contenu généré correct via fallback"
    else
        echo -e "${RED}✗ FAIL${NC}: Contenu fallback incorrect"
    fi
    
    # Vérifier les logs de fallback
    if echo "$result" | grep -q "FALLBACK"; then
        echo -e "${GREEN}✓ PASS${NC}: Log fallback détecté"
    else
        echo -e "${RED}✗ FAIL${NC}: Log fallback manquant"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Échec du fallback"
fi
cleanup_test

echo "======================================================================="
echo -e "${GREEN}🎉 Phase GREEN terminée !${NC}"