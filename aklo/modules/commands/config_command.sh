#!/usr/bin/env bash
#==============================================================================
# AKLO CONFIG COMMAND MODULE
#==============================================================================

cmd_config() {
    local action="$1"
    if [ -z "$action" ]; then
        echo "Erreur: Action manquante pour la commande 'config'." >&2
        echo "Usage: aklo config <diagnose|get_config>" >&2
        return 1
    fi
    
    case "$action" in
        "diagnose")
            # La fonction get_memory_diagnostics est dans performance_tuning.sh
            if declare -f "get_memory_diagnostics" >/dev/null; then
                get_memory_diagnostics
            else
                echo "Erreur: Module de diagnostic non chargé." >&2
            fi
            ;;
        "get_config")
            cmd_get_config "$@"
            ;;
        *)
            echo "Erreur: Action '$action' inconnue." >&2
            return 1
            ;;
    esac
    return 0
}

#------------------------------------------------------------------------------
# FONCTION: cmd_get_config
# Affiche la configuration Aklo
# Usage: aklo config get_config [--all] [<clé> [section]]
#------------------------------------------------------------------------------
cmd_get_config() {
    local key="$2"
    local section="$3"
    local show_all=false
    
    # Vérifier l'option --all
    for arg in "$@"; do
        if [ "$arg" = "--all" ]; then
            show_all=true
            break
        fi
    done
    
    if [ "$show_all" = true ]; then
        echo "📋 Configuration Aklo complète :"
        echo "=================================="
        
        # Configuration globale
        echo ""
        echo "🔧 Configuration globale :"
        echo "  PROJECT_WORKDIR: $(get_config "PROJECT_WORKDIR" "" "$AKLO_PROJECT_ROOT")"
        echo "  MAIN_BRANCH: $(get_config "MAIN_BRANCH" "" "master")"
        echo "  CACHE_ENABLED: $(get_config "enabled" "cache" "true")"
        echo "  AUTO_TUNE_ENABLED: $(get_config "AUTO_TUNE_ENABLED" "" "true")"
        
        # Section cache
        echo ""
        echo "💾 Configuration cache :"
        echo "  cache_dir: $(get_config "cache_dir" "cache" ".aklo_cache")"
        echo "  max_size_mb: $(get_config "max_size_mb" "cache" "100")"
        echo "  ttl_days: $(get_config "ttl_days" "cache" "7")"
        
        # Section performance
        echo ""
        echo "⚡ Configuration performance :"
        echo "  memory_limit_mb: $(get_config "memory_limit_mb" "performance" "500")"
        echo "  cleanup_interval_minutes: $(get_config "cleanup_interval_minutes" "performance" "30")"
        echo "  monitoring_level: $(get_config "monitoring_level" "performance" "normal")"
        
        # Section monitoring
        echo ""
        echo "📊 Configuration monitoring :"
        echo "  IO_MONITORING_ENABLED: $(get_config "IO_MONITORING_ENABLED" "monitoring" "true")"
        echo "  IO_ALERT_THRESHOLD_MS: $(get_config "IO_ALERT_THRESHOLD_MS" "monitoring" "1000")"
        echo "  IO_RETENTION_DAYS: $(get_config "IO_RETENTION_DAYS" "monitoring" "7")"
        
        # Fichiers de configuration
        echo ""
        echo "📁 Fichiers de configuration :"
        local global_config="${AKLO_TOOL_DIR}/config/.aklo.conf"
        local local_config="${AKLO_PROJECT_ROOT}/.aklo.conf"
        
        if [ -f "$global_config" ]; then
            echo "  ✅ Configuration globale: $global_config"
        else
            echo "  ❌ Configuration globale: $global_config (non trouvé)"
        fi
        
        if [ -f "$local_config" ]; then
            echo "  ✅ Configuration locale: $local_config"
        else
            echo "  ❌ Configuration locale: $local_config (non trouvé)"
        fi
        
    elif [ -n "$key" ]; then
        # Afficher une clé spécifique
        local value
        if [ -n "$section" ]; then
            value=$(get_config "$key" "$section")
            printf "%s\n" "$value"
        else
            value=$(get_config "$key")
            printf "%s\n" "$value"
        fi
    else
        echo "Usage: aklo config get_config [--all] [<clé> [section]]" >&2
        echo "  --all     : Affiche toute la configuration" >&2
        echo "  <clé>     : Affiche la valeur d'une clé spécifique" >&2
        echo "  [section] : Section optionnelle pour la clé" >&2
        echo "" >&2
        echo "Exemples :" >&2
        echo "  aklo config get_config --all" >&2
        echo "  aklo config get_config PROJECT_WORKDIR" >&2
        echo "  aklo config get_config max_size_mb cache" >&2
        return 1
    fi
} 