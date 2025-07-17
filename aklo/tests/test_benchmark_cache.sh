#!/usr/bin/env bash

#==============================================================================
# BENCHMARK - CACHE PRINCIPAL AKLO
# Mesure des gains de performance du cache des structures de protocoles
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
ITERATIONS=50
TEST_PROTOCOLS=(
    "DEVELOPPEMENT"
    "PLANIFICATION"
    "ARCHITECTURE"
    "REVUE-DE-CODE"
    "OPTIMISATION"
)

TEST_ARTEFACTS=(
    "PBI"
    "TASK"
    "ARCH"
    "DEBUG"
)

echo "🚀 Benchmark du Cache Principal Aklo - PBI-6"
echo "============================================="
echo "Iterations: $ITERATIONS"
echo "Protocoles de test: ${#TEST_PROTOCOLS[@]}"
echo "Types d'artefacts: ${#TEST_ARTEFACTS[@]}"
echo ""

#------------------------------------------------------------------------------
# Test sans cache (extraction directe)
#------------------------------------------------------------------------------
benchmark_without_cache() {
    echo "⏱️  Test sans cache (extraction directe)..."
    
    local start_time=$(date +%s%N)
    
    for ((i=1; i<=ITERATIONS; i++)); do
        for protocol in "${TEST_PROTOCOLS[@]}"; do
            for artefact in "${TEST_ARTEFACTS[@]}"; do
                # Simulation d'extraction directe sans cache
                local protocol_file="$AKLO_ROOT/charte/PROTOCOLES/00-${protocol}.xml"
                if [ -f "$protocol_file" ]; then
                    # Extraction XML directe (sans cache)
                    grep -A 20 "<${artefact}_STRUCTURE>" "$protocol_file" >/dev/null 2>&1 || true
                    grep -A 10 "<${artefact}_METADATA>" "$protocol_file" >/dev/null 2>&1 || true
                    grep -A 15 "<${artefact}_CONTENT>" "$protocol_file" >/dev/null 2>&1 || true
                fi
            done
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
    echo "⚡ Test avec cache principal..."
    
    # Initialiser le cache
    init_cache_metrics
    
    local start_time=$(date +%s%N)
    
    for ((i=1; i<=ITERATIONS; i++)); do
        for protocol in "${TEST_PROTOCOLS[@]}"; do
            for artefact in "${TEST_ARTEFACTS[@]}"; do
                # Utilisation du cache principal
                parse_and_generate_artefact_cached "$protocol" "$artefact" >/dev/null 2>&1 || true
            done
        done
    done
    
    local end_time=$(date +%s%N)
    local duration=$(( (end_time - start_time) / 1000000 )) # en millisecondes
    
    echo "   Durée: ${duration}ms"
    echo "$duration"
}

#------------------------------------------------------------------------------
# Test de performance du cache avec métriques détaillées
#------------------------------------------------------------------------------
benchmark_detailed_metrics() {
    echo "📊 Test avec métriques détaillées..."
    
    # Réinitialiser les métriques
    clear_cache
    init_cache_metrics
    
    local start_time=$(date +%s%N)
    local cache_hits=0
    local cache_misses=0
    
    for ((i=1; i<=ITERATIONS; i++)); do
        for protocol in "${TEST_PROTOCOLS[@]}"; do
            for artefact in "${TEST_ARTEFACTS[@]}"; do
                # Premier appel (miss)
                if parse_and_generate_artefact_cached "$protocol" "$artefact" >/dev/null 2>&1; then
                    cache_misses=$((cache_misses + 1))
                fi
                
                # Deuxième appel (hit)
                if parse_and_generate_artefact_cached "$protocol" "$artefact" >/dev/null 2>&1; then
                    cache_hits=$((cache_hits + 1))
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
# Test de performance avec différents types de protocoles
#------------------------------------------------------------------------------
benchmark_protocol_types() {
    echo "🔍 Test par type de protocole..."
    
    local results=()
    
    for protocol in "${TEST_PROTOCOLS[@]}"; do
        echo "   Test protocole: $protocol"
        
        # Réinitialiser le cache pour chaque protocole
        clear_cache
        init_cache_metrics
        
        local start_time=$(date +%s%N)
        
        for ((i=1; i<=10; i++)); do
            for artefact in "${TEST_ARTEFACTS[@]}"; do
                parse_and_generate_artefact_cached "$protocol" "$artefact" >/dev/null 2>&1 || true
            done
        done
        
        local end_time=$(date +%s%N)
        local duration=$(( (end_time - start_time) / 1000000 ))
        
        echo "     Durée: ${duration}ms"
        results+=("$protocol:$duration")
    done
    
    echo "   Résultats par protocole:"
    for result in "${results[@]}"; do
        local protocol="${result%:*}"
        local duration="${result#*:}"
        echo "     $protocol: ${duration}ms"
    done
}

#------------------------------------------------------------------------------
# Exécution du benchmark principal
#------------------------------------------------------------------------------
main() {
    echo "🔄 Préparation du benchmark..."
    
    # Vérifier que le cache est activé
    get_cache_config_values
    if [ "$CACHE_ENABLED" != "true" ]; then
        echo "❌ Cache désactivé. Activation du cache pour le benchmark..."
        # Activer temporairement le cache
        export CACHE_ENABLED=true
    fi
    
    echo "✅ Cache activé: $CACHE_ENABLED"
    echo ""
    
    # Test sans cache
    local time_without_cache
    time_without_cache=$(benchmark_without_cache | tail -1)
    
    echo ""
    
    # Test avec cache
    local time_with_cache
    time_with_cache=$(benchmark_with_cache | tail -1)
    
    echo ""
    echo "📊 Résultats du Benchmark Principal"
    echo "==================================="
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
    echo "📈 Métriques Détaillées"
    echo "======================="
    local detailed_results
    detailed_results=$(benchmark_detailed_metrics | tail -1)
    
    if [[ "$detailed_results" =~ ^([0-9]+)\|([0-9]+)\|([0-9]+)\|([0-9]+)$ ]]; then
        local duration="${BASH_REMATCH[1]}"
        local hits="${BASH_REMATCH[2]}"
        local misses="${BASH_REMATCH[3]}"
        local hit_rate="${BASH_REMATCH[4]}"
        
        echo "   Durée totale: ${duration}ms"
        echo "   Cache hits: $hits"
        echo "   Cache misses: $misses"
        echo "   Taux de hit: ${hit_rate}%"
    else
        echo "   ⚠️  Impossible de parser les métriques détaillées"
    fi
    
    echo ""
    echo "🔍 Performance par Protocole"
    echo "============================"
    benchmark_protocol_types
    
    echo ""
    echo "📋 Statut du Cache"
    echo "=================="
    show_cache_status
}

# Exécution si appelé directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi 