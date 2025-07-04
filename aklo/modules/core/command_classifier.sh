#!/bin/bash

#==============================================================================
# Command Classifier - Classification automatique des commandes TASK-13-1
#
# Auteur: AI_Agent
# Version: 2.0 (Amélioré)
# Module de classification automatique des commandes aklo avec profils adaptatifs
#==============================================================================

# Configuration de base
set -e

# Variables de configuration
CLASSIFIER_CONFIG_FILE="${AKLO_CONFIG_DIR:-/tmp}/classifier_config.json"
CLASSIFIER_CACHE_FILE="${AKLO_CACHE_DIR:-/tmp}/classifier_cache.json"
CLASSIFIER_LOG_FILE="${AKLO_CACHE_DIR:-/tmp}/classifier.log"

# Définition des profils de chargement
declare -A COMMAND_PROFILES
declare -A PROFILE_MODULES
declare -A PROFILE_PERFORMANCE_TARGETS
declare -A COMMAND_METADATA

# Cache simple pour les classifications récentes
declare -A CLASSIFICATION_CACHE

# Profils et leurs modules associés avec gestion hiérarchique
PROFILE_MODULES[MINIMAL]="core"
PROFILE_MODULES[NORMAL]="core,cache_basic,io_basic"
PROFILE_MODULES[FULL]="core,cache_basic,cache_advanced,io,perf,monitoring"
PROFILE_MODULES[AUTO]="auto"

# Objectifs de performance par profil (en secondes)
PROFILE_PERFORMANCE_TARGETS[MINIMAL]="0.050"
PROFILE_PERFORMANCE_TARGETS[NORMAL]="0.200"
PROFILE_PERFORMANCE_TARGETS[FULL]="1.000"
PROFILE_PERFORMANCE_TARGETS[AUTO]="0.100"

# Classification des commandes connues avec métadonnées
# Profil MINIMAL - Commandes simples et rapides
COMMAND_PROFILES[get_config]="MINIMAL"
COMMAND_PROFILES[status]="MINIMAL"
COMMAND_PROFILES[version]="MINIMAL"
COMMAND_PROFILES[help]="MINIMAL"
COMMAND_PROFILES[list]="MINIMAL"
COMMAND_PROFILES[info]="MINIMAL"

# Métadonnées des commandes MINIMAL
COMMAND_METADATA[get_config]="type:query,io:none,cache:none,complexity:low"
COMMAND_METADATA[status]="type:query,io:light,cache:none,complexity:low"
COMMAND_METADATA[version]="type:query,io:none,cache:none,complexity:low"
COMMAND_METADATA[help]="type:query,io:none,cache:none,complexity:low"

# Profil NORMAL - Commandes de développement standard
COMMAND_PROFILES[plan]="NORMAL"
COMMAND_PROFILES[dev]="NORMAL"
COMMAND_PROFILES[debug]="NORMAL"
COMMAND_PROFILES[review]="NORMAL"
COMMAND_PROFILES[new]="NORMAL"
COMMAND_PROFILES[template]="NORMAL"
COMMAND_PROFILES[create]="NORMAL"
COMMAND_PROFILES[edit]="NORMAL"

# Métadonnées des commandes NORMAL
COMMAND_METADATA[plan]="type:workflow,io:medium,cache:basic,complexity:medium"
COMMAND_METADATA[dev]="type:workflow,io:medium,cache:basic,complexity:medium"
COMMAND_METADATA[debug]="type:diagnostic,io:medium,cache:basic,complexity:medium"
COMMAND_METADATA[review]="type:analysis,io:medium,cache:basic,complexity:medium"

# Profil FULL - Commandes avancées et optimisations
COMMAND_PROFILES[optimize]="FULL"
COMMAND_PROFILES[benchmark]="FULL"
COMMAND_PROFILES[cache]="FULL"
COMMAND_PROFILES[monitor]="FULL"
COMMAND_PROFILES[diagnose]="FULL"
COMMAND_PROFILES[batch]="FULL"
COMMAND_PROFILES[performance]="FULL"

# Métadonnées des commandes FULL
COMMAND_METADATA[optimize]="type:optimization,io:heavy,cache:advanced,complexity:high"
COMMAND_METADATA[benchmark]="type:performance,io:heavy,cache:advanced,complexity:high"
COMMAND_METADATA[cache]="type:system,io:heavy,cache:advanced,complexity:high"
COMMAND_METADATA[monitor]="type:monitoring,io:heavy,cache:advanced,complexity:high"

#==============================================================================
# Fonction: classify_command
# Description: Classifie une commande et retourne le profil requis
# Paramètres: $1 - nom de la commande
# Retour: Profil requis (MINIMAL/NORMAL/FULL/AUTO) sur stdout
#==============================================================================
classify_command() {
    local command="$1"
    
    # Validation de l'entrée
    if [[ -z "$command" ]]; then
        echo "AUTO"
        return 0
    fi
    
    # Nettoyage du nom de commande
    command=$(echo "$command" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    
    # Vérification du cache en mémoire (plus rapide)
    if [[ -n "${CLASSIFICATION_CACHE[$command]}" ]]; then
        echo "${CLASSIFICATION_CACHE[$command]}"
        return 0
    fi
    
    # Vérification du cache persistant
    local cached_result
    cached_result=$(get_cached_classification "$command")
    if [[ -n "$cached_result" ]]; then
        # Mise en cache en mémoire
        CLASSIFICATION_CACHE[$command]="$cached_result"
        echo "$cached_result"
        return 0
    fi
    
    # Vérification si la commande est connue
    if [[ -n "${COMMAND_PROFILES[$command]}" ]]; then
        local profile="${COMMAND_PROFILES[$command]}"
        # Mise en cache en mémoire
        CLASSIFICATION_CACHE[$command]="$profile"
        cache_classification "$command" "$profile"
        log_classification "$command" "$profile" "known"
        echo "$profile"
        return 0
    fi
    
    # Commande inconnue - utilisation du learning engine si disponible
    if command -v predict_command_profile >/dev/null 2>&1; then
        local predicted_profile
        predicted_profile=$(predict_command_profile "$command")
        if [[ -n "$predicted_profile" && "$predicted_profile" != "AUTO" ]]; then
            # Mise en cache en mémoire
            CLASSIFICATION_CACHE[$command]="$predicted_profile"
            cache_classification "$command" "$predicted_profile"
            log_classification "$command" "$predicted_profile" "learned"
            echo "$predicted_profile"
            return 0
        fi
    fi
    
    # Fallback vers classification heuristique avancée
    local heuristic_profile
    heuristic_profile=$(classify_command_heuristic_advanced "$command")
    # Mise en cache en mémoire
    CLASSIFICATION_CACHE[$command]="$heuristic_profile"
    cache_classification "$command" "$heuristic_profile"
    log_classification "$command" "$heuristic_profile" "heuristic"
    echo "$heuristic_profile"
}

#==============================================================================
# Fonction: classify_command_heuristic_advanced
# Description: Classification heuristique avancée pour commandes inconnues
# Paramètres: $1 - nom de la commande
# Retour: Profil estimé sur stdout
#==============================================================================
classify_command_heuristic_advanced() {
    local command="$1"
    local score_minimal=0
    local score_normal=0
    local score_full=0
    
    # Analyse des patterns de noms avec scoring
    # Patterns MINIMAL (commandes légères)
    if [[ "$command" =~ ^(get|show|list|info|stat|help|version|check)$ ]]; then
        score_minimal=$((score_minimal + 50))
    fi
    if [[ "$command" =~ (get|show|list|info|stat|help|version|check) ]]; then
        score_minimal=$((score_minimal + 30))
    fi
    
    # Patterns NORMAL (commandes de développement)
    if [[ "$command" =~ ^(plan|dev|debug|review|new|create|edit|template|test|build)$ ]]; then
        score_normal=$((score_normal + 50))
    fi
    if [[ "$command" =~ (plan|dev|debug|review|new|create|edit|template|test|build) ]]; then
        score_normal=$((score_normal + 30))
    fi
    
    # Patterns FULL (commandes avancées)
    if [[ "$command" =~ ^(optim|bench|perf|monitor|diagnose|cache|batch|analyze)$ ]]; then
        score_full=$((score_full + 50))
    fi
    if [[ "$command" =~ (optim|bench|perf|monitor|diagnose|cache|batch|analyze) ]]; then
        score_full=$((score_full + 30))
    fi
    
    # Analyse de la longueur du nom (heuristique)
    local cmd_length=${#command}
    if (( cmd_length <= 5 )); then
        score_minimal=$((score_minimal + 10))
    elif (( cmd_length <= 10 )); then
        score_normal=$((score_normal + 10))
    else
        score_full=$((score_full + 10))
    fi
    
    # Analyse des suffixes/préfixes spéciaux
    case "$command" in
        *_test|test_*) score_normal=$((score_normal + 20)) ;;
        *_bench|bench_*) score_full=$((score_full + 20)) ;;
        *_cache|cache_*) score_full=$((score_full + 20)) ;;
        *_monitor|monitor_*) score_full=$((score_full + 20)) ;;
        *_get|get_*) score_minimal=$((score_minimal + 15)) ;;
        *_show|show_*) score_minimal=$((score_minimal + 15)) ;;
    esac
    
    # Détermination du profil basé sur le scoring
    if (( score_full > score_normal && score_full > score_minimal )); then
        echo "FULL"
    elif (( score_normal > score_minimal )); then
        echo "NORMAL"
    elif (( score_minimal > 0 )); then
        echo "MINIMAL"
    else
        # Aucun pattern reconnu - profil adaptatif
        echo "AUTO"
    fi
}

#==============================================================================
# Fonction: get_required_modules
# Description: Retourne la liste des modules requis pour un profil
# Paramètres: $1 - profil (MINIMAL/NORMAL/FULL/AUTO)
# Retour: Liste des modules séparés par des virgules
#==============================================================================
get_required_modules() {
    local profile="$1"
    
    case "$profile" in
        "MINIMAL"|"NORMAL"|"FULL")
            echo "${PROFILE_MODULES[$profile]}"
            ;;
        "AUTO")
            # Pour AUTO, on commence par MINIMAL et on escalade si nécessaire
            echo "${PROFILE_MODULES[MINIMAL]}"
            ;;
        *)
            # Profil inconnu - fallback vers MINIMAL
            echo "${PROFILE_MODULES[MINIMAL]}"
            ;;
    esac
}

#==============================================================================
# Fonction: get_profile_performance_target
# Description: Retourne l'objectif de performance pour un profil
# Paramètres: $1 - profil
# Retour: Objectif de performance en secondes
#==============================================================================
get_profile_performance_target() {
    local profile="$1"
    echo "${PROFILE_PERFORMANCE_TARGETS[$profile]:-0.100}"
}

#==============================================================================
# Fonction: detect_command_from_args
# Description: Détecte la commande principale depuis les arguments CLI
# Paramètres: $@ - arguments de la ligne de commande
# Retour: Commande détectée sur stdout
#==============================================================================
detect_command_from_args() {
    local args=("$@")
    
    # Détection avancée avec gestion des sous-commandes
    local main_command=""
    local sub_command=""
    
    for arg in "${args[@]}"; do
        # Ignore les options (commençant par -)
        if [[ "$arg" != -* ]] && [[ -n "$arg" ]]; then
            if [[ -z "$main_command" ]]; then
                main_command="$arg"
            elif [[ -z "$sub_command" ]]; then
                sub_command="$arg"
                break
            fi
        fi
    done
    
    # Construction de la commande complète
    if [[ -n "$sub_command" ]]; then
        echo "${main_command}_${sub_command}"
    elif [[ -n "$main_command" ]]; then
        echo "$main_command"
    else
        echo ""
    fi
}

#==============================================================================
# Fonction: get_command_metadata
# Description: Retourne les métadonnées d'une commande
# Paramètres: $1 - commande
# Retour: Métadonnées sur stdout
#==============================================================================
get_command_metadata() {
    local command="$1"
    
    if [[ -n "${COMMAND_METADATA[$command]}" ]]; then
        echo "${COMMAND_METADATA[$command]}"
    else
        echo "type:unknown,io:unknown,cache:unknown,complexity:unknown"
    fi
}

#==============================================================================
# Fonction: cache_classification
# Description: Met en cache une classification
# Paramètres: $1 - commande, $2 - profil
#==============================================================================
cache_classification() {
    local command="$1"
    local profile="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Écriture dans le cache (format simple)
    echo "$timestamp|$command|$profile" >> "$CLASSIFIER_CACHE_FILE" 2>/dev/null || true
}

#==============================================================================
# Fonction: get_cached_classification
# Description: Récupère une classification depuis le cache
# Paramètres: $1 - commande
# Retour: Profil en cache ou vide
#==============================================================================
get_cached_classification() {
    local command="$1"
    
    if [[ -f "$CLASSIFIER_CACHE_FILE" ]]; then
        # Recherche de la dernière classification pour cette commande
        local cached_entry
        cached_entry=$(grep "|$command|" "$CLASSIFIER_CACHE_FILE" 2>/dev/null | tail -1)
        
        if [[ -n "$cached_entry" ]]; then
            echo "$cached_entry" | cut -d'|' -f3
        fi
    fi
}

#==============================================================================
# Fonction: log_classification
# Description: Enregistre une classification dans les logs
# Paramètres: $1 - commande, $2 - profil, $3 - source
#==============================================================================
log_classification() {
    local command="$1"
    local profile="$2"
    local source="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [CLASSIFY] $command -> $profile (source: $source)" >> "$CLASSIFIER_LOG_FILE" 2>/dev/null || true
}

#==============================================================================
# Fonction: get_command_profile_stats
# Description: Retourne les statistiques de classification
# Retour: Statistiques sur stdout
#==============================================================================
get_command_profile_stats() {
    local minimal_count=0
    local normal_count=0
    local full_count=0
    
    # Comptage des commandes par profil
    for command in "${!COMMAND_PROFILES[@]}"; do
        case "${COMMAND_PROFILES[$command]}" in
            "MINIMAL") minimal_count=$((minimal_count + 1)) ;;
            "NORMAL") normal_count=$((normal_count + 1)) ;;
            "FULL") full_count=$((full_count + 1)) ;;
        esac
    done
    
    echo "=== Statistiques Classification ==="
    echo "MINIMAL: $minimal_count commandes"
    echo "NORMAL: $normal_count commandes"
    echo "FULL: $full_count commandes"
    echo "Total: $((minimal_count + normal_count + full_count)) commandes"
    
    # Statistiques du cache
    if [[ -f "$CLASSIFIER_CACHE_FILE" ]]; then
        local cache_entries
        cache_entries=$(wc -l < "$CLASSIFIER_CACHE_FILE" 2>/dev/null || echo "0")
        echo "Cache: $cache_entries entrées"
    fi
}

#==============================================================================
# Fonction: add_command_classification
# Description: Ajoute une nouvelle classification de commande
# Paramètres: $1 - commande, $2 - profil, $3 - métadonnées (optionnel)
# Retour: 0 si succès, 1 si erreur
#==============================================================================
add_command_classification() {
    local command="$1"
    local profile="$2"
    local metadata="${3:-type:custom,io:unknown,cache:unknown,complexity:unknown}"
    
    # Validation du profil
    case "$profile" in
        "MINIMAL"|"NORMAL"|"FULL"|"AUTO")
            COMMAND_PROFILES[$command]="$profile"
            COMMAND_METADATA[$command]="$metadata"
            log_classification "$command" "$profile" "manual_add"
            return 0
            ;;
        *)
            echo "Erreur: Profil invalide '$profile'" >&2
            return 1
            ;;
    esac
}

#==============================================================================
# Fonction: is_known_command
# Description: Vérifie si une commande est connue
# Paramètres: $1 - commande
# Retour: 0 si connue, 1 sinon
#==============================================================================
is_known_command() {
    local command="$1"
    [[ -n "${COMMAND_PROFILES[$command]}" ]]
}

#==============================================================================
# Fonction: list_commands_by_profile
# Description: Liste les commandes d'un profil donné
# Paramètres: $1 - profil
# Retour: Liste des commandes sur stdout
#==============================================================================
list_commands_by_profile() {
    local target_profile="$1"
    
    echo "=== Commandes $target_profile ==="
    for command in "${!COMMAND_PROFILES[@]}"; do
        if [[ "${COMMAND_PROFILES[$command]}" == "$target_profile" ]]; then
            local metadata="${COMMAND_METADATA[$command]:-N/A}"
            echo "- $command ($metadata)"
        fi
    done
}

#==============================================================================
# Fonction: validate_classification_consistency
# Description: Valide la cohérence des classifications
# Retour: 0 si cohérent, 1 sinon
#==============================================================================
validate_classification_consistency() {
    local inconsistencies=0
    
    echo "=== Validation Cohérence Classifications ==="
    
    # Vérification que chaque commande a des métadonnées
    for command in "${!COMMAND_PROFILES[@]}"; do
        if [[ -z "${COMMAND_METADATA[$command]}" ]]; then
            echo "⚠️  Commande '$command' sans métadonnées"
            inconsistencies=$((inconsistencies + 1))
        fi
    done
    
    # Vérification des profils valides
    for command in "${!COMMAND_PROFILES[@]}"; do
        local profile="${COMMAND_PROFILES[$command]}"
        case "$profile" in
            "MINIMAL"|"NORMAL"|"FULL"|"AUTO")
                ;;
            *)
                echo "❌ Commande '$command' avec profil invalide '$profile'"
                inconsistencies=$((inconsistencies + 1))
                ;;
        esac
    done
    
    if (( inconsistencies == 0 )); then
        echo "✅ Toutes les classifications sont cohérentes"
        return 0
    else
        echo "❌ $inconsistencies incohérences détectées"
        return 1
    fi
}

#==============================================================================
# Fonction: cleanup_old_cache
# Description: Nettoie les anciennes entrées du cache
# Paramètres: $1 - âge maximum en jours (défaut: 7)
#==============================================================================
cleanup_old_cache() {
    local max_age_days="${1:-7}"
    
    if [[ -f "$CLASSIFIER_CACHE_FILE" ]]; then
        local cutoff_date
        cutoff_date=$(date -d "$max_age_days days ago" '+%Y-%m-%d' 2>/dev/null || date -v-"${max_age_days}d" '+%Y-%m-%d' 2>/dev/null)
        
        if [[ -n "$cutoff_date" ]]; then
            local temp_file="${CLASSIFIER_CACHE_FILE}.tmp"
            
            # Garde seulement les entrées récentes
            while IFS='|' read -r timestamp command profile; do
                local entry_date
                entry_date=$(echo "$timestamp" | cut -d' ' -f1)
                
                if [[ "$entry_date" > "$cutoff_date" ]]; then
                    echo "$timestamp|$command|$profile" >> "$temp_file"
                fi
            done < "$CLASSIFIER_CACHE_FILE" 2>/dev/null
            
            # Remplacement atomique
            if [[ -f "$temp_file" ]]; then
                mv "$temp_file" "$CLASSIFIER_CACHE_FILE"
                echo "Cache nettoyé (entrées > $max_age_days jours supprimées)"
            fi
        fi
    fi
}

# Initialisation du module
mkdir -p "$(dirname "$CLASSIFIER_CACHE_FILE")" 2>/dev/null || true
mkdir -p "$(dirname "$CLASSIFIER_LOG_FILE")" 2>/dev/null || true

# Nettoyage du cache au démarrage (garde 7 jours)
cleanup_old_cache 7 >/dev/null 2>&1 || true