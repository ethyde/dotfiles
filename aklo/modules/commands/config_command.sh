#!/usr/bin/env bash
#==============================================================================
# AKLO CONFIG COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: config
# Point d'entrée pour la configuration de la performance.
#------------------------------------------------------------------------------
cmd_config() {
    local action="$1"
    if [ -z "$action" ]; then
        echo "Erreur: Action manquante pour la commande 'config'." >&2
        echo "Usage: aklo config <tune|profile|diagnose|validate>" >&2
        return 1
    fi
    
    # Le module performance_tuning est déjà chargé par le classifieur
    case "$action" in
        "tune")
            auto_tune_performance
            echo "✅ Auto-tuning des performances terminé."
            ;;
        "profile")
            local profile_name="$2"
            if [ -z "$profile_name" ]; then echo "Erreur: Nom de profil manquant (dev, test, prod)."; return 1; fi
            apply_performance_profile "$profile_name"
            echo "✅ Profil de performance '$profile_name' appliqué."
            ;;
        "diagnose")
            get_memory_diagnostics
            ;;
        "validate")
            if validate_performance_config; then
                echo "✅ La configuration de performance est valide."
            else
                echo "❌ La configuration de performance contient des erreurs."
            fi
            ;;
        *)
            echo "Erreur: Action '$action' inconnue pour la commande 'config'." >&2
            return 1
            ;;
    esac
    return 0
} 