#!/usr/bin/env bash
#==============================================================================
# Fonctions de cache pour le parser générique aklo
#==============================================================================

# Le répertoire du cache est DÉFINI ET EXPORTÉ par aklo/bin/aklo

# S'assure que le répertoire de cache (défini par le maître) existe.
mkdir -p "$AKLO_CACHE_DIR"

#==============================================================================
# Fonction: get_cache_filepath
# Description: Construit le chemin complet pour un fichier de cache donné.
#==============================================================================
get_cache_filepath() {
    local protocol_name="$1"
    local artefact_type="$2"
    local identifier="${protocol_name}_${artefact_type}"
    echo "${AKLO_CACHE_DIR}/${identifier}.parsed"
}

#==============================================================================
# Fonction: find_protocol_file
# Description: Trouve le chemin absolu d'un fichier de protocole.
#==============================================================================
find_protocol_file() {
    local protocol_name="$1"
    echo "${AKLO_PROJECT_ROOT}/aklo/charte/PROTOCOLES/${protocol_name}.xml"
}

#==============================================================================
# Fonction: cache_is_valid
# Description: Vérifie si un fichier cache est plus récent que son protocole.
#==============================================================================
cache_is_valid() {
    local cache_file="$1"
    local protocol_file="$2"
    
    [ ! -f "$cache_file" ] && return 1
    [ ! -f "$protocol_file" ] && return 1

    # Utilisation de mtime pour la comparaison
    local cache_mtime
    cache_mtime=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
    local protocol_mtime
    protocol_mtime=$(stat -f %m "$protocol_file" 2>/dev/null || stat -c %Y "$protocol_file" 2>/dev/null)

    [ "$cache_mtime" -ge "$protocol_mtime" ]
}

#==============================================================================
# Fonctions factices pour la compatibilité, à implémenter si nécessaire
#==============================================================================
log_cache_event() { :; }
update_cache_mtime() { :; }
get_next_id_cached() { echo "1"; }

#==============================================================================
# FONCTION : generate_cache_filename
# Crée un nom de fichier cache unique et portable à partir d'identifiants.
#==============================================================================
generate_cache_filename() {
    local protocol_name="$1"
    local artefact_type="$2"
    
    # Nettoie les entrées pour éviter les caractères problématiques
    local safe_protocol_name
    safe_protocol_name=$(echo "$protocol_name" | sed 's/[^a-zA-Z0-9_-]/_/g')
    local safe_artefact_type
    safe_artefact_type=$(echo "$artefact_type" | sed 's/[^a-zA-Z0-9_-]/_/g')

    local identifier="protocol_${safe_protocol_name}_${safe_artefact_type}"
    echo "${AKLO_CACHE_DIR}/${identifier}.parsed"
}

#==============================================================================
# FONCTION : get_file_mtime
# Récupère le timestamp de dernière modification d'un fichier (portable).
#==============================================================================
get_file_mtime() {
    local file_path="$1"
    stat -f %m "$file_path" 2>/dev/null || stat -c %Y "$file_path" 2>/dev/null
}

#==============================================================================
# FONCTION : is_cache_valid
# Vérifie si un fichier cache est plus récent que son fichier source.
#==============================================================================
is_cache_valid() {
    local cache_file="$1"
    local source_mtime="$2"

    local mtime_file="${cache_file}.mtime"

    if [ ! -f "$cache_file" ] || [ ! -f "$mtime_file" ]; then
        return 1 # Cache inexistant
    fi

    local cached_mtime
    cached_mtime=$(cat "$mtime_file")

    # Si le timestamp du cache est supérieur ou égal à celui de la source, il est valide.
    if [ "$cached_mtime" -ge "$source_mtime" ]; then
        return 0 # Cache valide
    else
        return 1 # Cache obsolète
    fi
}

#==============================================================================
# FONCTION : use_cached_structure
# Lit et retourne le contenu d'un fichier de cache.
#==============================================================================
use_cached_structure() {
    local cache_file="$1"
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
        return 0
    fi
    return 1
}

# Fonction pour logger les événements de cache
log_cache_event() {
    if [ "${AKLO_CACHE_DEBUG:-false}" = "true" ]; then
        local event_type="$1"
        local message="$2"
        echo "[CACHE::$event_type] $message" >&2
    fi
}