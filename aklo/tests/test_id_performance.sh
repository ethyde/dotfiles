#!/bin/bash

# Tests de performance pour le cache des IDs de get_next_id
# TASK-7-3: Mesure de l'amélioration des performances

# Source des fonctions
script_dir="$(dirname "$0")"
source "${script_dir}/../modules/cache/cache_functions.sh"
source "${script_dir}/../modules/cache/id_cache.sh"

# Couleurs pour les tests
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration des tests
TEST_DIR="/tmp/aklo_id_perf_test"
NUM_ARTEFACTS=100

# Fonction get_next_id originale pour comparaison
get_next_id_original() {
    local search_path="$1"
    local prefix="$2"
    local last_id
    last_id=$(ls "${search_path}/${prefix}"*-*.md 2>/dev/null | sed -n "s/.*${prefix}-\([0-9]*\)-.*/\1/p" | sort -n | tail -1)
    if [ -z "$last_id" ]; then
        last_id=0
    fi
    local next_id=$((last_id + 1))
    echo "$next_id"
}

# Setup des fichiers de test
setup_performance_test() {
    echo "🔧 Configuration des tests de performance..."
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    
    # Créer de nombreux artefacts pour tester les performances
    for i in $(seq 1 $NUM_ARTEFACTS); do
        touch "$TEST_DIR/PBI-$i-DONE.md"
        touch "$TEST_DIR/TASK-$i-TODO.md"
        touch "$TEST_DIR/DEBUG-$i-INVESTIGATING.md"
    done
    
    echo "✓ $NUM_ARTEFACTS artefacts de chaque type créés dans $TEST_DIR"
}

# Nettoyage
cleanup_performance_test() {
    rm -rf "$TEST_DIR"
}

# Test de performance: get_next_id original vs cached
test_get_next_id_performance() {
    echo -e "${BLUE}=== Test de performance: get_next_id original vs cached ===${NC}"
    
    local prefixes=("PBI" "TASK" "DEBUG")
    local num_calls=20
    
    for prefix in "${prefixes[@]}"; do
        echo "📊 Test avec préfixe: $prefix"
        
        # Test méthode originale
        echo "  Méthode originale (sans cache):"
        local start_time=$(date +%s%N)
        for i in $(seq 1 $num_calls); do
            get_next_id_original "$TEST_DIR" "$prefix" >/dev/null
        done
        local end_time=$(date +%s%N)
        local original_duration=$(( (end_time - start_time) / 1000000 )) # en ms
        
        echo "    ⏱️  Durée totale: ${original_duration}ms"
        echo "    📊 Durée moyenne: $((original_duration / num_calls))ms par appel"
        
        # Reset cache pour test équitable
        reset_id_cache_metrics
        
        # Test méthode avec cache
        echo "  Méthode avec cache:"
        start_time=$(date +%s%N)
        for i in $(seq 1 $num_calls); do
            get_next_id_cached "$TEST_DIR" "$prefix" >/dev/null
        done
        end_time=$(date +%s%N)
        local cached_duration=$(( (end_time - start_time) / 1000000 )) # en ms
        
        echo "    ⏱️  Durée totale: ${cached_duration}ms"
        echo "    📊 Durée moyenne: $((cached_duration / num_calls))ms par appel"
        
        # Afficher les métriques du cache
        local metrics=$(get_id_cache_metrics)
        echo "    📈 $metrics"
        
        # Calcul de l'amélioration
        if [ $original_duration -gt 0 ] && [ $cached_duration -gt 0 ]; then
            local improvement=$(( (original_duration - cached_duration) * 100 / original_duration ))
            if [ $improvement -ge 50 ]; then
                echo -e "    ${GREEN}✓ Amélioration: ${improvement}% (objectif 50-70% atteint)${NC}"
            elif [ $improvement -ge 0 ]; then
                echo -e "    ${YELLOW}⚠ Amélioration: ${improvement}% (en dessous de l'objectif 50-70%)${NC}"
            else
                echo -e "    ${RED}✗ Dégradation: ${improvement}%${NC}"
            fi
        fi
        
        echo
    done
}

# Test de performance avec répertoires de tailles différentes
test_scalability() {
    echo -e "${BLUE}=== Test de scalabilité ===${NC}"
    
    local sizes=(10 50 100 500)
    
    for size in "${sizes[@]}"; do
        echo "📊 Test avec $size artefacts:"
        
        # Créer un répertoire de test spécifique
        local test_dir="/tmp/aklo_scale_test_$size"
        rm -rf "$test_dir"
        mkdir -p "$test_dir"
        
        # Créer les artefacts
        for i in $(seq 1 $size); do
            touch "$test_dir/PBI-$i-DONE.md"
        done
        
        # Test méthode originale
        local start_time=$(date +%s%N)
        get_next_id_original "$test_dir" "PBI" >/dev/null
        local end_time=$(date +%s%N)
        local original_time=$(( (end_time - start_time) / 1000000 )) # en ms
        
        # Test méthode avec cache (premier appel)
        start_time=$(date +%s%N)
        get_next_id_cached "$test_dir" "PBI" >/dev/null
        end_time=$(date +%s%N)
        local cached_first_time=$(( (end_time - start_time) / 1000000 )) # en ms
        
        # Test méthode avec cache (deuxième appel - hit)
        start_time=$(date +%s%N)
        get_next_id_cached "$test_dir" "PBI" >/dev/null
        end_time=$(date +%s%N)
        local cached_second_time=$(( (end_time - start_time) / 1000000 )) # en ms
        
        echo "  Original: ${original_time}ms"
        echo "  Cache (miss): ${cached_first_time}ms"
        echo "  Cache (hit): ${cached_second_time}ms"
        
        if [ $cached_second_time -lt $original_time ]; then
            local improvement=$(( (original_time - cached_second_time) * 100 / original_time ))
            echo -e "  ${GREEN}Amélioration cache hit: ${improvement}%${NC}"
        fi
        
        # Nettoyage
        rm -rf "$test_dir"
        echo
    done
}

# Test de cache hit/miss ratio
test_cache_efficiency() {
    echo -e "${BLUE}=== Test d'efficacité du cache ===${NC}"
    
    # Reset des métriques
    reset_id_cache_metrics
    
    # Série d'appels avec répétitions
    local prefixes=("PBI" "TASK" "DEBUG")
    local calls_per_prefix=5
    
    echo "📊 Simulation d'utilisation réaliste:"
    for prefix in "${prefixes[@]}"; do
        echo "  Appels répétitifs pour $prefix..."
        for i in $(seq 1 $calls_per_prefix); do
            get_next_id_cached "$TEST_DIR" "$prefix" >/dev/null
        done
    done
    
    # Afficher les métriques finales
    local final_metrics=$(get_id_cache_metrics)
    echo "📈 Métriques finales: $final_metrics"
    
    # Extraire hits et misses
    local hits=$(echo "$final_metrics" | sed -n 's/.*Hits: \([0-9]*\).*/\1/p')
    local misses=$(echo "$final_metrics" | sed -n 's/.*Misses: \([0-9]*\).*/\1/p')
    local total=$((hits + misses))
    
    if [ $total -gt 0 ]; then
        local hit_ratio=$(( hits * 100 / total ))
        echo "📊 Taux de hit du cache: ${hit_ratio}%"
        
        if [ $hit_ratio -ge 60 ]; then
            echo -e "${GREEN}✓ Excellent taux de hit (≥60%)${NC}"
        elif [ $hit_ratio -ge 40 ]; then
            echo -e "${YELLOW}⚠ Bon taux de hit (40-59%)${NC}"
        else
            echo -e "${RED}✗ Faible taux de hit (<40%)${NC}"
        fi
    fi
    
    echo
}

# Exécution des tests
main() {
    echo -e "${BLUE}🚀 Tests de performance - Cache des IDs get_next_id${NC}"
    echo "Nombre d'artefacts de test: $NUM_ARTEFACTS"
    echo
    
    setup_performance_test
    
    test_get_next_id_performance
    test_scalability
    test_cache_efficiency
    
    cleanup_performance_test
    
    echo -e "${GREEN}✅ Tests de performance terminés${NC}"
}

# Lancer les tests si le script est exécuté directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi