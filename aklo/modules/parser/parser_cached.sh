#!/bin/bash

# shellcheck disable=SC2148
#
# Module Parser avec gestion de cache
# Simplifié et fiabilisé pour corriger les régressions.

# Sourcing robuste des fonctions de cache
if [ -n "$AKLO_PROJECT_ROOT" ]; then
  source "$AKLO_PROJECT_ROOT/aklo/modules/cache/cache_functions.sh"
else
  # Fallback si non défini, bien que ce soit peu probable dans un contexte aklo
  source "$(dirname "$0")/../cache/cache_functions.sh"
fi

# ==============================================================================
# Fonction: parse_and_generate_artefact_cached
# Description: Génère un artefact à partir d'un protocole, en utilisant un
#              système de cache pour accélérer le processus.
# ==============================================================================
parse_and_generate_artefact_cached() {
    local protocol_name="$1"
    local artefact_type="$2"
    local assistance_level="$3" # Non utilisé actuellement, mais conservé pour compatibilité
    local output_file="$4"
    local context_vars="$5" # Non utilisé actuellement

    # 1. Configuration et validation des entrées
    # Rend la configuration du cache explicite via une fonction dédiée si elle existe.
    # Sinon, utilise une valeur par défaut sûre.
    if declare -f get_cache_config >/dev/null; then
        get_cache_config
    else
        AKLO_CACHE_ENABLED="${AKLO_CACHE_ENABLED:-true}"
    fi

    local protocol_file
    protocol_file=$(find_protocol_file "$protocol_name")
    if [ ! -f "$protocol_file" ]; then
        echo "❌ Erreur : Protocole '$protocol_name' introuvable." >&2
        return 1
    fi
    
    # Création des répertoires nécessaires pour éviter les erreurs d'écriture
    mkdir -p "$(dirname "$output_file")"

    # 2. Gestion du cache désactivé
    if [ "$AKLO_CACHE_ENABLED" != "true" ]; then
        log_cache_event "DISABLED" "Cache désactivé. Génération directe."
        local structure
        structure=$(extract_artefact_xml "$protocol_file" "$artefact_type")
        if [ -z "$structure" ]; then
            echo "❌ Erreur: Structure '$artefact_type' non trouvée dans '$protocol_name'." >&2
            return 1
        fi
        echo "$structure" > "$output_file"
        log_cache_event "COMPLETE" "Génération sans cache terminée pour $output_file"
        return 0
    fi

    # 3. Logique de cache (si activé)
    local cache_file
    cache_file=$(get_cache_filepath "protocol_${protocol_name}_${artefact_type}")
    mkdir -p "$(dirname "$cache_file")"

    log_cache_event "CHECK" "Vérification cache pour ${protocol_name}/${artefact_type}"
    
    local protocol_mtime
    protocol_mtime=$(get_file_mtime "$protocol_file")

    if cache_is_valid "$cache_file" "$protocol_mtime"; then
        # CACHE HIT
        log_cache_event "HIT" "Cache valide trouvé: $cache_file"
        record_cache_metric "hit"
        
        local cached_structure
        cached_structure=$(use_cached_structure "$cache_file")
        if [ -n "$cached_structure" ]; then
            echo "$cached_structure" > "$output_file"
            log_cache_event "SUCCESS" "Artefact généré depuis le cache: $output_file"
            return 0
        else
            log_cache_event "ERROR" "Cache HIT mais fichier vide. Forcing MISS."
        fi
    fi

    # CACHE MISS (ou cache invalide/vide)
    log_cache_event "MISS" "Cache invalide ou non trouvé. Extraction depuis le protocole."
    record_cache_metric "miss"
    
    local fresh_structure
    fresh_structure=$(extract_artefact_xml "$protocol_file" "$artefact_type")

    if [ -z "$fresh_structure" ]; then
        echo "❌ Erreur: Structure '$artefact_type' non trouvée dans '$protocol_name' lors de l'extraction." >&2
        # Créer un fichier cache vide pour éviter de retenter une extraction qui échoue
        echo "" > "$cache_file"
        update_cache_mtime "$cache_file" "$protocol_mtime"
        return 1
    fi

    # Écrire la nouvelle structure dans le fichier de sortie ET dans le cache
    echo "$fresh_structure" > "$output_file"
    echo "$fresh_structure" > "$cache_file"
    
    # Mettre à jour le timestamp du cache pour les futures vérifications
    update_cache_mtime "$cache_file" "$protocol_mtime"
    
    log_cache_event "CACHED" "Structure extraite et mise en cache: $cache_file"
    log_cache_event "COMPLETE" "Génération avec cache miss terminée: $output_file"
    
    return 0
}

# ==============================================================================
# Fonction de compatibilité
# Assure que les anciens appels continuent de fonctionner.
# ==============================================================================
parse_and_generate_artefact() {
    parse_and_generate_artefact_cached "$@"
}