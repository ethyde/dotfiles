#!/bin/bash

#==============================================================================
# Command Classifier - v4.0 - Compatible Bash 3+ avec chemins complets
#==============================================================================

classify_command() {
    local command="$1"
    case "$command" in
        get_config|status|version|help|list|info)
            echo "MINIMAL"
            ;;
        propose-pbi|pbi|task|plan|dev|debug|review|arch|refactor|new|template|create|init)
            echo "NORMAL"
            ;;
        optimize|benchmark|cache|monitor|diagnose|batch|performance)
            echo "FULL"
            ;;
        *)
            echo "NORMAL" # Profil par défaut pour les commandes inconnues
            ;;
    esac
}

get_required_modules() {
    local profile="$1"
    case "$profile" in
        MINIMAL)
            echo "commands" # Contient get_config, help, status
            ;;
        NORMAL)
            echo "cache/cache_functions,io/extract_functions,cache/id_cache,parser/parser_cached,commands"
            ;;
        FULL)
            echo "cache/cache_functions,io/extract_functions,cache/id_cache,parser/parser_cached,performance/performance_tuning,commands"
            ;;
        *)
            echo "commands" # Fallback de sécurité
            ;;
    esac
}