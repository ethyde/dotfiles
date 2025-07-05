#!/bin/bash

#==============================================================================
# BENCHMARK - CACHE REGEX SYSTEM
# Mesure des gains de performance du cache regex
# 
# Partie de : PBI-7 TASK-7-1
# Date : 2025-07-03
#==============================================================================

# Chargement du système de cache
source "$(dirname "$0")/../modules/cache/regex_cache.sh"

# Configuration du benchmark
ITERATIONS=100
TEST_FILES=(
    "PBI-1-PROPOSED.md"
    "PBI-7-AGREED.md"
    "PBI-42-DONE.md"
    "TASK-1-1-TODO.md"
    "TASK-7-1-IN_PROGRESS.md"
    "TASK-42-3-DONE.md"
    "ARCH-7-1.md"
    "DEBUG-test-20250703.md"
)

echo "🚀 Benchmark du Cache Regex - TASK-7-1"
echo "========================================"
echo "Iterations: $ITERATIONS"
echo "Fichiers de test: ${#TEST_FILES[@]}"
echo ""

#------------------------------------------------------------------------------
# Test sans cache (patterns inline)
#------------------------------------------------------------------------------
benchmark_without_cache() {
    echo "⏱️  Test sans cache (patterns inline)..."
    
    local start_time=$(date +%s%N)
    
    for ((i=1; i<=ITERATIONS; i++)); do
        for file in "${TEST_FILES[@]}"; do
            # Simulation des patterns inline (sans cache)
            echo "$file" | grep -oE "PBI-[0-9]+" >/dev/null 2>&1
            echo "$file" | grep -oE "TASK-[0-9]+-[0-9]+" >/dev/null 2>&1
            echo "$file" | grep -oE "ARCH-[0-9]+-[0-9]+" >/dev/null 2>&1
            echo "$file" | grep -oE "DEBUG-[a-zA-Z0-9-]+-[0-9]{8}" >/dev/null 2>&1
        done
    done
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 )) # en millisecondes
    
    echo "   Durée: ${duration}ms"
    echo "$duration"
}

#------------------------------------------------------------------------------
# Test avec cache
#------------------------------------------------------------------------------
benchmark_with_cache() {
    echo "⚡ Test avec cache regex..."
    
    # Initialiser le cache
    init_regex_cache
    
    local start_time=$(date +%s%N)
    
    for ((i=1; i<=ITERATIONS; i++)); do
        for file in "${TEST_FILES[@]}"; do
            # Utilisation des fonctions cachées
            extract_pbi_id "$file" >/dev/null 2>&1
            extract_task_id "$file" >/dev/null 2>&1
            
            # Test direct du cache pour ARCH et DEBUG
            local arch_pattern
            arch_pattern=$(get_cached_regex "ARCH_ID" 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo "$file" | grep -oE "$arch_pattern" >/dev/null 2>&1
            fi
            
            local debug_pattern
            debug_pattern=$(get_cached_regex "DEBUG_ID" 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo "$file" | grep -oE "$debug_pattern" >/dev/null 2>&1
            fi
        done
    done
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 )) # en millisecondes
    
    echo "   Durée: ${duration}ms"
    echo "$duration"
}

#------------------------------------------------------------------------------
# Exécution du benchmark
#------------------------------------------------------------------------------
main() {
    # Test sans cache
    local time_without_cache
    time_without_cache=$(benchmark_without_cache)
    
    echo ""
    
    # Test avec cache
    local time_with_cache
    time_with_cache=$(benchmark_with_cache)
    
    echo ""
    echo "📊 Résultats du Benchmark"
    echo "=========================="
    echo "Sans cache:  ${time_without_cache}ms"
    echo "Avec cache:  ${time_with_cache}ms"
    
    if [ "$time_without_cache" -gt 0 ] && [ "$time_with_cache" -gt 0 ]; then
        local improvement=$(( (time_without_cache - time_with_cache) * 100 / time_without_cache ))
        local speedup=$(( time_without_cache * 100 / time_with_cache ))
        
        echo ""
        if [ "$time_with_cache" -lt "$time_without_cache" ]; then
            echo "🚀 Amélioration: ${improvement}% plus rapide"
            echo "⚡ Speedup: ${speedup}% de la performance originale"
        else
            local regression=$(( (time_with_cache - time_without_cache) * 100 / time_without_cache ))
            echo "⚠️  Régression: ${regression}% plus lent (overhead du cache)"
        fi
    fi
    
    echo ""
    echo "📈 Statistiques du Cache"
    echo "========================"
    show_regex_cache_stats
}

# Exécution si appelé directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi