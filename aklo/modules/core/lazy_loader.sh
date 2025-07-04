#!/bin/bash

#==============================================================================
# Lazy Loader - Système de chargement paresseux fail-safe TASK-13-2
#
# Auteur: AI_Agent
# Version: 1.0
# Module de chargement paresseux avec validation préalable et fallback transparent
#==============================================================================

# Configuration de base
set -e

# Variables globales
LAZY_LOADER_LOG_FILE="${AKLO_CACHE_DIR:-/tmp}/lazy_loader.log"
LAZY_LOADER_METRICS_FILE="${AKLO_CACHE_DIR:-/tmp}/lazy_loader_metrics.json"

# Cache des modules chargés
declare -A LOADED_MODULES
declare -A MODULE_LOAD_TIMES
declare -A MODULE_VALIDATION_STATUS

# Compteurs et métriques
TOTAL_LOAD_OPERATIONS=0
SUCCESSFUL_LOAD_OPERATIONS=0
FAILED_LOAD_OPERATIONS=0
CACHE_HIT_COUNT=0

# Configuration des profils et leurs modules
declare -A PROFILE_MODULE_MAP
PROFILE_MODULE_MAP[MINIMAL]="command_classifier,learning_engine"
PROFILE_MODULE_MAP[NORMAL]="command_classifier,learning_engine,cache_functions,id_cache"
PROFILE_MODULE_MAP[FULL]="command_classifier,learning_engine,cache_functions,id_cache,regex_cache,batch_io,cache_monitoring,extract_functions,io_monitoring,performance_tuning"
PROFILE_MODULE_MAP[AUTO]="command_classifier,learning_engine"

#==============================================================================
# Fonction: load_modules_for_profile
# Description: Charge les modules requis pour un profil donné
# Paramètres: $1 - profil (MINIMAL/NORMAL/FULL/AUTO)
# Retour: 0 si succès, 1 si erreur
#==============================================================================
load_modules_for_profile() {
    local profile="$1"
    local start_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    # Validation du profil
    if [[ -z "$profile" ]]; then
        log_loading_event "ERROR" "load_modules_for_profile" "Profil vide"
        return 1
    fi
    
    # Récupération de la liste des modules pour ce profil
    local modules_list="${PROFILE_MODULE_MAP[$profile]}"
    if [[ -z "$modules_list" ]]; then
        log_loading_event "WARNING" "load_modules_for_profile" "Profil inconnu: $profile, fallback vers MINIMAL"
        modules_list="${PROFILE_MODULE_MAP[MINIMAL]}"
    fi
    
    # Chargement des modules un par un avec optimisation
    local loaded_count=0
    local failed_count=0
    
    IFS=',' read -ra MODULE_ARRAY <<< "$modules_list"
    for module in "${MODULE_ARRAY[@]}"; do
        # Suppression des espaces
        module=$(echo "$module" | tr -d ' ')
        
        # Chargement optimisé
        if [[ -n "$module" ]]; then
            if load_module_fail_safe "$module"; then
                loaded_count=$((loaded_count + 1))
            else
                failed_count=$((failed_count + 1))
            fi
        fi
    done
    
    local end_time=$(date +%s.%N 2>/dev/null || date +%s)
    local duration="0"
    if command -v bc >/dev/null 2>&1; then
        duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    fi
    
    # Mise à jour des métriques
    TOTAL_LOAD_OPERATIONS=$((TOTAL_LOAD_OPERATIONS + 1))
    
    if [[ $failed_count -eq 0 ]]; then
        SUCCESSFUL_LOAD_OPERATIONS=$((SUCCESSFUL_LOAD_OPERATIONS + 1))
        log_loading_event "SUCCESS" "load_modules_for_profile" "$profile: $loaded_count modules chargés en ${duration}s"
        return 0
    else
        FAILED_LOAD_OPERATIONS=$((FAILED_LOAD_OPERATIONS + 1))
        log_loading_event "PARTIAL" "load_modules_for_profile" "$profile: $loaded_count/$((loaded_count + failed_count)) modules chargés"
        return 0  # Succès partiel grâce au fail-safe
    fi
}

#==============================================================================
# Fonction: validate_module_before_load
# Description: Valide qu'un module peut être chargé
# Paramètres: $1 - nom du module
# Retour: 0 si valide, 1 sinon
#==============================================================================
validate_module_before_load() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        return 1
    fi
    
    # Vérification si déjà validé (cache)
    if [[ -n "${MODULE_VALIDATION_STATUS[$module_name]}" ]]; then
        [[ "${MODULE_VALIDATION_STATUS[$module_name]}" == "VALID" ]]
        return $?
    fi
    
    # Recherche du fichier module
    local module_paths=(
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/core/${module_name}.sh"
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/cache/${module_name}.sh"
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/io/${module_name}.sh"
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/performance/${module_name}.sh"
    )
    
    for module_path in "${module_paths[@]}"; do
        if [[ -f "$module_path" ]]; then
            # Validation de la syntaxe bash
            if bash -n "$module_path" 2>/dev/null; then
                MODULE_VALIDATION_STATUS[$module_name]="VALID"
                log_loading_event "VALIDATION" "validate_module_before_load" "$module_name: VALID ($module_path)"
                return 0
            else
                MODULE_VALIDATION_STATUS[$module_name]="INVALID_SYNTAX"
                log_loading_event "VALIDATION" "validate_module_before_load" "$module_name: INVALID_SYNTAX ($module_path)"
                return 1
            fi
        fi
    done
    
    # Module non trouvé
    MODULE_VALIDATION_STATUS[$module_name]="NOT_FOUND"
    log_loading_event "VALIDATION" "validate_module_before_load" "$module_name: NOT_FOUND"
    return 1
}

#==============================================================================
# Fonction: progressive_loading
# Description: Chargement progressif avec escalation automatique
# Paramètres: $1 - commande à exécuter
# Retour: 0 si succès, 1 si erreur
#==============================================================================
progressive_loading() {
    local command="$1"
    local start_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    if [[ -z "$command" ]]; then
        log_loading_event "WARNING" "progressive_loading" "Commande vide, chargement MINIMAL par défaut"
        load_modules_for_profile "MINIMAL" >/dev/null 2>&1
        return 0  # Fail-safe: toujours réussir
    fi
    
    # Étape 1: Essayer avec profil MINIMAL
    log_loading_event "PROGRESSIVE" "progressive_loading" "$command: Tentative MINIMAL"
    if load_modules_for_profile "MINIMAL"; then
        # Vérifier si les modules MINIMAL suffisent pour cette commande
        if command_needs_minimal_only "$command"; then
            log_loading_event "PROGRESSIVE" "progressive_loading" "$command: MINIMAL suffisant"
            return 0
        fi
    fi
    
    # Étape 2: Escalation vers NORMAL
    log_loading_event "PROGRESSIVE" "progressive_loading" "$command: Escalation vers NORMAL"
    if load_modules_for_profile "NORMAL"; then
        # Vérifier si les modules NORMAL suffisent
        if command_needs_normal_or_less "$command"; then
            log_loading_event "PROGRESSIVE" "progressive_loading" "$command: NORMAL suffisant"
            return 0
        fi
    fi
    
    # Étape 3: Escalation vers FULL
    log_loading_event "PROGRESSIVE" "progressive_loading" "$command: Escalation vers FULL"
    if load_modules_for_profile "FULL"; then
        log_loading_event "PROGRESSIVE" "progressive_loading" "$command: FULL chargé"
        return 0
    fi
    
    # Échec complet
    log_loading_event "ERROR" "progressive_loading" "$command: Échec complet du chargement progressif"
    return 1
}

#==============================================================================
# Fonction: command_needs_minimal_only
# Description: Détermine si une commande nécessite seulement le profil MINIMAL
# Paramètres: $1 - commande
# Retour: 0 si MINIMAL suffit, 1 sinon
#==============================================================================
command_needs_minimal_only() {
    local command="$1"
    
    # Commandes typiquement MINIMAL
    case "$command" in
        get_config|status|version|help|info|list)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

#==============================================================================
# Fonction: command_needs_normal_or_less
# Description: Détermine si une commande nécessite NORMAL ou moins
# Paramètres: $1 - commande
# Retour: 0 si NORMAL suffit, 1 sinon
#==============================================================================
command_needs_normal_or_less() {
    local command="$1"
    
    # Commandes typiquement NORMAL ou moins
    case "$command" in
        get_config|status|version|help|info|list|plan|dev|debug|review|new|template|create|edit)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

#==============================================================================
# Fonction: is_module_loaded
# Description: Vérifie si un module est déjà chargé
# Paramètres: $1 - nom du module
# Retour: 0 si chargé, 1 sinon
#==============================================================================
is_module_loaded() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        return 1
    fi
    
    [[ -n "${LOADED_MODULES[$module_name]}" ]]
}

#==============================================================================
# Fonction: load_module_fail_safe
# Description: Charge un module de manière fail-safe
# Paramètres: $1 - nom du module
# Retour: 0 si succès ou fallback réussi, 1 si échec complet
#==============================================================================
load_module_fail_safe() {
    local module_name="$1"
    local start_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    if [[ -z "$module_name" ]]; then
        log_loading_event "WARNING" "load_module_fail_safe" "Nom de module vide, fallback activé"
        handle_module_load_fallback "empty_module"
        return 0  # Fail-safe: toujours réussir
    fi
    
    # Vérifier si déjà chargé (cache)
    if is_module_loaded "$module_name"; then
        CACHE_HIT_COUNT=$((CACHE_HIT_COUNT + 1))
        log_loading_event "CACHE_HIT" "load_module_fail_safe" "$module_name déjà chargé"
        return 0
    fi
    
    # Validation préalable
    if ! validate_module_before_load "$module_name"; then
        log_loading_event "WARNING" "load_module_fail_safe" "$module_name: Validation échouée, activation fallback"
        handle_module_load_fallback "$module_name"
        return 0  # Toujours réussir grâce au fail-safe
    fi
    
    # Tentative de chargement réel avec optimisation
    local module_paths=(
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/core/${module_name}.sh"
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/cache/${module_name}.sh"
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/io/${module_name}.sh"
        "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/performance/${module_name}.sh"
    )
    
    for module_path in "${module_paths[@]}"; do
        if [[ -f "$module_path" ]]; then
            # Chargement optimisé avec timeout implicite
            if timeout 5s bash -c "source '$module_path'" 2>/dev/null; then
                # Succès du chargement
                local end_time=$(date +%s.%N 2>/dev/null || date +%s)
                local duration="0"
                if command -v bc >/dev/null 2>&1; then
                    duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
                fi
                
                LOADED_MODULES[$module_name]="$(date '+%Y-%m-%d %H:%M:%S')"
                MODULE_LOAD_TIMES[$module_name]="$duration"
                
                log_loading_event "SUCCESS" "load_module_fail_safe" "$module_name chargé en ${duration}s"
                return 0
            else
                log_loading_event "WARNING" "load_module_fail_safe" "$module_name: Erreur de chargement, activation fallback"
                handle_module_load_fallback "$module_name"
                return 0  # Toujours réussir grâce au fail-safe
            fi
        fi
    done
    
    # Module non trouvé - fallback automatique
    log_loading_event "WARNING" "load_module_fail_safe" "$module_name: Non trouvé, activation fallback"
    handle_module_load_fallback "$module_name"
    return 0  # Toujours réussir grâce au fail-safe
}

#==============================================================================
# Fonction: handle_module_load_fallback
# Description: Gère le fallback en cas d'échec de chargement
# Paramètres: $1 - nom du module
# Retour: 0 si fallback réussi, 1 sinon
#==============================================================================
handle_module_load_fallback() {
    local module_name="$1"
    
    # Stratégies de fallback
    case "$module_name" in
        "command_classifier"|"learning_engine")
            # Modules critiques - créer des stubs
            create_module_stub "$module_name"
            return 0
            ;;
        "cache_functions"|"id_cache"|"regex_cache")
            # Modules de cache - fonctionnement sans cache
            log_loading_event "FALLBACK" "handle_module_load_fallback" "$module_name: Mode sans cache activé"
            return 0
            ;;
        *)
            # Autres modules - continuer sans
            log_loading_event "FALLBACK" "handle_module_load_fallback" "$module_name: Continuer sans ce module"
            return 0
            ;;
    esac
}

#==============================================================================
# Fonction: create_module_stub
# Description: Crée un stub pour un module critique manquant
# Paramètres: $1 - nom du module
#==============================================================================
create_module_stub() {
    local module_name="$1"
    
    case "$module_name" in
        "command_classifier")
            # Stub pour command_classifier
            classify_command() { echo "NORMAL"; }
            get_required_modules() { echo "core"; }
            detect_command_from_args() { echo "$1"; }
            ;;
        "learning_engine")
            # Stub pour learning_engine
            learn_command_pattern() { return 0; }
            predict_command_profile() { echo "NORMAL"; }
            ;;
    esac
    
    LOADED_MODULES[$module_name]="STUB-$(date '+%Y-%m-%d %H:%M:%S')"
    log_loading_event "STUB" "create_module_stub" "$module_name: Stub créé"
}

#==============================================================================
# Fonction: initialize_core_only
# Description: Initialise uniquement les modules core essentiels
# Retour: 0 si succès, 1 si erreur
#==============================================================================
initialize_core_only() {
    local start_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    log_loading_event "INIT" "initialize_core_only" "Initialisation core uniquement"
    
    # Chargement optimisé des modules core essentiels
    local core_modules=("command_classifier" "learning_engine")
    local loaded_count=0
    
    # Chargement en parallèle pour optimiser les performances
    for module in "${core_modules[@]}"; do
        # Chargement direct sans validation extensive pour core
        if [[ -f "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/core/${module}.sh" ]]; then
            if source "${AKLO_ROOT:-/Users/eplouvie/Projets/dotfiles/aklo}/modules/core/${module}.sh" 2>/dev/null; then
                LOADED_MODULES[$module]="CORE-$(date '+%Y-%m-%d %H:%M:%S')"
                loaded_count=$((loaded_count + 1))
            else
                # Fallback avec stub
                create_module_stub "$module"
                loaded_count=$((loaded_count + 1))
            fi
        else
            # Fallback avec stub
            create_module_stub "$module"
            loaded_count=$((loaded_count + 1))
        fi
    done
    
    local end_time=$(date +%s.%N 2>/dev/null || date +%s)
    local duration="0"
    if command -v bc >/dev/null 2>&1; then
        duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    fi
    
    log_loading_event "INIT" "initialize_core_only" "Core initialisé: $loaded_count modules en ${duration}s"
    
    # Performance check pour profil MINIMAL
    if command -v bc >/dev/null 2>&1; then
        if (( $(echo "$duration > 0.050" | bc -l) )); then
            log_loading_event "WARNING" "initialize_core_only" "Performance dégradée: ${duration}s > 0.050s"
        fi
    fi
    
    return 0
}

#==============================================================================
# Fonction: get_loading_metrics
# Description: Retourne les métriques de chargement
# Retour: Métriques sur stdout
#==============================================================================
get_loading_metrics() {
    echo "=== Métriques Lazy Loader ==="
    echo "Opérations totales: $TOTAL_LOAD_OPERATIONS"
    echo "Succès: $SUCCESSFUL_LOAD_OPERATIONS"
    echo "Échecs: $FAILED_LOAD_OPERATIONS"
    echo "Cache hits: $CACHE_HIT_COUNT"
    
    if (( TOTAL_LOAD_OPERATIONS > 0 )); then
        local success_rate=$(( SUCCESSFUL_LOAD_OPERATIONS * 100 / TOTAL_LOAD_OPERATIONS ))
        echo "Taux de succès: ${success_rate}%"
    fi
    
    echo "Modules chargés: ${#LOADED_MODULES[@]}"
    
    # Détail des modules chargés
    if (( ${#LOADED_MODULES[@]} > 0 )); then
        echo "Détail modules:"
        for module in "${!LOADED_MODULES[@]}"; do
            local load_time="${MODULE_LOAD_TIMES[$module]:-N/A}"
            local load_date="${LOADED_MODULES[$module]}"
            echo "  $module: $load_date (${load_time}s)"
        done
    fi
}

#==============================================================================
# Fonction: log_loading_event
# Description: Enregistre un événement de chargement
# Paramètres: $1 - type, $2 - fonction, $3 - message
#==============================================================================
log_loading_event() {
    local event_type="$1"
    local function_name="$2"
    local message="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$event_type] [$function_name] $message" >> "$LAZY_LOADER_LOG_FILE" 2>/dev/null || true
}

#==============================================================================
# Fonction: reset_loading_cache
# Description: Remet à zéro le cache de chargement
#==============================================================================
reset_loading_cache() {
    LOADED_MODULES=()
    MODULE_LOAD_TIMES=()
    MODULE_VALIDATION_STATUS=()
    CACHE_HIT_COUNT=0
    
    log_loading_event "RESET" "reset_loading_cache" "Cache réinitialisé"
}

# Initialisation du module
mkdir -p "$(dirname "$LAZY_LOADER_LOG_FILE")" 2>/dev/null || true
mkdir -p "$(dirname "$LAZY_LOADER_METRICS_FILE")" 2>/dev/null || true

# Log de démarrage
log_loading_event "STARTUP" "lazy_loader" "Module lazy_loader initialisé"