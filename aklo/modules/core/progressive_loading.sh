#!/usr/bin/env bash

#==============================================================================
# Progressive Loading - Architecture Fail-Safe TASK-13-8
#
# Auteur: AI_Agent
# Version: 1.0
# Module de chargement progressif avec escalation automatique
#
# Ce module implémente un système de chargement progressif intelligent
# qui adapte le niveau de modules chargés selon les besoins détectés,
# avec escalation automatique et fallback transparent.
#==============================================================================

# Configuration de base
set -e

# Source des modules requis
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "${script_dir}/validation_engine.sh" 2>/dev/null || {
    echo "⚠️  Validation engine non disponible - mode dégradé" >&2
}
source "${script_dir}/fail_safe_loader.sh" 2>/dev/null || {
    echo "⚠️  Fail safe loader non disponible - mode dégradé" >&2
}

# Variables globales
PROGRESSIVE_LOG_FILE="${AKLO_CACHE_DIR:-/tmp}/progressive_loading.log"
PROGRESSIVE_METRICS_FILE="${AKLO_CACHE_DIR:-/tmp}/progressive_metrics.json"
CURRENT_PROFILE="MINIMAL"
ESCALATION_TRIGGERED=false
ESCALATION_HISTORY=()
LOADING_PERFORMANCE=()

# Définition des profils de chargement avec priorités
declare -A PROFILE_MODULES
PROFILE_MODULES[MINIMAL]="core"
PROFILE_MODULES[NORMAL]="core,cache_basic"
PROFILE_MODULES[FULL]="core,cache_basic,cache_advanced,io,perf"
PROFILE_MODULES[EMERGENCY]="core"

# Définition des seuils de performance pour escalation
declare -A PERFORMANCE_THRESHOLDS
PERFORMANCE_THRESHOLDS[MINIMAL]="0.050"    # 50ms max pour commandes simples
PERFORMANCE_THRESHOLDS[NORMAL]="0.200"     # 200ms max pour commandes normales
PERFORMANCE_THRESHOLDS[FULL]="1.000"       # 1s max pour commandes complexes

# Mapping des modules vers leurs chemins
declare -A MODULE_PATHS
MODULE_PATHS[core]="core/validation_engine.sh core/fail_safe_loader.sh"
MODULE_PATHS[cache_basic]="cache/cache_functions.sh cache/id_cache.sh"
MODULE_PATHS[cache_advanced]="cache/regex_cache.sh cache/batch_io.sh cache/cache_monitoring.sh"
MODULE_PATHS[io]="io/extract_functions.sh io/io_monitoring.sh"
MODULE_PATHS[perf]="performance/performance_tuning.sh"

#==============================================================================
# Fonction: progressive_load_with_escalation
# Description: Charge les modules progressivement avec escalation automatique
# Paramètres: $1 - profil de départ, $2 - répertoire des modules, $3 - commande cible
# Retour: 0 (ne peut pas échouer)
#==============================================================================
progressive_load_with_escalation() {
    local target_profile="${1:-MINIMAL}"
    local modules_base_dir="${2:-$(dirname "$script_dir")/modules}"
    local target_command="${3:-unknown}"
    local loading_start=$(date +%s.%N)
    
    CURRENT_PROFILE="$target_profile"
    
    # Log du début du chargement progressif
    log_progressive_event "START" "$target_profile" "Démarrage pour commande: $target_command"
    
    # Analyse des besoins basée sur la commande
    local optimized_profile
    optimized_profile=$(analyze_command_requirements "$target_command" "$target_profile")
    
    if [[ "$optimized_profile" != "$target_profile" ]]; then
        log_progressive_event "OPTIMIZATION" "$target_profile" "Profil optimisé: $optimized_profile"
        target_profile="$optimized_profile"
        CURRENT_PROFILE="$target_profile"
    fi
    
    # Chargement selon le profil optimisé
    case "$target_profile" in
        "MINIMAL")
            load_profile_minimal "$modules_base_dir"
            ;;
        "NORMAL")
            load_profile_normal "$modules_base_dir"
            ;;
        "FULL")
            load_profile_full "$modules_base_dir"
            ;;
        "EMERGENCY")
            load_profile_emergency "$modules_base_dir"
            ;;
        *)
            log_progressive_event "WARNING" "$target_profile" "Profil inconnu - fallback vers MINIMAL"
            load_profile_minimal "$modules_base_dir"
            ;;
    esac
    
    # Calcul du temps de chargement
    local loading_end=$(date +%s.%N)
    local loading_time=$(echo "$loading_end - $loading_start" | bc 2>/dev/null || echo "0")
    
    # Vérification des seuils de performance
    check_performance_thresholds "$target_profile" "$loading_time"
    
    # Enregistrement des métriques
    record_progressive_metrics "$target_profile" "$loading_time" "$target_command"
    
    log_progressive_event "COMPLETE" "$target_profile" "Chargement terminé en ${loading_time}s"
    
    return 0
}

#==============================================================================
# Fonction: analyze_command_requirements
# Description: Analyse les besoins d'une commande pour optimiser le profil
# Paramètres: $1 - commande, $2 - profil par défaut
# Retour: Profil optimisé sur stdout
#==============================================================================
analyze_command_requirements() {
    local command="$1"
    local default_profile="$2"
    
    # Analyse basée sur des patterns de commandes connues
    case "$command" in
        "get_config"|"status"|"version"|"help")
            echo "MINIMAL"
            ;;
        "plan"|"dev"|"debug"|"review")
            echo "NORMAL"
            ;;
        "optimize"|"benchmark"|"monitor"|"perf")
            echo "FULL"
            ;;
        *)
            # Analyse heuristique pour commandes inconnues
            analyze_unknown_command "$command" "$default_profile"
            ;;
    esac
}

#==============================================================================
# Fonction: analyze_unknown_command
# Description: Analyse heuristique pour commandes inconnues
# Paramètres: $1 - commande, $2 - profil par défaut
# Retour: Profil recommandé sur stdout
#==============================================================================
analyze_unknown_command() {
    local command="$1"
    local default_profile="$2"
    
    # Heuristiques basées sur le nom de la commande
    if [[ "$command" =~ (cache|regex|batch) ]]; then
        echo "NORMAL"
    elif [[ "$command" =~ (perf|optim|bench|monitor) ]]; then
        echo "FULL"
    elif [[ "$command" =~ (get|show|list|info|stat) ]]; then
        echo "MINIMAL"
    else
        # Utilisation de l'historique si disponible
        local historical_profile
        historical_profile=$(get_historical_profile "$command")
        if [[ -n "$historical_profile" ]]; then
            echo "$historical_profile"
        else
            echo "$default_profile"
        fi
    fi
}

#==============================================================================
# Fonction: get_historical_profile
# Description: Récupère le profil historique d'une commande
# Paramètres: $1 - commande
# Retour: Profil historique ou vide
#==============================================================================
get_historical_profile() {
    local command="$1"
    
    # Recherche dans l'historique des métriques
    if [[ -f "$PROGRESSIVE_METRICS_FILE" ]]; then
        local last_profile
        last_profile=$(grep "\"command\":\"$command\"" "$PROGRESSIVE_METRICS_FILE" 2>/dev/null | tail -1 | sed 's/.*"profile":"\([^"]*\)".*/\1/')
        if [[ -n "$last_profile" ]]; then
            echo "$last_profile"
        fi
    fi
}

#==============================================================================
# Fonction: load_profile_minimal
# Description: Charge uniquement les modules core essentiels
# Paramètres: $1 - répertoire de base des modules
#==============================================================================
load_profile_minimal() {
    local modules_dir="$1"
    
    log_progressive_event "PROFILE" "MINIMAL" "Chargement des modules core"
    
    # Modules core essentiels
    local core_modules=()
    IFS=' ' read -ra module_list <<< "${MODULE_PATHS[core]}"
    for module in "${module_list[@]}"; do
        core_modules+=("${modules_dir}/${module}")
    done
    
    # Chargement sécurisé
    if command -v safe_load_module_list >/dev/null 2>&1; then
        safe_load_module_list "${core_modules[@]}"
    else
        load_modules_fallback "${core_modules[@]}"
    fi
}

#==============================================================================
# Fonction: load_profile_normal
# Description: Charge les modules core + cache basique
# Paramètres: $1 - répertoire de base des modules
#==============================================================================
load_profile_normal() {
    local modules_dir="$1"
    
    log_progressive_event "PROFILE" "NORMAL" "Chargement core + cache basique"
    
    # Chargement du profil minimal d'abord
    load_profile_minimal "$modules_dir"
    
    # Ajout des modules cache basiques
    local cache_modules=()
    IFS=' ' read -ra module_list <<< "${MODULE_PATHS[cache_basic]}"
    for module in "${module_list[@]}"; do
        cache_modules+=("${modules_dir}/${module}")
    done
    
    # Chargement sécurisé
    if command -v safe_load_module_list >/dev/null 2>&1; then
        safe_load_module_list "${cache_modules[@]}"
    else
        load_modules_fallback "${cache_modules[@]}"
    fi
}

#==============================================================================
# Fonction: load_profile_full
# Description: Charge tous les modules disponibles
# Paramètres: $1 - répertoire de base des modules
#==============================================================================
load_profile_full() {
    local modules_dir="$1"
    
    log_progressive_event "PROFILE" "FULL" "Chargement complet de tous les modules"
    
    # Chargement du profil normal d'abord
    load_profile_normal "$modules_dir"
    
    # Ajout de tous les modules avancés
    local advanced_modules=()
    
    # Cache avancé
    IFS=' ' read -ra module_list <<< "${MODULE_PATHS[cache_advanced]}"
    for module in "${module_list[@]}"; do
        advanced_modules+=("${modules_dir}/${module}")
    done
    
    # Modules I/O
    IFS=' ' read -ra module_list <<< "${MODULE_PATHS[io]}"
    for module in "${module_list[@]}"; do
        advanced_modules+=("${modules_dir}/${module}")
    done
    
    # Modules de performance
    IFS=' ' read -ra module_list <<< "${MODULE_PATHS[perf]}"
    for module in "${module_list[@]}"; do
        advanced_modules+=("${modules_dir}/${module}")
    done
    
    # Chargement sécurisé
    if command -v safe_load_module_list >/dev/null 2>&1; then
        safe_load_module_list "${advanced_modules[@]}"
    else
        load_modules_fallback "${advanced_modules[@]}"
    fi
}

#==============================================================================
# Fonction: load_profile_emergency
# Description: Charge uniquement les modules absolument essentiels
# Paramètres: $1 - répertoire de base des modules
#==============================================================================
load_profile_emergency() {
    local modules_dir="$1"
    
    log_progressive_event "PROFILE" "EMERGENCY" "Chargement d'urgence - modules essentiels uniquement"
    
    # Chargement minimal avec création de stubs pour le reste
    local emergency_modules=(
        "${modules_dir}/core/validation_engine.sh"
        "${modules_dir}/core/fail_safe_loader.sh"
    )
    
    # Chargement avec fallback maximum
    for module in "${emergency_modules[@]}"; do
        if command -v safe_load_module >/dev/null 2>&1; then
            safe_load_module "$module" 3
        else
            source "$module" 2>/dev/null || {
                log_progressive_event "EMERGENCY" "$module" "Échec du chargement d'urgence"
            }
        fi
    done
    
    # Création de stubs pour tous les autres modules
    if command -v create_emergency_stubs >/dev/null 2>&1; then
        create_emergency_stubs "cache_functions"
        create_emergency_stubs "io_monitoring"
        create_emergency_stubs "performance_tuning"
    fi
}

#==============================================================================
# Fonction: load_modules_fallback
# Description: Chargement de fallback sans fail_safe_loader
# Paramètres: $@ - liste des modules à charger
#==============================================================================
load_modules_fallback() {
    local modules=("$@")
    
    for module in "${modules[@]}"; do
        if [[ -f "$module" ]]; then
            source "$module" 2>/dev/null || {
                log_progressive_event "FALLBACK" "$module" "Chargement fallback échoué"
            }
        fi
    done
}

#==============================================================================
# Fonction: escalate_profile
# Description: Escalade automatique vers un profil supérieur
# Paramètres: $1 - profil cible, $2 - raison de l'escalation
#==============================================================================
escalate_profile() {
    local target_profile="$1"
    local escalation_reason="${2:-Escalation automatique}"
    
    if [[ "$target_profile" != "$CURRENT_PROFILE" ]]; then
        ESCALATION_TRIGGERED=true
        ESCALATION_HISTORY+=("$CURRENT_PROFILE->$target_profile:$escalation_reason")
        
        log_progressive_event "ESCALATION" "$CURRENT_PROFILE" "Vers $target_profile: $escalation_reason"
        
        # Chargement du nouveau profil
        local modules_dir="$(dirname "$script_dir")/modules"
        progressive_load_with_escalation "$target_profile" "$modules_dir" "escalated"
    fi
}

#==============================================================================
# Fonction: check_performance_thresholds
# Description: Vérifie les seuils de performance et déclenche l'escalation si nécessaire
# Paramètres: $1 - profil actuel, $2 - temps de chargement
#==============================================================================
check_performance_thresholds() {
    local current_profile="$1"
    local loading_time="$2"
    
    local threshold="${PERFORMANCE_THRESHOLDS[$current_profile]}"
    if [[ -n "$threshold" ]]; then
        # Comparaison des temps (nécessite bc pour les nombres décimaux)
        if command -v bc >/dev/null 2>&1; then
            if (( $(echo "$loading_time > $threshold" | bc -l) )); then
                log_progressive_event "PERFORMANCE" "$current_profile" "Seuil dépassé: ${loading_time}s > ${threshold}s"
                
                # Escalation si possible
                case "$current_profile" in
                    "MINIMAL")
                        escalate_profile "EMERGENCY" "Performance dégradée sur MINIMAL"
                        ;;
                    "NORMAL")
                        escalate_profile "MINIMAL" "Performance dégradée sur NORMAL"
                        ;;
                    "FULL")
                        escalate_profile "NORMAL" "Performance dégradée sur FULL"
                        ;;
                esac
            fi
        fi
    fi
}

#==============================================================================
# Fonction: record_progressive_metrics
# Description: Enregistre les métriques de chargement progressif
# Paramètres: $1 - profil, $2 - temps, $3 - commande
#==============================================================================
record_progressive_metrics() {
    local profile="$1"
    local loading_time="$2"
    local command="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Création d'une entrée JSON détaillée
    local json_entry="{\"timestamp\":\"$timestamp\",\"profile\":\"$profile\",\"loading_time\":\"$loading_time\",\"command\":\"$command\",\"escalation\":$ESCALATION_TRIGGERED}"
    echo "$json_entry" >> "$PROGRESSIVE_METRICS_FILE" 2>/dev/null || true
    
    LOADING_PERFORMANCE+=("$profile:$loading_time:$command")
}

#==============================================================================
# Fonction: log_progressive_event
# Description: Enregistre un événement de chargement progressif
# Paramètres: $1 - type, $2 - profil, $3 - message
#==============================================================================
log_progressive_event() {
    local event_type="$1"
    local profile="$2"
    local message="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$event_type] [$profile] $message" >> "$PROGRESSIVE_LOG_FILE" 2>/dev/null || true
}

#==============================================================================
# Fonction: get_current_profile
# Description: Retourne le profil actuellement chargé
#==============================================================================
get_current_profile() {
    echo "$CURRENT_PROFILE"
}

#==============================================================================
# Fonction: get_escalation_history
# Description: Retourne l'historique des escalations
#==============================================================================
get_escalation_history() {
    printf '%s\n' "${ESCALATION_HISTORY[@]}"
}

#==============================================================================
# Fonction: get_progressive_stats
# Description: Retourne les statistiques de chargement progressif
#==============================================================================
get_progressive_stats() {
    echo "Profil actuel: $CURRENT_PROFILE"
    echo "Escalations: ${#ESCALATION_HISTORY[@]}"
    echo "Performances: ${#LOADING_PERFORMANCE[@]} mesures"
    echo "Escalation déclenchée: $ESCALATION_TRIGGERED"
}

#==============================================================================
# Fonction: optimize_future_loading
# Description: Optimise les futurs chargements basés sur l'historique
#==============================================================================
optimize_future_loading() {
    local command="$1"
    
    # Analyse de l'historique pour optimiser
    if [[ -f "$PROGRESSIVE_METRICS_FILE" ]]; then
        local avg_time
        avg_time=$(grep "\"command\":\"$command\"" "$PROGRESSIVE_METRICS_FILE" 2>/dev/null | \
                   sed 's/.*"loading_time":"\([^"]*\)".*/\1/' | \
                   awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
        
        if [[ -n "$avg_time" ]] && (( $(echo "$avg_time > 0" | bc -l 2>/dev/null) )); then
            log_progressive_event "OPTIMIZATION" "$command" "Temps moyen historique: ${avg_time}s"
        fi
    fi
}

# Initialisation du module
CURRENT_PROFILE="MINIMAL"
ESCALATION_TRIGGERED=false
ESCALATION_HISTORY=()
LOADING_PERFORMANCE=()

# Création des répertoires de cache si nécessaire
mkdir -p "$(dirname "$PROGRESSIVE_LOG_FILE")" 2>/dev/null || true
mkdir -p "$(dirname "$PROGRESSIVE_METRICS_FILE")" 2>/dev/null || true