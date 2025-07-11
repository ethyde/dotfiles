#!/usr/bin/env bash
#==============================================================================
# AKLO CORE CONFIG MODULE
# Fournit un accès fiable aux variables de .aklo.conf
#==============================================================================

# Cache les variables pour éviter de lire le fichier à chaque appel.
declare -A AKLO_CONFIG_CACHE

#------------------------------------------------------------------------------
# FONCTION: get_config
# Lit une variable depuis .aklo.conf et la met en cache.
#------------------------------------------------------------------------------
get_config() {
    local key="$1"
    local default_value="$2"

    # Retourne la valeur du cache si elle existe
    if [ -n "${AKLO_CONFIG_CACHE[$key]}" ]; then
        echo "${AKLO_CONFIG_CACHE[$key]}"
        return
    fi

    local config_file="${AKLO_PROJECT_ROOT}/.aklo.conf"
    if [ ! -f "$config_file" ]; then
        # Si le fichier n'existe pas, on utilise la valeur par défaut
        echo "$default_value"
        return
    fi
    
    local value
    value=$(grep "^${key}=" "$config_file" | cut -d'=' -f2 | sed 's/"//g')

    if [ -n "$value" ]; then
        AKLO_CONFIG_CACHE["$key"]="$value" # Met en cache
        echo "$value"
    else
        echo "$default_value"
    fi
} 