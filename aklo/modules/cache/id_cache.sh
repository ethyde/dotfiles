#!/usr/bin/env bash
#==============================================================================
# AKLO ID CACHE
# DÉPENDANCE (gérée par aklo/bin/aklo): cache/cache_functions.sh
#==============================================================================

#------------------------------------------------------------------------------
# Obtient le prochain ID disponible pour un type d'artefact dans un répertoire.
# Utilise un cache pour des performances optimales.
#
# @param $1 - Répertoire des artefacts (ex: "docs/backlog/00-pbi")
# @param $2 - Préfixe de l'artefact (ex: "PBI-")
#------------------------------------------------------------------------------
get_next_id_cached() {
    local artefact_dir="$1"
    local prefix="$2"
    local cache_key
    cache_key=$(generate_cache_filename "${artefact_dir}" "id_cache")

    # Si le cache est valide, on l'utilise
    if is_cache_valid "$cache_key"; then
        cat "$cache_key"
        return
    fi

    # Sinon, on calcule, on met en cache et on retourne la valeur
    local last_id
    last_id=$(find "$artefact_dir" -name "${prefix}*.xml" 2>/dev/null | \
              grep -oE "${prefix}[0-9]+" | \
              sed "s/${prefix}//" | \
              sort -nr | \
              head -1)
    
    local next_id=$(( ${last_id:-0} + 1 ))
    
    echo "$next_id" | tee "$cache_key" >/dev/null
    echo "$next_id"
}