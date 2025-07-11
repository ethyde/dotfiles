#!/usr/bin/env bash
#==============================================================================
# Système de configuration tuning et gestion mémoire (V2 - Centralisé)
#==============================================================================

# --- Fonctions principales (la logique de tuning ne change pas) ---
# apply_performance_profile, auto_tune_performance, etc. restent identiques...
# ...

# --- DIAGNOSTIC MÉMOIRE (CORRIGÉ) ---
get_memory_diagnostics() {
    # On récupère les valeurs de configuration via la fonction centrale
    local PERF_CACHE_MAX_SIZE_MB=$(get_config "max_size_mb" "cache" "100")
    local PERF_MEMORY_LIMIT_MB=$(get_config "memory_limit_mb" "performance" "500")
    local PERF_CLEANUP_INTERVAL_MINUTES=$(get_config "cleanup_interval_minutes" "performance" "30")
    local PERF_MONITORING_LEVEL=$(get_config "monitoring_level" "performance" "normal")
    
    # On récupère le chemin du cache de la même manière
    local cache_dir=$(get_config "cache_dir" "cache" ".aklo_cache")
    if [[ "$cache_dir" != /* ]]; then
        cache_dir="${AKLO_PROJECT_ROOT}/${cache_dir}"
    fi

    echo "🔍 DIAGNOSTIC MÉMOIRE AKLO"
    echo "=========================="
    echo ""
    
    echo "📋 Configuration Performance:"
    echo "   Cache Max Size: ${PERF_CACHE_MAX_SIZE_MB}MB"
    echo "   Memory Limit: ${PERF_MEMORY_LIMIT_MB}MB"
    echo "   Cleanup Interval: ${PERF_CLEANUP_INTERVAL_MINUTES}min"
    echo "   Monitoring Level: ${PERF_MONITORING_LEVEL}"
    # ... (le reste de la fonction d'affichage reste identique) ...

    echo ""
    echo "📊 Cache Usage:"
    if [[ -d "$cache_dir" ]]; then
        # ... la logique qui utilise $cache_dir reste la même ...
        local total_size_kb=$(du -sk "$cache_dir" 2>/dev/null | cut -f1)
        local total_size_mb=$((total_size_kb / 1024))
        # ... etc
    else
        echo "   Aucun cache trouvé dans: $cache_dir"
    fi
    
    echo ""
    echo "💡 Recommandations:"
    # ...
}

# Vérification des limites de taille pour un cache spécifique
check_cache_size_limit() {
    local cache_type="$1"
    local cache_dir="${AKLO_CACHE_DIR:-$HOME/.aklo/cache}"
    local cache_path="$cache_dir/$cache_type"
    
    [[ ! -d "$cache_path" ]] && return 0
    
    local size_kb=$(du -sk "$cache_path" 2>/dev/null | cut -f1)
    local size_mb=$((size_kb / 1024))
    local limit_mb=$((PERF_CACHE_MAX_SIZE_MB / 3)) # 1/3 de la limite totale par cache
    
    if [[ "$size_mb" -gt "$limit_mb" ]]; then
        return 1
    fi
    
    return 0
}

# Reset vers les valeurs par défaut
reset_to_defaults() {
    PERF_CACHE_MAX_SIZE_MB=100
    PERF_CACHE_TTL_HOURS=24
    PERF_AUTO_TUNE_ENABLED=true
    PERF_ENVIRONMENT=auto
    PERF_MEMORY_LIMIT_MB=500
    PERF_CLEANUP_INTERVAL_MINUTES=30
    PERF_MONITORING_LEVEL=normal
}

# Initialisation automatique si pas en mode test
# CORRECTION : On commente ou supprime cette ligne.
# Le module ne doit rien exécuter de lui-même.
# Les fonctions seront appelées par les commandes qui en ont besoin.
#
# if [[ -z "$AKLO_TEST_MODE" ]]; then
#     load_performance_config
# fi