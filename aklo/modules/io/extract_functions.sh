#!/bin/bash

# Fonctions d'extraction et de mise en cache pour aklo
# TASK-6-2: Fonction de mise en cache des structures protocoles
# Phase BLUE: Version refactorisée et optimisée

# Source des fonctions de cache (TASK-6-1)
source "$(dirname "${BASH_SOURCE[0]}")/../cache/cache_functions.sh"

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

# Applique un filtrage intelligent sur la structure XML en fonction du niveau d'assistance
# et injecte les variables contextuelles.
# Assure également que les balises title et status sont présentes.
# Usage: apply_intelligent_filtering <xml_structure> <assistance_level> <context_vars>
apply_intelligent_filtering() {
    local xml_structure="$1"
    local assistance_level="$2"
    local context_vars="$3"

    # 1. Injection des balises title et status
    local final_xml
    final_xml=$(inject_missing_xml_tags "$xml_structure" "$context_vars")
    
    # 2. Logique de filtrage basée sur assistance_level (à implémenter si nécessaire)
    # ...

    # 3. Remplacement des variables contextuelles
    # Exemple : Remplacer {{PBI_ID}} par sa valeur
    if [[ "$context_vars" == *"PBI_ID="* ]]; then
        local pbi_id
        pbi_id=$(echo "$context_vars" | grep -o 'PBI_ID=[^;]*' | cut -d'=' -f2)
        final_xml=$(echo "$final_xml" | sed "s/{{PBI_ID}}/$pbi_id/g")
    fi

    echo "$final_xml"
}


# Injecte dynamiquement les balises XML manquantes dans un bloc artefact
# Usage: inject_missing_xml_tags <xml_block> [<context_vars>]
inject_missing_xml_tags() {
    local xml_block="$1"
    local context_vars="$2"
    local result="$xml_block"

    # Extraire le nom de la balise racine (ex: pbi, task)
    local root_tag
    root_tag=$(echo "$result" | grep -o '^<[a-zA-Z0-9_-]*' | sed 's/^<//')

    if [ -n "$root_tag" ]; then
        # Extraire le titre depuis les variables de contexte, sinon valeur par défaut
        local title_value="Titre non défini"
        if [[ "$context_vars" == *"TITLE="* ]]; then
            title_value=$(echo "$context_vars" | grep -o 'TITLE=[^;]*' | cut -d'=' -f2)
        fi

        # Injection de l'attribut title si absent
        if ! echo "$result" | grep -q "<$root_tag.*title="; then
            local title_value
            title_value=$(echo "$context_vars" | tr ';' '\n' | grep 'TITLE=' | cut -d'=' -f2)
            result=$(echo "$result" | sed "s/<$root_tag>/<$root_tag title=\"${title_value:-Sans titre}\">/")
        fi

        # Injection de la balise <status>PROPOSED</status> si absente
        if ! echo "$result" | grep -q '<status>'; then
            local status_value="PROPOSED"
            result=$(echo "$result" | sed "s~</$root_tag>~  <status>$status_value</status>\\n</$root_tag>~")
        fi
    fi

    echo "$result"
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