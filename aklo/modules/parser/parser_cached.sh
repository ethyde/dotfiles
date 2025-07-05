#!/bin/bash

# shellcheck disable=SC2148
#
# Module Parser avec gestion de cache
# TASK-6-3

# Version avec cache de la fonction parse_and_generate_artefact
# TASK-6-3: Intégration cache dans parse_and_generate_artefact
# Phase GREEN: Implémentation minimale

# Source des fonctions de cache
source "$AKLO_PROJECT_ROOT/aklo/modules/cache/cache_functions.sh"

# Configuration cache par défaut
AKLO_CACHE_ENABLED="${AKLO_CACHE_ENABLED:-true}"
AKLO_CACHE_DEBUG="${AKLO_CACHE_DEBUG:-false}"

# Fonction utilitaire pour le logging cache
log_cache_event() {
    local event="$1"
    local details="$2"
    
    if [ "$AKLO_CACHE_DEBUG" = "true" ]; then
        echo "[CACHE] $event: $details" >&2
    fi
}

# Fonction pour lire la configuration cache depuis .aklo.conf
get_cache_config() {
    local config_file=".aklo.conf"
    
    # Chercher le fichier de config
    if [ ! -f "$config_file" ]; then
        local script_dir="$(dirname "$0")"
        config_file="${script_dir}/../config/.aklo.conf"
    fi
    
    if [ -f "$config_file" ]; then
        # Lire la configuration cache
        if grep -q "^CACHE_ENABLED=" "$config_file" 2>/dev/null; then
            AKLO_CACHE_ENABLED=$(grep "^CACHE_ENABLED=" "$config_file" | cut -d'=' -f2)
        fi
        
        if grep -q "^CACHE_DEBUG=" "$config_file" 2>/dev/null; then
            AKLO_CACHE_DEBUG=$(grep "^CACHE_DEBUG=" "$config_file" | cut -d'=' -f2)
        fi
    fi
}

# Version avec cache de parse_and_generate_artefact
# Remplace la fonction originale avec intégration cache intelligente
parse_and_generate_artefact_cached() {
    local protocol_name="$1"        # Ex: "03-DEVELOPPEMENT"
    local artefact_type="$2"        # Ex: "PBI", "TASK"
    local assistance_level="$3"     # "full", "skeleton", "minimal"
    local output_file="$4"          # Chemin du fichier de sortie
    local context_vars="$5"         # Variables contextuelles
    
    # Lire la configuration cache
    get_cache_config
    
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
    
    local artefact_structure=""
    
    # NOUVEAU: Tentative d'utilisation du cache si activé
    if [ "$AKLO_CACHE_ENABLED" = "true" ]; then
        log_cache_event "CHECK" "Vérification cache pour ${protocol_name}/${artefact_type}"
        
        # Générer le nom du fichier cache
        local cache_file
        if cache_file=$(generate_cache_filename "$protocol_name" "$artefact_type"); then
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
        else
            log_cache_event "ERROR" "Impossible de générer nom cache - fallback"
        fi
    else
        log_cache_event "DISABLED" "Cache désactivé par configuration"
    fi
    
    # Fallback vers méthode originale si cache échoue ou désactivé
    if [ -z "$artefact_structure" ]; then
        log_cache_event "FALLBACK" "Utilisation méthode originale"
        artefact_structure=$(extract_artefact_structure "$protocol_file" "$artefact_type")
        
        if [ -z "$artefact_structure" ]; then
            echo "❌ Erreur : Structure d'artefact $artefact_type non trouvée dans $protocol_name." >&2
            return 1
        fi
        # Forcer le recalcul du cache si le protocole a changé
        if [ -n "$cache_file" ]; then
            echo "$artefact_structure" > "$cache_file"
            log_cache_event "RECALC" "Cache régénéré pour $cache_file"
        fi
    fi
    
    # Appliquer le filtrage intelligent selon le niveau d'assistance
    local filtered_content
    if ! filtered_content=$(apply_intelligent_filtering "$artefact_structure" "$assistance_level" "$context_vars"); then
        echo "❌ Erreur : Échec du filtrage intelligent (injection des variables). Vérifiez que tous les marqueurs %%VAR%% sont présents dans le template et que les variables sont bien passées." >&2
        return 1
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