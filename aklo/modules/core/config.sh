#!/usr/bin/env bash
#==============================================================================
# AKLO CORE CONFIG MODULE (V3 - AVEC PARSING DE SECTION)
#==============================================================================

declare -A AKLO_CONFIG_CACHE

#------------------------------------------------------------------------------
# FONCTION: get_config
# Lit une variable depuis .aklo.conf (global ou dans une section).
# Usage : get_config <clé> [section] [valeur_par_défaut]
#------------------------------------------------------------------------------
get_config() {
    local key="$1"
    local section="$2"
    local default_value="$3"
    local cache_key="${section}:${key}"

    if [ -n "${AKLO_CONFIG_CACHE[$cache_key]}" ]; then
        echo "${AKLO_CONFIG_CACHE[$cache_key]}"
        return
    fi

    local config_file="${AKLO_PROJECT_ROOT}/.aklo.conf"
    if [ ! -f "$config_file" ]; then
        config_file="${AKLO_PROJECT_ROOT}/aklo/config/.aklo.conf"
    fi

    if [ ! -f "$config_file" ]; then
        echo "$default_value"
        return
    fi
    
    local value=""
    # Utilisation de awk pour parser les sections de type .ini
    if [ -n "$section" ]; then
        value=$(awk -F'=' -v s="[$section]" -v k="$key" '
            $0 == s {in_section=1}
            /^\s*\[/ && $0 != s {in_section=0}
            in_section && $1 ~ k {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}
        ' "$config_file")
    else
        # Recherche globale pour les clés hors section
        value=$(grep "^${key}=" "$config_file" | head -n 1 | cut -d'=' -f2-)
    fi
    
    # Nettoyage de la valeur (supprime espaces et guillemets)
    value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"//' -e 's/"$//')

    if [ -n "$value" ]; then
        AKLO_CONFIG_CACHE["$cache_key"]="$value"
        echo "$value"
    else
        echo "$default_value"
    fi
} 