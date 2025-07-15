#!/usr/bin/env bash
#==============================================================================
# Fonctions de cache pour le parser générique aklo
#==============================================================================

# La création du répertoire est déplacée dans une fonction pour un contrôle total.
init_cache_dir() {
    # La variable AKLO_PROJECT_ROOT est définie et exportée par aklo/bin/aklo
    local cache_dir_path
    cache_dir_path=$(get_config "cache_dir" "cache" "${AKLO_PROJECT_ROOT}/.aklo_cache")
    
    if [ -n "$cache_dir_path" ] && [ ! -d "$cache_dir_path" ]; then
        if [ "${AKLO_DRY_RUN:-false}" = false ]; then
            mkdir -p "$cache_dir_path"
        fi
    fi
}

# ... (le reste du fichier : get_cache_filepath, cache_is_valid, etc. reste inchangé) ...
