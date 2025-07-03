#!/bin/bash

# Tests unitaires pour TASK-6-4 - Phase BLUE
# Tests de performance et robustesse

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Tests Phase BLUE - Performance et Robustesse Cache${NC}"
echo "======================================================================="

cd /Users/eplouvie/Projets/dotfiles

# Test 1: Performance complète du système cache
echo -e "${BLUE}Test 1: Performance complète du système cache${NC}"
./aklo/bin/aklo cache clear >/dev/null 2>&1

# Mesurer les performances sur plusieurs générations
echo "📊 Test de performance sur 3 générations PBI..."

total_miss_time=0
total_hit_time=0
hit_count=0

for i in 1 2 3; do
    # Test cache miss (première fois pour chaque protocole)
    start_time=$(date +%s%N)
    ./aklo/bin/aklo propose-pbi "Test Performance $i" >/dev/null 2>&1
    end_time=$(date +%s%N)
    miss_time=$((($end_time - $start_time) / 1000000))
    total_miss_time=$((total_miss_time + miss_time))
    
    # Test cache hit (deuxième fois)
    start_time=$(date +%s%N)
    ./aklo/bin/aklo propose-pbi "Test Performance Hit $i" >/dev/null 2>&1
    end_time=$(date +%s%N)
    hit_time=$((($end_time - $start_time) / 1000000))
    total_hit_time=$((total_hit_time + hit_time))
    hit_count=$((hit_count + 1))
done

avg_miss_time=$((total_miss_time / 3))
avg_hit_time=$((total_hit_time / hit_count))
performance_gain=$((avg_miss_time - avg_hit_time))
performance_percent=0
if [ $avg_miss_time -gt 0 ]; then
    performance_percent=$((performance_gain * 100 / avg_miss_time))
fi

echo "Résultats performance:"
echo "  Temps moyen cache miss: ${avg_miss_time}ms"
echo "  Temps moyen cache hit:  ${avg_hit_time}ms"
echo "  Gain moyen:             ${performance_gain}ms (${performance_percent}%)"

if [ $performance_gain -gt 0 ]; then
    echo -e "${GREEN}✓ PASS${NC}: Performance cache positive"
else
    echo -e "${RED}✗ FAIL${NC}: Pas de gain de performance"
fi

# Test 2: Métriques complètes
echo -e "${BLUE}Test 2: Métriques complètes${NC}"
status_output=$(./aklo/bin/aklo cache status 2>&1)

if echo "$status_output" | grep -q "Total requêtes: [1-9]"; then
    echo -e "${GREEN}✓ PASS${NC}: Métriques collectées"
else
    echo -e "${RED}✗ FAIL${NC}: Métriques non collectées"
fi

if echo "$status_output" | grep -q "Hits:.*([0-9]*%)"; then
    echo -e "${GREEN}✓ PASS${NC}: Ratio hit/miss calculé"
else
    echo -e "${RED}✗ FAIL${NC}: Ratio hit/miss manquant"
fi

# Test 3: Robustesse avec cache corrompu
echo -e "${BLUE}Test 3: Robustesse avec cache corrompu${NC}"
echo "CORRUPTED_DATA" > /tmp/aklo_cache/protocol_00-PRODUCT-OWNER_PBI.parsed

if ./aklo/bin/aklo propose-pbi "Test Cache Corrompu" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Fallback fonctionne avec cache corrompu"
else
    echo -e "${RED}✗ FAIL${NC}: Échec avec cache corrompu"
fi

# Test 4: Gestion des erreurs de permissions
echo -e "${BLUE}Test 4: Gestion des erreurs de permissions${NC}"
# Créer un répertoire cache en lecture seule
sudo mkdir -p /tmp/aklo_cache_readonly 2>/dev/null || mkdir -p /tmp/aklo_cache_readonly
sudo chmod 444 /tmp/aklo_cache_readonly 2>/dev/null || chmod 444 /tmp/aklo_cache_readonly

# Temporairement changer le répertoire cache
export CACHE_DIR="/tmp/aklo_cache_readonly"

if ./aklo/bin/aklo propose-pbi "Test Permissions" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Gestion erreurs permissions OK"
else
    echo -e "${RED}✗ FAIL${NC}: Échec gestion erreurs permissions"
fi

# Restaurer permissions
sudo chmod 755 /tmp/aklo_cache_readonly 2>/dev/null || chmod 755 /tmp/aklo_cache_readonly
rm -rf /tmp/aklo_cache_readonly 2>/dev/null || true
unset CACHE_DIR

# Test 5: Configuration avancée
echo -e "${BLUE}Test 5: Configuration avancée${NC}"
# Tester avec cache désactivé
echo "CACHE_ENABLED=false" >> aklo/config/.aklo.conf

if ./aklo/bin/aklo propose-pbi "Test Cache Disabled" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Fonctionne avec cache désactivé"
    
    # Vérifier qu'aucun nouveau cache n'est créé
    cache_files_before=$(find /tmp/aklo_cache -name "*.parsed" 2>/dev/null | wc -l || echo 0)
    ./aklo/bin/aklo propose-pbi "Test No Cache Creation" >/dev/null 2>&1
    cache_files_after=$(find /tmp/aklo_cache -name "*.parsed" 2>/dev/null | wc -l || echo 0)
    
    if [ "$cache_files_before" -eq "$cache_files_after" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Aucun nouveau cache créé quand désactivé"
    else
        echo -e "${RED}✗ FAIL${NC}: Cache créé malgré désactivation"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Échec avec cache désactivé"
fi

# Restaurer la configuration
sed -i '' '/^CACHE_ENABLED=false$/d' aklo/config/.aklo.conf

# Test 6: Benchmark complet
echo -e "${BLUE}Test 6: Benchmark complet${NC}"
benchmark_output=$(./aklo/bin/aklo cache benchmark 2>&1)

if echo "$benchmark_output" | grep -q "Cache miss:.*ms"; then
    echo -e "${GREEN}✓ PASS${NC}: Benchmark cache miss mesuré"
else
    echo -e "${RED}✗ FAIL${NC}: Benchmark cache miss manquant"
fi

if echo "$benchmark_output" | grep -q "Cache hit:.*ms"; then
    echo -e "${GREEN}✓ PASS${NC}: Benchmark cache hit mesuré"
else
    echo -e "${RED}✗ FAIL${NC}: Benchmark cache hit manquant"
fi

if echo "$benchmark_output" | grep -q "Gain:.*ms.*%"; then
    echo -e "${GREEN}✓ PASS${NC}: Calcul de gain correct"
else
    echo -e "${RED}✗ FAIL${NC}: Calcul de gain manquant"
fi

# Nettoyer les fichiers de test
rm -f docs/backlog/00-pbi/PBI-*-Test-*.md
./aklo/bin/aklo cache clear >/dev/null 2>&1

echo "======================================================================="
echo -e "${GREEN}🎉 Phase BLUE terminée !${NC}"