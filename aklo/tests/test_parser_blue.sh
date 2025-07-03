#!/bin/bash

# Tests unitaires pour la phase BLUE (TASK-6-3)
# Refactorisation et optimisation

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Tests Phase BLUE - Refactorisation et Performance${NC}"
echo "======================================================================="

# Test des performances cache
echo -e "${BLUE}Test Performance: Cache vs No Cache${NC}"
cd /Users/eplouvie/Projets/dotfiles

# Nettoyer le cache
rm -rf /tmp/aklo_cache
mkdir -p /tmp/aklo_cache

# Test sans cache (première fois)
echo "CACHE_ENABLED=false" > aklo/config/.aklo.conf.tmp
mv aklo/config/.aklo.conf aklo/config/.aklo.conf.backup
mv aklo/config/.aklo.conf.tmp aklo/config/.aklo.conf

start_time=$(date +%s%N)
./aklo/bin/aklo propose-pbi "Test Performance No Cache" >/dev/null 2>&1
end_time=$(date +%s%N)
duration_no_cache=$((($end_time - $start_time) / 1000000))

# Restaurer config avec cache
mv aklo/config/.aklo.conf.backup aklo/config/.aklo.conf

# Test avec cache miss
start_time=$(date +%s%N)
./aklo/bin/aklo propose-pbi "Test Performance Cache Miss" >/dev/null 2>&1
end_time=$(date +%s%N)
duration_cache_miss=$((($end_time - $start_time) / 1000000))

# Test avec cache hit
start_time=$(date +%s%N)
./aklo/bin/aklo propose-pbi "Test Performance Cache Hit" >/dev/null 2>&1
end_time=$(date +%s%N)
duration_cache_hit=$((($end_time - $start_time) / 1000000))

echo "Résultats de performance:"
echo "  Sans cache:     ${duration_no_cache}ms"
echo "  Cache miss:     ${duration_cache_miss}ms"
echo "  Cache hit:      ${duration_cache_hit}ms"

# Vérifier les améliorations
if [ $duration_cache_hit -lt $duration_cache_miss ]; then
    gain_miss=$((duration_cache_miss - duration_cache_hit))
    echo -e "${GREEN}✓ PASS${NC}: Cache hit plus rapide que cache miss (gain: ${gain_miss}ms)"
else
    echo -e "${RED}✗ FAIL${NC}: Cache hit pas plus rapide que cache miss"
fi

if [ $duration_cache_hit -lt $duration_no_cache ]; then
    gain_no_cache=$((duration_no_cache - duration_cache_hit))
    echo -e "${GREEN}✓ PASS${NC}: Cache hit plus rapide que sans cache (gain: ${gain_no_cache}ms)"
else
    echo -e "${RED}✗ FAIL${NC}: Cache hit pas plus rapide que sans cache"
fi

# Test de robustesse
echo -e "${BLUE}Test Robustesse: Gestion des erreurs${NC}"

# Test avec protocole inexistant
if ./aklo/bin/aklo propose-pbi "Test Inexistant" --protocol="INEXISTANT" 2>/dev/null; then
    echo -e "${RED}✗ FAIL${NC}: Devrait échouer avec protocole inexistant"
else
    echo -e "${GREEN}✓ PASS${NC}: Gestion erreur protocole inexistant"
fi

# Test avec cache corrompu
echo "CACHE_CORRUPTED" > /tmp/aklo_cache/protocol_00-PRODUCT-OWNER_PBI.parsed
if ./aklo/bin/aklo propose-pbi "Test Cache Corrompu" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Fallback fonctionne avec cache corrompu"
else
    echo -e "${RED}✗ FAIL${NC}: Fallback échoue avec cache corrompu"
fi

# Nettoyer les fichiers de test
rm -f docs/backlog/00-pbi/PBI-*-Test-*.md
rm -rf /tmp/aklo_cache

echo "======================================================================="
echo -e "${GREEN}🎉 Phase BLUE terminée !${NC}"