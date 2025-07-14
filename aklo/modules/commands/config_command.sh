#!/usr/bin/env bash
#==============================================================================
# AKLO CONFIG COMMAND MODULE
#==============================================================================

cmd_config() {
    local action="$1"
    if [ -z "$action" ]; then
        echo "Erreur: Action manquante pour la commande 'config'." >&2
        echo "Usage: aklo config <diagnose>" >&2
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
        *)
            echo "Erreur: Action '$action' inconnue." >&2
            return 1
            ;;
    esac
    return 0
} 