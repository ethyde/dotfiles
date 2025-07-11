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