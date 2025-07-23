#!/usr/bin/env bash
#==============================================================================
# Fonctions d'extraction et de mise en cache pour aklo
#==============================================================================

# --- AJOUT CRITIQUE ---
# Assure la disponibilité des fonctions de cache dont ce module dépend.
if [ -n "$AKLO_PROJECT_ROOT" ] && [ -f "${AKLO_PROJECT_ROOT}/aklo/modules/cache/cache_functions.sh" ]; then
  source "${AKLO_PROJECT_ROOT}/aklo/modules/cache/cache_functions.sh"
elif [ -n "$AKLO_TOOL_DIR" ]; then
  # Utiliser AKLO_TOOL_DIR si les modules ne sont pas dans AKLO_PROJECT_ROOT
  source "$AKLO_TOOL_DIR/modules/cache/cache_functions.sh"
else
  # Utiliser des chemins relatifs depuis le répertoire du script
  local script_dir
  script_dir="$(dirname "$0")"
  source "${script_dir}/../cache/cache_functions.sh"
fi

# Fonction de validation avant mise en cache
# Usage: validate_cache_prerequisites <protocol_file> <artefact_type> <cache_file>
# Retourne: 0 si valide, 1 si invalide
validate_cache_prerequisites() {
    local protocol_file="$1"
    local artefact_type="$2"
    local cache_file="$3"
    
    # Validation des paramètres d'entrée
    if [ -z "$protocol_file" ] || [ -z "$artefact_type" ] || [ -z "$cache_file" ]; then
        return 1
    fi
    
    # Vérifier l'existence du fichier protocole
    if [ ! -f "$protocol_file" ]; then
        return 1
    fi
    
    # Vérifier que le type d'artefact est supporté
    if ! is_valid_artefact_type "$artefact_type"; then
        return 1
    fi
    
    # Vérifier que le répertoire parent du cache existe ou peut être créé
    local cache_dir
    cache_dir=$(dirname "$cache_file")
    if [ ! -d "$cache_dir" ]; then
        if ! mkdir -p "$cache_dir" 2>/dev/null; then
            return 1
        fi
    fi
    
    return 0
}

# Fonction principale : extraire et mettre en cache la structure d'un protocole
# Usage: extract_and_cache_structure <protocol_file> <artefact_type> <cache_file>
# Retourne: structure extraite sur stdout, 0 si succès, 1 si erreur
extract_and_cache_structure() {
    local protocol_file="$1"
    local artefact_type="$2"
    local cache_file="$3"
    
    # Ne jamais écrire dans le cache si AKLO_CACHE_ENABLED=false
    if [ "$AKLO_CACHE_ENABLED" = "false" ]; then
        if declare -f log_cache_event >/dev/null; then
            log_cache_event "DISABLED" "Cache désactivé par configuration (extract_and_cache_structure)"
        fi
        # Debug temporaire : afficher le nom du cache_file si jamais appelé
        echo "[DEBUG] extract_and_cache_structure appelé avec cache désactivé, cache_file=$cache_file" >&2
        extract_artefact_xml "$protocol_file" "$artefact_type"
        return $?
    fi
    # Validation préalable
    if ! validate_cache_prerequisites "$protocol_file" "$artefact_type" "$cache_file"; then
        return 1
    fi
    
    # Extraire la structure XML depuis le protocole
    local structure
    if ! structure=$(extract_artefact_xml "$protocol_file" "$artefact_type"); then
        return 1
    fi
    
    # Vérifier que la structure n'est pas vide
    if [ -z "$structure" ]; then
        return 1
    fi
    
    # Obtenir le timestamp du fichier protocole
    local protocol_mtime
    if ! protocol_mtime=$(get_file_mtime "$protocol_file"); then
        return 1
    fi
    
    # Initialiser le répertoire cache
    if ! init_cache_dir; then
        return 1
    fi
    
    # Écriture atomique : utiliser des fichiers temporaires
    local temp_cache_file="${cache_file}.tmp.$$"
    local temp_mtime_file="${cache_file}.mtime.tmp.$$"
    
    # Piège pour nettoyer en cas d'interruption
    trap 'rm -f "$temp_cache_file" "$temp_mtime_file" 2>/dev/null' EXIT
    
    # Écrire la structure dans le fichier temporaire
    if ! echo "$structure" > "$temp_cache_file"; then
        return 1
    fi
    
    # Écrire le timestamp dans le fichier temporaire
    if ! echo "$protocol_mtime" > "$temp_mtime_file"; then
        return 1
    fi
    
    # Déplacer atomiquement les fichiers temporaires vers les fichiers finaux
    if ! mv "$temp_cache_file" "$cache_file"; then
        return 1
    fi
    
    if ! mv "$temp_mtime_file" "${cache_file}.mtime"; then
        # Le fichier cache est déjà créé, on continue
        rm -f "$temp_mtime_file" 2>/dev/null
    fi
    
    # Désactiver le piège de nettoyage
    trap - EXIT
    
    # Retourner la structure extraite
    echo "$structure"
    return 0
}

# Extraction d'une balise d'artefact XML depuis un protocole Aklo
# Usage: extract_artefact_xml <protocol_file> <artefact_tag>
# Retourne: le bloc XML de la balise demandée (ex: <pbi>...</pbi>), 0 si succès, 1 si erreur
extract_artefact_xml() {
    local protocol_file="$1"
    local artefact_tag="$2"
    if [ -z "$protocol_file" ] || [ ! -f "$protocol_file" ] || [ -z "$artefact_tag" ]; then
        echo "[AKLO:WARN] extract_artefact_xml: appel invalide (protocol_file='$protocol_file', tag='$artefact_tag', shell='$SHELL', 0='$0')" >&2
        return 1
    fi
    # Extraction stricte à l'intérieur du bloc <artefact_template>
    local structure
    structure=$(awk -v tag="$artefact_tag" '
        /<artefact_template/ { in_template=1 }
        /<\/artefact_template>/ { in_template=0 }
        in_template && match($0, "<"tag"[ >]") { in_block=1 }
        in_template && in_block { print }
        in_template && match($0, "</"tag">") && in_block { exit }
    ' "$protocol_file")
    if [ -z "$structure" ]; then
        echo "[AKLO:WARN] extract_artefact_xml: structure vide extraite (protocol_file='$protocol_file', tag='$artefact_tag', shell='$SHELL', head='$(head -n 5 "$protocol_file" | tr -d "\n")')" >&2
        return 1
    fi
    echo "$structure"
}

# Injecte dynamiquement les balises XML manquantes dans un bloc artefact
# Usage: inject_missing_xml_tags <xml_block> <tag1> [<tag2> ...]
inject_missing_xml_tags() {
    local xml_block="$1"
    shift
    local tags=("$@")
    local result="$xml_block"
    for tag in "${tags[@]}"; do
        if ! echo "$result" | grep -q "<$tag>"; then
            # Injecter la balise juste après l’ouverture de l’artefact principal
            # (on suppose que le bloc commence par <pbi> ou <task>...)
            result=$(echo "$result" | sed "0,/<[a-zA-Z0-9_\-]*>/s//&\n  <$tag><\/ $tag>/")
        fi
    done
    echo "$result"
}

# Validation des types d’artefacts supportés
# Usage: is_valid_artefact_type <type>
is_valid_artefact_type() {
    case "$1" in
        pbi|task|debug|arch|journal|improve|review)
            return 0 ;;
        *)
            return 1 ;;
    esac
}