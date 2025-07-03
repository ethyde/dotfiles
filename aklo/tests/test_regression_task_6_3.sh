#!/bin/bash

# Test de régression pour TASK-6-3
# Vérifier que toutes les commandes aklo fonctionnent avec le cache

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Tests de Régression TASK-6-3 - Cache Integration${NC}"
echo "======================================================================="

cd /Users/eplouvie/Projets/dotfiles

# Nettoyer
rm -rf /tmp/aklo_cache
rm -f docs/backlog/00-pbi/PBI-*-Test-*.md
rm -f docs/backlog/01-tasks/TASK-*-Test-*.md

# Activer le cache debug
echo "CACHE_DEBUG=true" >> aklo/config/.aklo.conf

# Test 1: Commande status
echo -e "${BLUE}Test 1: aklo status${NC}"
if ./aklo/bin/aklo status --brief >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: aklo status fonctionne"
else
    echo -e "${RED}✗ FAIL${NC}: aklo status échoue"
fi

# Test 2: Création PBI
echo -e "${BLUE}Test 2: aklo propose-pbi${NC}"
if ./aklo/bin/aklo propose-pbi "Test Regression PBI" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: aklo propose-pbi fonctionne"
    
    # Vérifier le cache
    if ls /tmp/aklo_cache/protocol_*_PBI.parsed 1>/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}: Cache PBI créé"
    else
        echo -e "${RED}✗ FAIL${NC}: Cache PBI manquant"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: aklo propose-pbi échoue"
fi

# Test 3: Planification (utilise TASK)
echo -e "${BLUE}Test 3: aklo plan${NC}"
if ./aklo/bin/aklo plan 1 --no-agent >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: aklo plan fonctionne"
    
    # Vérifier le cache TASK
    if ls /tmp/aklo_cache/protocol_*_TASK.parsed 1>/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}: Cache TASK créé"
    else
        echo -e "${RED}✗ FAIL${NC}: Cache TASK manquant"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: aklo plan échoue"
fi

# Test 4: Debug (utilise DEBUG)
echo -e "${BLUE}Test 4: aklo debug${NC}"
if ./aklo/bin/aklo debug "Test regression debug" --no-agent >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: aklo debug fonctionne"
    
    # Vérifier le cache DEBUG
    if ls /tmp/aklo_cache/protocol_*_DEBUG.parsed 1>/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}: Cache DEBUG créé"
    else
        echo -e "${RED}✗ FAIL${NC}: Cache DEBUG manquant"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: aklo debug échoue"
fi

# Test 5: Architecture (utilise ARCH)
echo -e "${BLUE}Test 5: aklo arch${NC}"
if ./aklo/bin/aklo arch 1 --no-agent >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: aklo arch fonctionne"
    
    # Vérifier le cache ARCH
    if ls /tmp/aklo_cache/protocol_*_ARCH.parsed 1>/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}: Cache ARCH créé"
    else
        echo -e "${RED}✗ FAIL${NC}: Cache ARCH manquant"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: aklo arch échoue"
fi

# Test 6: Cache hit performance
echo -e "${BLUE}Test 6: Performance cache hit${NC}"
start_time=$(date +%s%N)
./aklo/bin/aklo propose-pbi "Test Cache Hit Performance" >/dev/null 2>&1
end_time=$(date +%s%N)
duration_hit=$((($end_time - $start_time) / 1000000))

echo "Durée cache hit: ${duration_hit}ms"
if [ $duration_hit -lt 1000 ]; then
    echo -e "${GREEN}✓ PASS${NC}: Cache hit performance acceptable (<1s)"
else
    echo -e "${RED}✗ FAIL${NC}: Cache hit trop lent (>1s)"
fi

# Test 7: Configuration cache disable
echo -e "${BLUE}Test 7: Configuration cache disable${NC}"
sed -i '' 's/CACHE_ENABLED=true/CACHE_ENABLED=false/' aklo/config/.aklo.conf
rm -rf /tmp/aklo_cache

if ./aklo/bin/aklo propose-pbi "Test Cache Disabled" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Fonctionne avec cache désactivé"
    
    # Vérifier qu'aucun cache n'est créé
    if [ ! -d "/tmp/aklo_cache" ] || [ -z "$(ls -A /tmp/aklo_cache 2>/dev/null)" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Aucun cache créé quand désactivé"
    else
        echo -e "${RED}✗ FAIL${NC}: Cache créé malgré désactivation"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Échoue avec cache désactivé"
fi

# Restaurer la configuration
sed -i '' 's/CACHE_ENABLED=false/CACHE_ENABLED=true/' aklo/config/.aklo.conf
sed -i '' '/^CACHE_DEBUG=true$/d' aklo/config/.aklo.conf

# Nettoyer les fichiers de test
rm -f docs/backlog/00-pbi/PBI-*-Test-*.md
rm -f docs/backlog/01-tasks/TASK-*-Test-*.md
rm -f docs/backlog/02-arch/ARCH-*-Test-*.md
rm -f docs/backlog/03-debug/DEBUG-*-Test-*.md
rm -rf /tmp/aklo_cache

echo "======================================================================="
echo -e "${GREEN}🎉 Tests de régression terminés !${NC}"