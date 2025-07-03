#!/bin/bash

# Test d'intégration finale pour TASK-6-3
# Vérifier que le cache fonctionne avec le vrai script aklo

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Test d'intégration finale - Cache dans aklo${NC}"
echo "======================================================================="

# Test avec une vraie commande aklo
cd /Users/eplouvie/Projets/dotfiles

# Nettoyer le cache
rm -rf /tmp/aklo_cache
mkdir -p /tmp/aklo_cache

# Activer le debug cache
echo "CACHE_DEBUG=true" >> aklo/config/.aklo.conf

# Test 1: Générer un PBI avec cache miss
echo -e "${BLUE}Test 1: Génération PBI avec cache miss${NC}"
start_time=$(date +%s%N)
result=$(./aklo/bin/aklo propose-pbi "Test Cache Integration" 2>&1)
end_time=$(date +%s%N)
duration_miss=$((($end_time - $start_time) / 1000000))

if echo "$result" | grep -q "PBI créé"; then
    echo -e "${GREEN}✓ PASS${NC}: PBI généré avec succès"
    echo "  Durée (cache miss): ${duration_miss}ms"
    
    # Vérifier qu'un cache a été créé
    if ls /tmp/aklo_cache/protocol_*_PBI.parsed 1> /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}: Fichier cache créé"
    else
        echo -e "${RED}✗ FAIL${NC}: Aucun fichier cache créé"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Échec génération PBI"
fi

# Test 2: Générer un autre PBI avec cache hit
echo -e "${BLUE}Test 2: Génération PBI avec cache hit${NC}"
start_time=$(date +%s%N)
result=$(./aklo/bin/aklo propose-pbi "Test Cache Hit" 2>&1)
end_time=$(date +%s%N)
duration_hit=$((($end_time - $start_time) / 1000000))

if echo "$result" | grep -q "PBI créé"; then
    echo -e "${GREEN}✓ PASS${NC}: PBI généré avec succès"
    echo "  Durée (cache hit): ${duration_hit}ms"
    
    # Comparer les performances
    if [ $duration_hit -lt $duration_miss ]; then
        echo -e "${GREEN}✓ PASS${NC}: Cache hit plus rapide (gain: $((duration_miss - duration_hit))ms)"
    else
        echo -e "${RED}✗ FAIL${NC}: Cache hit pas plus rapide"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Échec génération PBI avec cache hit"
fi

# Test 3: Vérifier que les autres commandes fonctionnent toujours
echo -e "${BLUE}Test 3: Compatibilité avec autres commandes${NC}"
if ./aklo/bin/aklo status --brief >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Commande status fonctionne"
else
    echo -e "${RED}✗ FAIL${NC}: Commande status échoue"
fi

# Restaurer la config
sed -i '' '/^CACHE_DEBUG=true$/d' aklo/config/.aklo.conf

# Nettoyer les PBIs de test
rm -f docs/backlog/00-pbi/PBI-*-Test-Cache-*.md

echo "======================================================================="
echo -e "${GREEN}🎉 Tests d'intégration terminés !${NC}"