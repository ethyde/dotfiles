#!/bin/bash

#==============================================================================
# Validation Engine - Moteur de validation pour le lazy loading TASK-13-2
#
# Auteur: AI_Agent
# Version: 1.0
# Module de validation préalable des modules avant chargement
#==============================================================================

# Configuration de base

# Variables globales de validation
VALIDATION_CACHE_FILE="${AKLO_CACHE_DIR:-/tmp}/validation_cache.json"
VALIDATION_LOG_FILE="${AKLO_CACHE_DIR:-/tmp}/validation_engine.log"

# Cache de validation
declare -A VALIDATION_CACHE
declare -A VALIDATION_TIMESTAMPS

# Compteurs de validation
VALIDATION_OPERATIONS=0
VALIDATION_CACHE_HITS=0
VALIDATION_SUCCESSES=0
VALIDATION_FAILURES=0

#==============================================================================
# Fonction: validate_module_syntax
# Description: Valide la syntaxe bash d'un module
# Paramètres: $1 - chemin du module
# Retour: 0 si valide, 1 sinon
#==============================================================================
validate_module_syntax() {
    local module_path="$1"
    
    if [[ ! -f "$module_path" ]]; then
        return 1
    fi
    
    # Validation syntaxe bash
    if bash -n "$module_path" 2>/dev/null; then
        log_validation_event "SYNTAX_OK" "validate_module_syntax" "$module_path"
        return 0
    else
        log_validation_event "SYNTAX_ERROR" "validate_module_syntax" "$module_path"
        return 1
    fi
}

#==============================================================================
# Fonction: validate_module_dependencies
# Description: Valide les dépendances d'un module
# Paramètres: $1 - chemin du module
# Retour: 0 si valide, 1 sinon
#==============================================================================
validate_module_dependencies() {
    local module_path="$1"
    
    if [[ ! -f "$module_path" ]]; then
        return 1
    fi
    
    # Extraction des dépendances (source, require, etc.)
    local dependencies
    dependencies=$(grep -E "^[[:space:]]*source|^[[:space:]]*\." "$module_path" 2>/dev/null | head -10)
    
    if [[ -n "$dependencies" ]]; then
        while IFS= read -r dep_line; do
            # Extraction du chemin de dépendance
            local dep_path
            dep_path=$(echo "$dep_line" | sed -E 's/^[[:space:]]*(source|\.)//g' | tr -d '"' | tr -d "'" | xargs)
            
            # Vérification si la dépendance existe
            if [[ -f "$dep_path" ]] || [[ -f "${module_path%/*}/$dep_path" ]]; then
                log_validation_event "DEP_OK" "validate_module_dependencies" "$dep_path"
            else
                log_validation_event "DEP_MISSING" "validate_module_dependencies" "$dep_path"
                return 1
            fi
        done <<< "$dependencies"
    fi
    
    return 0
}

#==============================================================================
# Fonction: validate_module_functions
# Description: Valide que les fonctions attendues sont présentes
# Paramètres: $1 - chemin du module, $2 - liste des fonctions attendues
# Retour: 0 si valide, 1 sinon
#==============================================================================
validate_module_functions() {
    local module_path="$1"
    local expected_functions="$2"
    
    if [[ ! -f "$module_path" ]]; then
        return 1
    fi
    
    # Extraction des fonctions définies
    local defined_functions
    defined_functions=$(grep -E "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)" "$module_path" 2>/dev/null | cut -d'(' -f1 | xargs)
    
    if [[ -n "$expected_functions" ]]; then
        IFS=',' read -ra EXPECTED_ARRAY <<< "$expected_functions"
        for expected_func in "${EXPECTED_ARRAY[@]}"; do
            expected_func=$(echo "$expected_func" | xargs)  # Supprimer espaces
            
            if echo "$defined_functions" | grep -q "$expected_func"; then
                log_validation_event "FUNC_OK" "validate_module_functions" "$expected_func"
            else
                log_validation_event "FUNC_MISSING" "validate_module_functions" "$expected_func"
                return 1
            fi
        done
    fi
    
    return 0
}

#==============================================================================
# Fonction: validate_module_comprehensive
# Description: Validation complète d'un module
# Paramètres: $1 - nom du module
# Retour: 0 si valide, 1 sinon
#==============================================================================
validate_module_comprehensive() {
    local module_name="$1"
    local start_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    VALIDATION_OPERATIONS=$((VALIDATION_OPERATIONS + 1))
    
    # Vérification cache
    if [[ -n "${VALIDATION_CACHE[$module_name]}" ]]; then
        local cache_timestamp="${VALIDATION_TIMESTAMPS[$module_name]}"
        local current_timestamp=$(date +%s)
        
        # Cache valide pendant 1 heure
        if (( current_timestamp - cache_timestamp < 3600 )); then
            VALIDATION_CACHE_HITS=$((VALIDATION_CACHE_HITS + 1))
            log_validation_event "CACHE_HIT" "validate_module_comprehensive" "$module_name"
            [[ "${VALIDATION_CACHE[$module_name]}" == "VALID" ]]
            return $?
        fi
    fi
    
    # Recherche du module
    local module_paths=(
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/core/${module_name}.sh"
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/cache/${module_name}.sh"
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/io/${module_name}.sh"
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/performance/${module_name}.sh"
    )
    
    for module_path in "${module_paths[@]}"; do
        if [[ -f "$module_path" ]]; then
            # Validation syntaxe
            if ! validate_module_syntax "$module_path"; then
                VALIDATION_CACHE[$module_name]="INVALID_SYNTAX"
                VALIDATION_TIMESTAMPS[$module_name]=$(date +%s)
                VALIDATION_FAILURES=$((VALIDATION_FAILURES + 1))
                return 1
            fi
            
            # Validation dépendances
            if ! validate_module_dependencies "$module_path"; then
                VALIDATION_CACHE[$module_name]="INVALID_DEPENDENCIES"
                VALIDATION_TIMESTAMPS[$module_name]=$(date +%s)
                VALIDATION_FAILURES=$((VALIDATION_FAILURES + 1))
                return 1
            fi
            
            # Validation fonctions spécifiques selon le module
            local expected_functions=""
            case "$module_name" in
                "command_classifier")
                    expected_functions="classify_command,get_required_modules"
                    ;;
                "learning_engine")
                    expected_functions="learn_command_pattern,predict_command_profile"
                    ;;
                "cache_functions")
                    expected_functions="cache_get,cache_set,cache_clear"
                    ;;
            esac
            
            if [[ -n "$expected_functions" ]]; then
                if ! validate_module_functions "$module_path" "$expected_functions"; then
                    VALIDATION_CACHE[$module_name]="INVALID_FUNCTIONS"
                    VALIDATION_TIMESTAMPS[$module_name]=$(date +%s)
                    VALIDATION_FAILURES=$((VALIDATION_FAILURES + 1))
                    return 1
                fi
            fi
            
            # Validation réussie
            VALIDATION_CACHE[$module_name]="VALID"
            VALIDATION_TIMESTAMPS[$module_name]=$(date +%s)
            VALIDATION_SUCCESSES=$((VALIDATION_SUCCESSES + 1))
            
            local end_time=$(date +%s.%N 2>/dev/null || date +%s)
            local duration="0"
            if command -v bc >/dev/null 2>&1; then
                duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
            fi
            
            log_validation_event "VALID" "validate_module_comprehensive" "$module_name validé en ${duration}s"
            return 0
        fi
    done
    
    # Module non trouvé
    VALIDATION_CACHE[$module_name]="NOT_FOUND"
    VALIDATION_TIMESTAMPS[$module_name]=$(date +%s)
    VALIDATION_FAILURES=$((VALIDATION_FAILURES + 1))
    log_validation_event "NOT_FOUND" "validate_module_comprehensive" "$module_name"
    return 1
}

#==============================================================================
# Fonction: get_validation_metrics
# Description: Retourne les métriques de validation
# Retour: Métriques sur stdout
#==============================================================================
get_validation_metrics() {
    echo "=== Métriques Validation Engine ==="
    echo "Validations totales: $VALIDATION_OPERATIONS"
    echo "Cache hits: $VALIDATION_CACHE_HITS"
    echo "Succès: $VALIDATION_SUCCESSES"
    echo "Échecs: $VALIDATION_FAILURES"
    
    if (( VALIDATION_OPERATIONS > 0 )); then
        local success_rate=$(( VALIDATION_SUCCESSES * 100 / VALIDATION_OPERATIONS ))
        local cache_hit_rate=$(( VALIDATION_CACHE_HITS * 100 / VALIDATION_OPERATIONS ))
        echo "Taux de succès: ${success_rate}%"
        echo "Taux de cache hit: ${cache_hit_rate}%"
    fi
    
    echo "Modules en cache: ${#VALIDATION_CACHE[@]}"
}

#==============================================================================
# Fonction: log_validation_event
# Description: Enregistre un événement de validation
# Paramètres: $1 - type, $2 - fonction, $3 - message
#==============================================================================
log_validation_event() {
    local event_type="$1"
    local function_name="$2"
    local message="$3"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo "[$timestamp] [$event_type] [$function_name] $message" >> "$VALIDATION_LOG_FILE"
}

#==============================================================================
# Fonction: clear_validation_cache
# Description: Vide le cache de validation
#==============================================================================
clear_validation_cache() {
    VALIDATION_CACHE=()
    VALIDATION_TIMESTAMPS=()
    
    log_validation_event "CACHE_CLEAR" "clear_validation_cache" "Cache de validation vidé"
}

# Initialisation du module
mkdir -p "$(dirname "$VALIDATION_CACHE_FILE")" 2>/dev/null || true
mkdir -p "$(dirname "$VALIDATION_LOG_FILE")" 2>/dev/null || true

# Log de démarrage
log_validation_event "STARTUP" "validation_engine" "Moteur de validation initialisé"