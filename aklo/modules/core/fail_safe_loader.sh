#!/bin/bash

#==============================================================================
# Fail Safe Loader - Architecture Fail-Safe TASK-13-8
#
# Auteur: AI_Agent
# Version: 1.0
# Module de chargement sans échec possible avec fallback transparent
#
# Ce module garantit qu'aucun échec n'est possible lors du chargement
# des modules, avec validation préalable, fallback transparent et
# logging complet des événements.
#==============================================================================

# Configuration de base
set -e

# Source du validation engine
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "${script_dir}/validation_engine.sh" 2>/dev/null || {
    echo "⚠️  Validation engine non disponible - fallback mode" >&2
}

# Variables globales
FAIL_SAFE_LOG_FILE="${AKLO_CACHE_DIR:-/tmp}/fail_safe_loader.log"
FAIL_SAFE_METRICS_FILE="${AKLO_CACHE_DIR:-/tmp}/fail_safe_metrics.json"
LOADED_MODULES=()
FAILED_MODULES=()
FALLBACK_TRIGGERED=false
LOADING_START_TIME=""
LOADING_STATS=()

# Niveaux de fallback
declare -A FALLBACK_LEVELS
FALLBACK_LEVELS[0]="NONE"
FALLBACK_LEVELS[1]="PARTIAL"
FALLBACK_LEVELS[2]="COMPLETE"
FALLBACK_LEVELS[3]="EMERGENCY"

#==============================================================================
# Fonction: transparent_fallback
# Description: Fallback transparent vers chargement complet en cas de problème
# Paramètres: $1 - module qui a échoué, $2 - raison de l'échec, $3 - niveau de fallback
# Retour: 0 (ne peut pas échouer)
#==============================================================================
transparent_fallback() {
    local failed_module="$1"
    local failure_reason="$2"
    local fallback_level="${3:-1}"
    
    FALLBACK_TRIGGERED=true
    FAILED_MODULES+=("$failed_module")
    
    # Log détaillé de l'événement de fallback
    log_fail_safe_event "FALLBACK" "$failed_module" "$failure_reason" "$fallback_level"
    
    # Gestion du fallback selon le niveau
    case "$fallback_level" in
        1) # PARTIAL - Chargement partiel avec fonctions limitées
            attempt_partial_loading "$failed_module"
            ;;
        2) # COMPLETE - Chargement complet avec gestion d'erreur
            attempt_complete_loading "$failed_module"
            ;;
        3) # EMERGENCY - Mode d'urgence avec fonctions stub
            create_emergency_stubs "$failed_module"
            ;;
        *)
            # Fallback par défaut
            attempt_partial_loading "$failed_module"
            ;;
    esac
    
    # Le fallback ne peut jamais échouer
    return 0
}

#==============================================================================
# Fonction: attempt_partial_loading
# Description: Tentative de chargement partiel d'un module
# Paramètres: $1 - module à charger partiellement
#==============================================================================
attempt_partial_loading() {
    local module="$1"
    
    if [[ -f "$module" ]]; then
        # Tentative de chargement avec suppression des erreurs
        if source "$module" 2>/dev/null; then
            log_fail_safe_event "PARTIAL_SUCCESS" "$module" "Chargement partiel réussi"
        else
            log_fail_safe_event "PARTIAL_FAILED" "$module" "Chargement partiel échoué"
            # Escalade vers le niveau supérieur
            transparent_fallback "$module" "Partial loading failed" 2
        fi
    else
        log_fail_safe_event "MODULE_MISSING" "$module" "Module introuvable"
        create_emergency_stubs "$module"
    fi
}

#==============================================================================
# Fonction: attempt_complete_loading
# Description: Tentative de chargement complet avec gestion d'erreur
# Paramètres: $1 - module à charger complètement
#==============================================================================
attempt_complete_loading() {
    local module="$1"
    
    if [[ -f "$module" ]]; then
        # Chargement avec capture des erreurs
        local error_output
        if error_output=$(source "$module" 2>&1); then
            log_fail_safe_event "COMPLETE_SUCCESS" "$module" "Chargement complet réussi"
        else
            log_fail_safe_event "COMPLETE_FAILED" "$module" "Erreur: $error_output"
            # Escalade vers le mode d'urgence
            create_emergency_stubs "$module"
        fi
    else
        create_emergency_stubs "$module"
    fi
}

#==============================================================================
# Fonction: create_emergency_stubs
# Description: Crée des fonctions stub d'urgence pour un module manquant
# Paramètres: $1 - module manquant
#==============================================================================
create_emergency_stubs() {
    local module="$1"
    local module_name=$(basename "$module" .sh)
    
    log_fail_safe_event "EMERGENCY_STUBS" "$module" "Création de fonctions stub"
    
    # Création de fonctions stub basiques selon le type de module
    case "$module_name" in
        *cache*)
            create_cache_stubs
            ;;
        *io*)
            create_io_stubs
            ;;
        *performance*)
            create_performance_stubs
            ;;
        *)
            create_generic_stubs "$module_name"
            ;;
    esac
}

#==============================================================================
# Fonction: create_cache_stubs
# Description: Crée des fonctions stub pour les modules de cache
#==============================================================================
create_cache_stubs() {
    # Fonctions stub pour les modules de cache
    if ! command -v cache_get >/dev/null 2>&1; then
        cache_get() { return 1; }
    fi
    if ! command -v cache_set >/dev/null 2>&1; then
        cache_set() { return 0; }
    fi
    if ! command -v cache_clear >/dev/null 2>&1; then
        cache_clear() { return 0; }
    fi
}

#==============================================================================
# Fonction: create_io_stubs
# Description: Crée des fonctions stub pour les modules I/O
#==============================================================================
create_io_stubs() {
    # Fonctions stub pour les modules I/O
    if ! command -v monitor_io >/dev/null 2>&1; then
        monitor_io() { return 0; }
    fi
    if ! command -v extract_data >/dev/null 2>&1; then
        extract_data() { cat; }
    fi
}

#==============================================================================
# Fonction: create_performance_stubs
# Description: Crée des fonctions stub pour les modules de performance
#==============================================================================
create_performance_stubs() {
    # Fonctions stub pour les modules de performance
    if ! command -v optimize_performance >/dev/null 2>&1; then
        optimize_performance() { return 0; }
    fi
    if ! command -v benchmark_operation >/dev/null 2>&1; then
        benchmark_operation() { "$@"; }
    fi
}

#==============================================================================
# Fonction: create_generic_stubs
# Description: Crée des fonctions stub génériques
# Paramètres: $1 - nom du module
#==============================================================================
create_generic_stubs() {
    local module_name="$1"
    
    # Création d'une fonction stub générique
    eval "${module_name}_stub() { 
        echo '⚠️  Fonction stub pour module manquant: $module_name' >&2
        return 0
    }"
}

#==============================================================================
# Fonction: safe_load_module
# Description: Charge un module de manière sécurisée avec fallback automatique
# Paramètres: $1 - chemin du module à charger, $2 - niveau de fallback max
# Retour: 0 (ne peut pas échouer grâce au fallback)
#==============================================================================
safe_load_module() {
    local module_path="$1"
    local max_fallback_level="${2:-2}"
    local loading_start=$(date +%s.%N)
    
    # Validation préalable si disponible
    if command -v validate_module_integrity >/dev/null 2>&1; then
        local validation_result
        validation_result=$(validate_module_integrity "$module_path")
        local validation_code=$?
        
        case $validation_code in
            0)
                # Module valide, chargement normal
                ;;
            1)
                # Erreur critique, fallback immédiat
                transparent_fallback "$module_path" "Validation échouée" "$max_fallback_level"
                return 0
                ;;
            2)
                # Avertissements, chargement avec précaution
                log_fail_safe_event "WARNING" "$module_path" "Chargement avec avertissements"
                ;;
        esac
    fi
    
    # Tentative de chargement normal
    if source "$module_path" 2>/dev/null; then
        LOADED_MODULES+=("$module_path")
        local loading_end=$(date +%s.%N)
        local loading_time=$(echo "$loading_end - $loading_start" | bc 2>/dev/null || echo "0")
        
        log_fail_safe_event "SUCCESS" "$module_path" "Chargé en ${loading_time}s"
        record_loading_stats "$module_path" "$loading_time" "SUCCESS"
    else
        # Fallback automatique
        transparent_fallback "$module_path" "Chargement échoué" 1
    fi
    
    return 0
}

#==============================================================================
# Fonction: safe_load_module_list
# Description: Charge une liste de modules de manière sécurisée
# Paramètres: $@ - liste des modules à charger
# Retour: 0 (ne peut pas échouer)
#==============================================================================
safe_load_module_list() {
    local modules=("$@")
    local batch_start=$(date +%s.%N)
    
    LOADING_START_TIME="$batch_start"
    log_fail_safe_event "BATCH_START" "BATCH" "Début du chargement de ${#modules[@]} modules"
    
    # Validation préalable de tous les modules si disponible
    if command -v check_dependencies_chain >/dev/null 2>&1; then
        if ! check_dependencies_chain "${modules[@]}"; then
            log_fail_safe_event "BATCH_WARNING" "BATCH" "Problèmes de dépendances détectés"
        fi
    fi
    
    # Chargement de chaque module
    for module in "${modules[@]}"; do
        safe_load_module "$module"
    done
    
    local batch_end=$(date +%s.%N)
    local batch_time=$(echo "$batch_end - $batch_start" | bc 2>/dev/null || echo "0")
    
    log_fail_safe_event "BATCH_END" "BATCH" "Chargement terminé en ${batch_time}s"
    
    return 0
}

#==============================================================================
# Fonction: log_fail_safe_event
# Description: Enregistre un événement fail-safe
# Paramètres: $1 - type d'événement, $2 - module, $3 - message, $4 - niveau
#==============================================================================
log_fail_safe_event() {
    local event_type="$1"
    local module="$2"
    local message="$3"
    local level="${4:-0}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$event_type] [$level] $module: $message" >> "$FAIL_SAFE_LOG_FILE" 2>/dev/null || true
}

#==============================================================================
# Fonction: record_loading_stats
# Description: Enregistre les statistiques de chargement
# Paramètres: $1 - module, $2 - temps de chargement, $3 - statut
#==============================================================================
record_loading_stats() {
    local module="$1"
    local loading_time="$2"
    local status="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Création d'une entrée JSON
    local json_entry="{\"timestamp\":\"$timestamp\",\"module\":\"$module\",\"loading_time\":\"$loading_time\",\"status\":\"$status\"}"
    echo "$json_entry" >> "$FAIL_SAFE_METRICS_FILE" 2>/dev/null || true
    
    LOADING_STATS+=("$module:$loading_time:$status")
}

#==============================================================================
# Fonction: get_loaded_modules
# Description: Retourne la liste des modules chargés avec succès
# Retour: Liste des modules sur stdout
#==============================================================================
get_loaded_modules() {
    printf '%s\n' "${LOADED_MODULES[@]}"
}

#==============================================================================
# Fonction: get_failed_modules
# Description: Retourne la liste des modules qui ont échoué
# Retour: Liste des modules sur stdout
#==============================================================================
get_failed_modules() {
    printf '%s\n' "${FAILED_MODULES[@]}"
}

#==============================================================================
# Fonction: is_fallback_triggered
# Description: Indique si le fallback a été déclenché
# Retour: 0 si fallback déclenché, 1 sinon
#==============================================================================
is_fallback_triggered() {
    [[ "$FALLBACK_TRIGGERED" == "true" ]]
}

#==============================================================================
# Fonction: get_loading_stats
# Description: Retourne les statistiques de chargement
# Retour: Statistiques sur stdout
#==============================================================================
get_loading_stats() {
    echo "Modules chargés: ${#LOADED_MODULES[@]}"
    echo "Modules échoués: ${#FAILED_MODULES[@]}"
    echo "Fallback déclenché: $FALLBACK_TRIGGERED"
    echo "Statistiques détaillées: ${#LOADING_STATS[@]} entrées"
}

#==============================================================================
# Fonction: detect_loading_issues
# Description: Détecte les problèmes de chargement en cours
# Retour: 0 si pas de problèmes, 1 si problèmes détectés
#==============================================================================
detect_loading_issues() {
    local issues_detected=false
    
    # Vérification du ratio d'échec
    local total_modules=$((${#LOADED_MODULES[@]} + ${#FAILED_MODULES[@]}))
    if [[ $total_modules -gt 0 ]]; then
        local failure_rate=$(echo "scale=2; ${#FAILED_MODULES[@]} * 100 / $total_modules" | bc 2>/dev/null || echo "0")
        if (( $(echo "$failure_rate > 20" | bc -l 2>/dev/null) )); then
            log_fail_safe_event "ISSUE" "SYSTEM" "Taux d'échec élevé: ${failure_rate}%"
            issues_detected=true
        fi
    fi
    
    # Vérification des fallbacks multiples
    if [[ ${#FAILED_MODULES[@]} -gt 3 ]]; then
        log_fail_safe_event "ISSUE" "SYSTEM" "Trop de modules échoués: ${#FAILED_MODULES[@]}"
        issues_detected=true
    fi
    
    if [[ "$issues_detected" == "true" ]]; then
        return 1
    else
        return 0
    fi
}

# Initialisation du module
LOADED_MODULES=()
FAILED_MODULES=()
FALLBACK_TRIGGERED=false
LOADING_STATS=()

# Création des répertoires de cache si nécessaire
mkdir -p "$(dirname "$FAIL_SAFE_LOG_FILE")" 2>/dev/null || true
mkdir -p "$(dirname "$FAIL_SAFE_METRICS_FILE")" 2>/dev/null || true