#!/usr/bin/env bash
#==============================================================================
# AKLO CACHE COMMAND MODULE
#==============================================================================

# Importer les fonctions de cache
AKLO_MODULES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$AKLO_MODULES_ROOT/cache/cache_monitoring.sh"

cmd_cache() {
    local action="$1"
    if [ -z "$action" ]; then
        echo "Erreur: Action manquante pour la commande 'cache'." >&2
        echo "Usage: aklo cache <status|clear|benchmark>" >&2
        return 1
    fi
    
    case "$action" in
        "status")      show_cache_status ;;
        "clear")       clear_cache ;;
        "benchmark")   benchmark_cache ;;
        *)
            echo "Erreur: Action '$action' inconnue pour la commande 'cache'." >&2
            return 1
            ;;
    esac
    return 0
} 