#!/usr/bin/env bash
#==============================================================================
# AKLO MONITOR COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: monitor
# Point d'entrée pour les commandes de monitoring.
#------------------------------------------------------------------------------
cmd_monitor() {
    local action="$1"
    if [ -z "$action" ]; then
        echo "Erreur: Action manquante pour la commande 'monitor'." >&2
        echo "Usage: aklo monitor <dashboard|memory|performance>" >&2
        return 1
    fi
    
    # Les modules io_monitoring et performance_tuning sont chargés par le classifieur.
    case "$action" in
        "dashboard")
            show_io_dashboard
            ;;
        "memory")
            # La fonction get_memory_diagnostics se trouve dans performance_tuning.sh
            if declare -f "get_memory_diagnostics" >/dev/null; then
                get_memory_diagnostics
            else
                echo "Erreur: Le module de diagnostic mémoire n'est pas chargé." >&2
            fi
            ;;
        "performance")
            # La fonction generate_io_report se trouve dans io_monitoring.sh
            if declare -f "generate_io_report" >/dev/null; then
                generate_io_report
            else
                echo "Erreur: Le module de rapport de performance I/O n'est pas chargé." >&2
            fi
            ;;
        *)
            echo "Erreur: Action '$action' inconnue pour la commande 'monitor'." >&2
            return 1
            ;;
    esac
    return 0
} 