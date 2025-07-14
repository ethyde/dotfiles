#!/usr/bin/env bash
#==============================================================================
# AKLO MONITOR COMMAND MODULE
#==============================================================================

cmd_monitor() {
    local action="$1"
    if [ -z "$action" ]; then
        echo "Erreur: Action manquante pour la commande 'monitor'." >&2
        echo "Usage: aklo monitor <dashboard>" >&2
        return 1
    fi
    
    case "$action" in
        "dashboard")
            # La fonction show_io_dashboard est dans io_monitoring.sh
            if declare -f "show_io_dashboard" >/dev/null; then
                show_io_dashboard
            else
                echo "Erreur: Module de dashboard non chargé." >&2
            fi
            ;;
        *)
            echo "Erreur: Action '$action' inconnue." >&2
            return 1
            ;;
    esac
    return 0
} 