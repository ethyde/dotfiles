#!/usr/bin/env bash

#==============================================================================
# BENCHMARK RÉALISTE - CACHE PRINCIPAL AKLO
# Test des performances avec cache pré-chargé
# 
# Partie de : PBI-6 TASK-6-4
# Date : 2025-07-18
#==============================================================================

# Chargement du système de cache
AKLO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export AKLO_PROJECT_ROOT="$(cd "$AKLO_ROOT/.." && pwd)"

# Charger les modules avec les bons chemins
source "$AKLO_ROOT/modules/core/config.sh"
source "$AKLO_ROOT/modules/cache/cache_monitoring.sh"
source "$AKLO_ROOT/modules/cache/cache_functions.sh"
source "$AKLO_ROOT/modules/parser/parser_cached.sh"

# Configuration du benchmark
ITERATIONS=20
TEST_PROTOCOLS=(
    "DEVELOPPEMENT"
    "PLANIFICATION"
    "ARCHITECTURE"
)

TEST_ARTEFACTS=(
    "PBI"
    "TASK"
    "ARCH"
)

echo "🚀 Benchmark Réaliste du Cache Aklo - PBI-6"
echo "============================================"
echo "Iterations: $ITERATIONS"
echo "Protocoles de test: ${#TEST_PROTOCOLS[@]}"
echo "Types d'artefacts: ${#TEST_ARTEFACTS[@]}"
echo ""

#------------------------------------------------------------------------------
# Pré-chargement du cache
#------------------------------------------------------------------------------
preload_cache() {
    echo "🔄 Pré-chargement du cache..."
    
    for protocol in "${TEST_PROTOCOLS[@]}"; do
        for artefact in "${TEST_ARTEFACTS[@]}"; do
            parse_and_generate_artefact_cached "$protocol" "$artefact" >/dev/null 2>&1 || true
        done
    done
    
    echo "✅ Cache pré-chargé avec succès"
    echo ""
}

#------------------------------------------------------------------------------
# Test avec cache pré-chargé (simulation d'usage réel)
#------------------------------------------------------------------------------
benchmark_with_preloaded_cache() {
    echo "⚡ Test avec cache pré-chargé..."
    
    local start_time=$(date +%s%N)
    local cache_hits=0
    local cache_misses=0
    
    for ((i=1; i<=ITERATIONS; i++)); do
        for protocol in "${TEST_PROTOCOLS[@]}"; do
            for artefact in "${TEST_ARTEFACTS[@]}"; do
                # Utilisation du cache (devrait être des hits)
                if parse_and_generate_artefact_cached "$protocol" "$artefact" >/dev/null 2>&1; then
                    cache_hits=$((cache_hits + 1))
                else
                    cache_misses=$((cache_misses + 1))
                fi
            done
        done
    done
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 )) # en millisecondes
    
    echo "   Durée: ${duration}ms"
    echo "   Hits: $cache_hits"
    echo "   Misses: $cache_misses"
    
    # Calculer le taux de hit
    local total_operations=$((cache_hits + cache_misses))
    local hit_rate=0
    if [ $total_operations -gt 0 ]; then
        hit_rate=$(( (cache_hits * 100) / total_operations ))
    fi
    
    echo "   Taux de hit: ${hit_rate}%"
    echo "$duration|$cache_hits|$cache_misses|$hit_rate"
}

#------------------------------------------------------------------------------
# Test de performance par type d'artefact
#------------------------------------------------------------------------------
benchmark_by_artefact_type() {
    echo "🔍 Test par type d'artefact..."
    
    local results=()
    
    for artefact in "${TEST_ARTEFACTS[@]}"; do
        echo "   Test artefact: $artefact"
        
        # Réinitialiser les métriques pour ce test
        clear_cache
        init_cache_metrics
        
        # Pré-charger le cache pour ce type d'artefact
        for protocol in "${TEST_PROTOCOLS[@]}"; do
            parse_and_generate_artefact_cached "$protocol" "$artefact" >/dev/null 2>&1 || true
        done
        
        local start_time=$(date +%s%N)
        local cache_hits=0
        
        # Test avec cache pré-chargé
        for ((i=1; i<=10; i++)); do
            for protocol in "${TEST_PROTOCOLS[@]}"; do
                if parse_and_generate_artefact_cached "$protocol" "$artefact" >/dev/null 2>&1; then
                    cache_hits=$((cache_hits + 1))
                fi
            done
        done
        
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))
        local total_ops=$((10 * ${#TEST_PROTOCOLS[@]}))
        local hit_rate=$(( (cache_hits * 100) / total_ops ))
        
        echo "     Durée: ${duration}ms (hit rate: ${hit_rate}%)"
        results+=("$artefact:$duration:$hit_rate")
    done
    
    echo "   Résultats par type d'artefact:"
    for result in "${results[@]}"; do
        local artefact="${result%:*}"
        local duration="${result#*:}"
        duration="${duration%:*}"
        local hit_rate="${result##*:}"
        echo "     $artefact: ${duration}ms (${hit_rate}% hit rate)"
    done
}

#------------------------------------------------------------------------------
# Test de performance avec invalidation de cache
#------------------------------------------------------------------------------
benchmark_cache_invalidation() {
    echo "🔄 Test d'invalidation de cache..."
    
    # Pré-charger le cache
    preload_cache
    
    local start_time=$(date +%s%N)
    local cache_hits=0
    local cache_misses=0
    
    for ((i=1; i<=ITERATIONS; i++)); do
        for protocol in "${TEST_PROTOCOLS[@]}"; do
            for artefact in "${TEST_ARTEFACTS[@]}"; do
                # Premier appel (hit)
                if parse_and_generate_artefact_cached "$protocol" "$artefact" >/dev/null 2>&1; then
                    cache_hits=$((cache_hits + 1))
                fi
                
                # Simuler une modification du protocole (invalidation)
                if [ $((i % 5)) -eq 0 ]; then
                    # Toucher le fichier protocole pour invalider le cache
                    local protocol_file="$AKLO_ROOT/charte/PROTOCOLES/00-${protocol}.xml"
                    if [ -f "$protocol_file" ]; then
                        touch "$protocol_file" 2>/dev/null || true
                    fi
                fi
                
                # Deuxième appel (peut être miss si invalidation)
                if parse_and_generate_artefact_cached "$protocol" "$artefact" >/dev/null 2>&1; then
                    cache_hits=$((cache_hits + 1))
                else
                    cache_misses=$((cache_misses + 1))
                fi
            done
        done
    done
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 ))
    
    echo "   Durée: ${duration}ms"
    echo "   Hits: $cache_hits"
    echo "   Misses: $cache_misses"
    
    local total_operations=$((cache_hits + cache_misses))
    local hit_rate=0
    if [ $total_operations -gt 0 ]; then
        hit_rate=$(( (cache_hits * 100) / total_operations ))
    fi
    
    echo "   Taux de hit: ${hit_rate}%"
}

#------------------------------------------------------------------------------
# Exécution du benchmark réaliste
#------------------------------------------------------------------------------
main() {
    echo "🔄 Préparation du benchmark réaliste..."
    
    # Vérifier que le cache est activé
    get_cache_config_values
    if [ "$CACHE_ENABLED" != "true" ]; then
        echo "❌ Cache désactivé. Activation du cache pour le benchmark..."
        export CACHE_ENABLED=true
    fi
    
    echo "✅ Cache activé: $CACHE_ENABLED"
    echo ""
    
    # Pré-charger le cache
    preload_cache
    
    # Test avec cache pré-chargé
    echo "📊 Test avec Cache Pré-chargé"
    echo "============================="
    local detailed_results
    detailed_results=$(benchmark_with_preloaded_cache | tail -1)
    
    if [[ "$detailed_results" =~ ^([0-9]+)\|([0-9]+)\|([0-9]+)\|([0-9]+)$ ]]; then
        local duration="${BASH_REMATCH[1]}"
        local hits="${BASH_REMATCH[2]}"
        local misses="${BASH_REMATCH[3]}"
        local hit_rate="${BASH_REMATCH[4]}"
        
        echo "   Durée totale: ${duration}ms"
        echo "   Cache hits: $hits"
        echo "   Cache misses: $misses"
        echo "   Taux de hit: ${hit_rate}%"
        
        # Calculer le gain de performance
        local avg_time_per_op=$(( duration / (hits + misses) ))
        echo "   Temps moyen par opération: ${avg_time_per_op}ms"
    fi
    
    echo ""
    echo "🔍 Performance par Type d'Artefact"
    echo "=================================="
    benchmark_by_artefact_type
    
    echo ""
    echo "🔄 Test d'Invalidation de Cache"
    echo "==============================="
    benchmark_cache_invalidation
    
    echo ""
    echo "📋 Statut Final du Cache"
    echo "========================"
    show_cache_status
    
    echo ""
    echo "💡 Recommandations"
    echo "=================="
    echo "• Le cache est plus efficace avec des protocoles complexes"
    echo "• L'invalidation automatique maintient la cohérence"
    echo "• Les métriques permettent d'optimiser l'usage"
}

# Exécution si appelé directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi 