#!/usr/bin/env bash
#==============================================================================
# AKLO CACHE COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: cache
# Point d'entrée pour la gestion du cache.
#------------------------------------------------------------------------------
cmd_cache() {
    local action="$1"
    if [ -z "$action" ]; then
        echo "Erreur: Action manquante pour la commande 'cache'." >&2
        echo "Usage: aklo cache <status|clear|benchmark|dashboard>" >&2
        return 1
    fi
    
    # Le module cache_monitoring est déjà chargé par le classifieur
    case "$action" in
        "status")
            show_cache_status
            ;;
        "clear")
            clear_cache
            ;;
        "benchmark")
            benchmark_cache
            ;;
        "dashboard")
            echo "Pour le dashboard I/O, utilisez 'aklo monitor dashboard'"
            ;;
        *)
            echo "Erreur: Action '$action' inconnue pour la commande 'cache'." >&2
            return 1
            ;;
    esac
    return 0
} 