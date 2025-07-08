#!/bin/bash

# shellcheck disable=SC2148
#
# Module Parser avec gestion de cache
# Tous les logs de statuts de cache (MISS, HIT, etc.) doivent utiliser la fonction centralisée log_cache_event du module cache_functions.sh
# TASK-6-3

# Version avec cache de la fonction parse_and_generate_artefact
# TASK-6-3: Intégration cache dans parse_and_generate_artefact
# Phase GREEN: Implémentation minimale

# Sourcing robuste des fonctions de cache
if [ -n "$AKLO_PROJECT_ROOT" ]; then
  source "$AKLO_PROJECT_ROOT/aklo/modules/cache/cache_functions.sh"
else
  source "$(dirname "$0")/../cache/cache_functions.sh"
fi

# Configuration cache par défaut
AKLO_CACHE_ENABLED="${AKLO_CACHE_ENABLED:-true}"
AKLO_CACHE_DEBUG="${AKLO_CACHE_DEBUG:-false}"

# Fonction pour lire la configuration cache depuis .aklo.conf
get_cache_config() {
    local config_file=".aklo.conf"
    
    # Chercher le fichier de config
    if [ ! -f "$config_file" ]; then
        local script_dir="$(dirname "$0")"
        config_file="${script_dir}/../config/.aklo.conf"
    fi
    
    if [ -f "$config_file" ]; then
        # Lire la configuration cache uniquement si non déjà définie
        if [ -z "$AKLO_CACHE_ENABLED" ] && grep -q "^CACHE_ENABLED=" "$config_file" 2>/dev/null; then
            AKLO_CACHE_ENABLED=$(grep "^CACHE_ENABLED=" "$config_file" | cut -d'=' -f2)
        fi
        
        if [ -z "$AKLO_CACHE_DEBUG" ] && grep -q "^CACHE_DEBUG=" "$config_file" 2>/dev/null; then
            AKLO_CACHE_DEBUG=$(grep "^CACHE_DEBUG=" "$config_file" | cut -d'=' -f2)
        fi
    fi
}

# Version avec cache de parse_and_generate_artefact
# Remplace la fonction originale avec intégration cache intelligente
parse_and_generate_artefact_cached() {
    local protocol_name="$1"        # Ex: "03-DEVELOPPEMENT"
    local artefact_type="$2"        # Ex: "pbi", "task"
    local assistance_level="$3"     # "full", "skeleton", "minimal"
    local output_file="$4"          # Chemin du fichier de sortie
    local context_vars="$5"         # Variables contextuelles
    
    # Lire la configuration cache
    get_cache_config
    export AKLO_CACHE_ENABLED
    
    # Construire le chemin du protocole en priorité depuis la variable d'environnement
    local protocol_dir="${AKLO_PROTOCOLS_PATH:-./aklo/charte/PROTOCOLES}"
    local protocol_file="${protocol_dir}/${protocol_name}.xml"
    
    # Si pas trouvé, essayer les chemins legacy pour la compatibilité
    if [ ! -f "$protocol_file" ]; then
        protocol_file="./aklo/charte/PROTOCOLES/${protocol_name}.xml"
        if [ ! -f "$protocol_file" ]; then
            local script_dir
            script_dir="$(dirname "$0")"
            protocol_file="${script_dir}/../charte/PROTOCOLES/${protocol_name}.xml"
        fi
    fi
    
    if [ ! -f "$protocol_file" ]; then
        echo "❌ Erreur : Protocole $protocol_name non trouvé." >&2
        echo "   Cherché dans: ./aklo/charte/PROTOCOLES/${protocol_name}.xml" >&2
        echo "   Et dans: ${script_dir}/../charte/PROTOCOLES/${protocol_name}.xml" >&2
        return 1
    fi
    
    # Log de debug pour tracer la valeur de AKLO_CACHE_ENABLED
    log_cache_event "DEBUG" "AKLO_CACHE_ENABLED=$AKLO_CACHE_ENABLED"
    # Gestion stricte du cache désactivé (guard clause)
    if [ "$AKLO_CACHE_ENABLED" = "false" ]; then
        local artefact_structure
        log_cache_event "DISABLED" "Cache désactivé par configuration"
        artefact_structure=$(extract_artefact_xml "$protocol_file" "$artefact_type")
        if [ -z "$artefact_structure" ]; then
            echo "❌ Erreur : Structure d'artefact $artefact_type non trouvée dans $protocol_name." >&2
            return 1
        fi
        if declare -f inject_missing_xml_tags >/dev/null; then
            artefact_structure=$(inject_missing_xml_tags "$artefact_structure" "title" "status")
        fi
        if ! echo "$artefact_structure" > "$output_file"; then
            echo "❌ Erreur : Impossible d'écrire dans $output_file." >&2
            return 1
        fi
        log_cache_event "COMPLETE" "Génération artefact terminée: $output_file"
        return 0
    fi

    # Générer le nom du fichier cache uniquement si le cache est activé
    local cache_file
    if cache_file=$(generate_cache_filename "$protocol_name" "$artefact_type"); then
        :
    fi

    # Tentative d'utilisation du cache si activé
    local artefact_structure=""
    if [ "$AKLO_CACHE_ENABLED" = "true" ]; then
        log_cache_event "CHECK" "Vérification cache pour ${protocol_name}/${artefact_type}"
        # Obtenir le timestamp du protocole
        local protocol_mtime
        if protocol_mtime=$(get_file_mtime "$protocol_file"); then
            # Vérifier la validité du cache
            if cache_is_valid "$cache_file" "$protocol_mtime"; then
                # Cache hit - utiliser le cache
                log_cache_event "HIT" "Cache valide trouvé: $cache_file"
                if artefact_structure=$(use_cached_structure "$cache_file"); then
                    log_cache_event "SUCCESS" "Cache lu avec succès"
                else
                    log_cache_event "ERROR" "Échec lecture cache - fallback vers extraction"
                    artefact_structure=""
                fi
            else
                # Cache miss - extraction et mise en cache
                log_cache_event "MISS" "Cache invalide ou inexistant"
                if artefact_structure=$(extract_and_cache_structure "$protocol_file" "$artefact_type" "$cache_file"); then
                    log_cache_event "CACHED" "Structure extraite et mise en cache"
                else
                    log_cache_event "ERROR" "Échec extraction avec cache - fallback"
                    artefact_structure=""
                fi
            fi
        else
            log_cache_event "ERROR" "Impossible d'obtenir mtime - fallback"
        fi
    fi
    
    # Fallback extraction XML natif si cache échoue (uniquement si cache activé)
    if [ -z "$artefact_structure" ] && [ "$AKLO_CACHE_ENABLED" = "true" ]; then
        local artefact_structure_fallback
        log_cache_event "FALLBACK" "Extraction XML natif directe"
        artefact_structure_fallback=$(extract_artefact_xml "$protocol_file" "$artefact_type")
        if [ -z "$artefact_structure_fallback" ]; then
            echo "❌ Erreur : Structure d'artefact $artefact_type non trouvée dans $protocol_name." >&2
            return 1
        fi
        # Forcer le recalcul du cache si le protocole a changé
        if [ -n "$cache_file" ]; then
            echo "$artefact_structure_fallback" > "$cache_file"
            log_cache_event "RECALC" "Cache régénéré pour $cache_file"
        fi
        artefact_structure="$artefact_structure_fallback"
    fi
    
    # Pas de filtrage intelligent ni d'injection de variables : XML pur
    local filtered_content="$artefact_structure"
    # Injection dynamique des balises <title> et <status>
    if declare -f inject_missing_xml_tags >/dev/null; then
        filtered_content=$(inject_missing_xml_tags "$filtered_content" "title" "status")
    fi
    # Écrire le résultat dans le fichier de sortie
    if ! echo "$filtered_content" > "$output_file"; then
        echo "❌ Erreur : Impossible d'écrire dans $output_file." >&2
        return 1
    fi
    
    log_cache_event "COMPLETE" "Génération artefact terminée: $output_file"
    return 0
}

# Fonction de compatibilité - remplace la fonction originale
parse_and_generate_artefact() {
    parse_and_generate_artefact_cached "$@"
}