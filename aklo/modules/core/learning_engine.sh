#!/bin/bash

#==============================================================================
# Learning Engine - Apprentissage automatique des commandes TASK-13-1
#
# Auteur: AI_Agent
# Version: 2.0 (Amélioré)
# Module d'apprentissage automatique pour classification des nouvelles commandes
#==============================================================================

# Configuration de base
set -e

# Variables globales
LEARNING_DB_FILE="${AKLO_CACHE_DIR:-/tmp}/learning_database.json"
LEARNING_LOG_FILE="${AKLO_CACHE_DIR:-/tmp}/learning_engine.log"
LEARNING_STATS_FILE="${AKLO_CACHE_DIR:-/tmp}/learning_stats.json"
LEARNING_BACKUP_DIR="${AKLO_CACHE_DIR:-/tmp}/learning_backups"

# Configuration d'apprentissage
LEARNING_CONFIDENCE_THRESHOLD=75
LEARNING_MAX_HISTORY=1000
LEARNING_BACKUP_INTERVAL=100

# Base de données d'apprentissage en mémoire
declare -A LEARNED_PATTERNS
declare -A COMMAND_USAGE_COUNT
declare -A COMMAND_PERFORMANCE_DATA
declare -A COMMAND_CONTEXT_HISTORY
declare -A SIMILARITY_CACHE

# Compteurs et statistiques
LEARNING_OPERATIONS_COUNT=0
PREDICTION_OPERATIONS_COUNT=0
CACHE_HIT_COUNT=0
CACHE_MISS_COUNT=0

#==============================================================================
# Fonction: learn_command_pattern
# Description: Apprend un nouveau pattern de commande avec validation
# Paramètres: $1 - commande, $2 - profil, $3 - contexte d'usage, $4 - confiance
# Retour: 0 si succès, 1 si erreur
#==============================================================================
learn_command_pattern() {
    local command="$1"
    local profile="$2"
    local usage_context="${3:-default}"
    local confidence="${4:-100}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Validation des entrées
    if [[ -z "$command" ]]; then
        echo "Erreur: Commande vide" >&2
        return 1
    fi
    
    # Validation du profil
    case "$profile" in
        "MINIMAL"|"NORMAL"|"FULL"|"AUTO")
            ;;
        *)
            echo "Erreur: Profil invalide '$profile'" >&2
            return 1
            ;;
    esac
    
    # Validation de la confiance
    if (( confidence < 0 || confidence > 100 )); then
        echo "Erreur: Confiance invalide '$confidence' (doit être 0-100)" >&2
        return 1
    fi
    
    # Nettoyage du nom de commande
    command=$(echo "$command" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    
    # Vérification si la commande existe déjà
    if [[ -n "${LEARNED_PATTERNS[$command]}" ]]; then
        # Mise à jour avec moyenne pondérée de confiance
        local existing_profile="${LEARNED_PATTERNS[$command]}"
        local existing_confidence="${COMMAND_CONTEXT_HISTORY[$command]##*:}"
        
        if [[ "$existing_profile" != "$profile" ]]; then
            # Conflit de profil - utilise la confiance la plus élevée
            if (( confidence > existing_confidence )); then
                LEARNED_PATTERNS[$command]="$profile"
                log_learning_event "UPDATE" "$command" "$profile" "conflict_resolved:$usage_context:confidence:$confidence"
            else
                log_learning_event "CONFLICT" "$command" "$existing_profile" "kept_existing:$usage_context:confidence:$existing_confidence"
                return 0
            fi
        fi
    else
        # Nouveau pattern
        LEARNED_PATTERNS[$command]="$profile"
        log_learning_event "LEARN" "$command" "$profile" "new:$usage_context:confidence:$confidence"
    fi
    
    # Mise à jour du compteur d'usage
    local current_count="${COMMAND_USAGE_COUNT[$command]:-0}"
    COMMAND_USAGE_COUNT[$command]=$((current_count + 1))
    
    # Stockage du contexte et de la confiance
    COMMAND_CONTEXT_HISTORY[$command]="$timestamp:$usage_context:$confidence"
    
    # Mise à jour des statistiques
    LEARNING_OPERATIONS_COUNT=$((LEARNING_OPERATIONS_COUNT + 1))
    
    # Sauvegarde périodique
    if (( LEARNING_OPERATIONS_COUNT % LEARNING_BACKUP_INTERVAL == 0 )); then
        backup_learning_database
    fi
    
    # Sauvegarde persistante
    save_learning_database
    
    return 0
}

#==============================================================================
# Fonction: predict_command_profile
# Description: Prédit le profil d'une commande avec algorithme amélioré
# Paramètres: $1 - commande
# Retour: Profil prédit sur stdout
#==============================================================================
predict_command_profile() {
    local command="$1"
    
    # Validation de l'entrée
    if [[ -z "$command" ]]; then
        echo "AUTO"
        return 0
    fi
    
    # Nettoyage du nom de commande
    command=$(echo "$command" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    
    # Mise à jour des statistiques
    PREDICTION_OPERATIONS_COUNT=$((PREDICTION_OPERATIONS_COUNT + 1))
    
    # Vérification si la commande a été apprise
    if [[ -n "${LEARNED_PATTERNS[$command]}" ]]; then
        local profile="${LEARNED_PATTERNS[$command]}"
        log_learning_event "PREDICT" "$command" "$profile" "direct_match"
        echo "$profile"
        return 0
    fi
    
    # Prédiction basée sur la similarité avec cache
    local predicted_profile
    predicted_profile=$(predict_by_similarity_cached "$command")
    
    if [[ -n "$predicted_profile" && "$predicted_profile" != "AUTO" ]]; then
        log_learning_event "PREDICT" "$command" "$predicted_profile" "similarity_match"
        echo "$predicted_profile"
        return 0
    fi
    
    # Prédiction basée sur des heuristiques avancées
    predicted_profile=$(predict_by_advanced_heuristics "$command")
    
    if [[ -n "$predicted_profile" && "$predicted_profile" != "AUTO" ]]; then
        log_learning_event "PREDICT" "$command" "$predicted_profile" "heuristic_match"
        echo "$predicted_profile"
        return 0
    fi
    
    # Prédiction basée sur l'analyse des patterns de noms
    predicted_profile=$(predict_by_name_analysis "$command")
    
    if [[ -n "$predicted_profile" ]]; then
        log_learning_event "PREDICT" "$command" "$predicted_profile" "name_analysis"
        echo "$predicted_profile"
        return 0
    fi
    
    # Fallback vers AUTO pour apprentissage futur
    log_learning_event "PREDICT" "$command" "AUTO" "fallback"
    echo "AUTO"
}

#==============================================================================
# Fonction: predict_by_similarity_cached
# Description: Prédiction avec cache de similarité
# Paramètres: $1 - commande
# Retour: Profil prédit ou vide
#==============================================================================
predict_by_similarity_cached() {
    local command="$1"
    
    # Vérification du cache
    if [[ -n "${SIMILARITY_CACHE[$command]}" ]]; then
        CACHE_HIT_COUNT=$((CACHE_HIT_COUNT + 1))
        echo "${SIMILARITY_CACHE[$command]}"
        return 0
    fi
    
    CACHE_MISS_COUNT=$((CACHE_MISS_COUNT + 1))
    
    local best_match=""
    local best_score=0
    local best_profile=""
    
    # Recherche de similarité avec les commandes apprises
    for learned_command in "${!LEARNED_PATTERNS[@]}"; do
        local score
        score=$(calculate_advanced_similarity_score "$command" "$learned_command")
        
        if (( score > best_score )); then
            best_score=$score
            best_match="$learned_command"
            best_profile="${LEARNED_PATTERNS[$learned_command]}"
        fi
    done
    
    # Si un bon match est trouvé (score > seuil de confiance)
    if (( best_score > LEARNING_CONFIDENCE_THRESHOLD )); then
        # Mise en cache
        SIMILARITY_CACHE[$command]="$best_profile"
        echo "$best_profile"
    else
        # Mise en cache du résultat négatif
        SIMILARITY_CACHE[$command]=""
        echo ""
    fi
}

#==============================================================================
# Fonction: calculate_advanced_similarity_score
# Description: Calcule un score de similarité avancé entre deux commandes
# Paramètres: $1 - commande 1, $2 - commande 2
# Retour: Score de similarité (0-100)
#==============================================================================
calculate_advanced_similarity_score() {
    local cmd1="$1"
    local cmd2="$2"
    
    # Initialisation du score
    local score=0
    
    # Similarité exacte
    if [[ "$cmd1" == "$cmd2" ]]; then
        echo "100"
        return 0
    fi
    
    # Longueurs des commandes
    local len1=${#cmd1}
    local len2=${#cmd2}
    local max_len=$((len1 > len2 ? len1 : len2))
    local min_len=$((len1 < len2 ? len1 : len2))
    
    # Pénalité pour différence de longueur
    local length_penalty=$(( (max_len - min_len) * 5 ))
    
    # Vérification des préfixes communs
    local common_prefix_len=0
    for (( i=0; i<min_len; i++ )); do
        if [[ "${cmd1:$i:1}" == "${cmd2:$i:1}" ]]; then
            common_prefix_len=$((common_prefix_len + 1))
        else
            break
        fi
    done
    
    # Score basé sur le préfixe commun
    if (( common_prefix_len > 0 )); then
        score=$((score + (common_prefix_len * 100 / max_len)))
    fi
    
    # Vérification des suffixes communs
    local common_suffix_len=0
    for (( i=1; i<=min_len; i++ )); do
        if [[ "${cmd1: -$i:1}" == "${cmd2: -$i:1}" ]]; then
            common_suffix_len=$((common_suffix_len + 1))
        else
            break
        fi
    done
    
    # Score basé sur le suffixe commun
    if (( common_suffix_len > 0 )); then
        score=$((score + (common_suffix_len * 50 / max_len)))
    fi
    
    # Vérification de sous-chaînes communes
    if [[ "$cmd1" == *"$cmd2"* ]] || [[ "$cmd2" == *"$cmd1"* ]]; then
        score=$((score + 30))
    fi
    
    # Analyse des caractères séparateurs
    local separators1=$(echo "$cmd1" | grep -o '[_-]' | wc -l)
    local separators2=$(echo "$cmd2" | grep -o '[_-]' | wc -l)
    
    if (( separators1 == separators2 )); then
        score=$((score + 10))
    fi
    
    # Application de la pénalité de longueur
    score=$((score - length_penalty))
    
    # Assurer que le score reste dans la plage 0-100
    if (( score < 0 )); then
        score=0
    elif (( score > 100 )); then
        score=100
    fi
    
    echo "$score"
}

#==============================================================================
# Fonction: predict_by_advanced_heuristics
# Description: Prédiction basée sur des heuristiques avancées
# Paramètres: $1 - commande
# Retour: Profil prédit ou vide
#==============================================================================
predict_by_advanced_heuristics() {
    local command="$1"
    local score_minimal=0
    local score_normal=0
    local score_full=0
    
    # Patterns spécifiques avec scoring pondéré
    # Patterns MINIMAL (poids élevé pour les commandes simples)
    case "$command" in
        get*|show*|list*|info*|stat*|help*|version*|check*)
            score_minimal=$((score_minimal + 60))
            ;;
        *get|*show|*list|*info|*stat|*help|*version|*check)
            score_minimal=$((score_minimal + 40))
            ;;
    esac
    
    # Patterns NORMAL (poids moyen pour les commandes de développement)
    case "$command" in
        plan*|dev*|debug*|review*|new*|create*|edit*|template*|test*)
            score_normal=$((score_normal + 50))
            ;;
        *plan|*dev|*debug|*review|*new|*create|*edit|*template|*test)
            score_normal=$((score_normal + 35))
            ;;
        build*|compile*|deploy*)
            score_normal=$((score_normal + 45))
            ;;
    esac
    
    # Patterns FULL (poids élevé pour les commandes complexes)
    case "$command" in
        optim*|bench*|perf*|monitor*|diagnose*|cache*|batch*|analyze*)
            score_full=$((score_full + 70))
            ;;
        *optim|*bench|*perf|*monitor|*diagnose|*cache|*batch|*analyze)
            score_full=$((score_full + 50))
            ;;
        system*|admin*|config*)
            score_full=$((score_full + 40))
            ;;
    esac
    
    # Analyse de la complexité basée sur la structure (réduite)
    local complexity_score=0
    
    # Commandes avec séparateurs (plus complexes) - score réduit
    local separator_count=$(echo "$command" | grep -o '[_-]' | wc -l)
    complexity_score=$((separator_count * 5))
    
    # Longueur de la commande (heuristique de complexité) - score réduit
    local cmd_length=${#command}
    if (( cmd_length > 20 )); then
        complexity_score=$((complexity_score + 15))
    elif (( cmd_length > 15 )); then
        complexity_score=$((complexity_score + 10))
    fi
    
    # Application du score de complexité seulement si déjà des points FULL
    if (( score_full > 0 )); then
        score_full=$((score_full + complexity_score))
    fi
    
    # Analyse des patterns de verbes d'action
    if [[ "$command" =~ ^(run|exec|start|stop|restart|kill|terminate) ]]; then
        score_normal=$((score_normal + 25))
    fi
    
    # Détermination du profil basé sur le scoring
    local max_score=0
    local predicted_profile=""
    
    if (( score_minimal > max_score )); then
        max_score=$score_minimal
        predicted_profile="MINIMAL"
    fi
    
    if (( score_normal > max_score )); then
        max_score=$score_normal
        predicted_profile="NORMAL"
    fi
    
    if (( score_full > max_score )); then
        max_score=$score_full
        predicted_profile="FULL"
    fi
    
    # Seuil minimum de confiance plus élevé pour éviter les faux positifs
    if (( max_score >= 60 )); then
        echo "$predicted_profile"
    else
        echo ""
    fi
}

#==============================================================================
# Fonction: predict_by_name_analysis
# Description: Analyse avancée du nom de commande
# Paramètres: $1 - commande
# Retour: Profil prédit
#==============================================================================
predict_by_name_analysis() {
    local command="$1"
    
    # Analyse des mots-clés dans le nom
    local keywords_minimal=("get" "show" "list" "info" "stat" "help" "version" "check" "status")
    local keywords_normal=("plan" "dev" "debug" "review" "new" "create" "edit" "template" "test" "build")
    local keywords_full=("optim" "bench" "perf" "monitor" "diagnose" "cache" "batch" "analyze" "system")
    
    local score_minimal=0
    local score_normal=0
    local score_full=0
    
    # Recherche de mots-clés
    for keyword in "${keywords_minimal[@]}"; do
        if [[ "$command" == *"$keyword"* ]]; then
            score_minimal=$((score_minimal + 20))
        fi
    done
    
    for keyword in "${keywords_normal[@]}"; do
        if [[ "$command" == *"$keyword"* ]]; then
            score_normal=$((score_normal + 20))
        fi
    done
    
    for keyword in "${keywords_full[@]}"; do
        if [[ "$command" == *"$keyword"* ]]; then
            score_full=$((score_full + 20))
        fi
    done
    
    # Détermination du profil gagnant
    if (( score_full > score_normal && score_full > score_minimal && score_full >= 20 )); then
        echo "FULL"
    elif (( score_normal > score_minimal && score_normal >= 20 )); then
        echo "NORMAL"
    elif (( score_minimal >= 20 )); then
        echo "MINIMAL"
    else
        echo "AUTO"
    fi
}

#==============================================================================
# Fonction: update_command_performance
# Description: Met à jour les données de performance avec analyse
# Paramètres: $1 - commande, $2 - temps d'exécution, $3 - profil utilisé
#==============================================================================
update_command_performance() {
    local command="$1"
    local execution_time="$2"
    local profile_used="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Validation des entrées
    if [[ -z "$command" || -z "$execution_time" || -z "$profile_used" ]]; then
        echo "Erreur: Paramètres manquants pour update_command_performance" >&2
        return 1
    fi
    
    # Stockage des données de performance avec historique
    local existing_data="${COMMAND_PERFORMANCE_DATA[$command]}"
    local perf_data="$timestamp:$execution_time:$profile_used"
    
    if [[ -n "$existing_data" ]]; then
        # Garde les 5 dernières entrées
        local history_entries
        history_entries=$(echo "$existing_data" | tr '|' '\n' | tail -4)
        COMMAND_PERFORMANCE_DATA[$command]="$history_entries|$perf_data"
    else
        COMMAND_PERFORMANCE_DATA[$command]="$perf_data"
    fi
    
    # Log de la performance
    log_learning_event "PERFORMANCE" "$command" "$profile_used" "time:$execution_time"
    
    # Apprentissage automatique basé sur la performance
    auto_learn_from_performance_advanced "$command" "$execution_time" "$profile_used"
}

#==============================================================================
# Fonction: auto_learn_from_performance_advanced
# Description: Apprentissage automatique avancé basé sur la performance
# Paramètres: $1 - commande, $2 - temps, $3 - profil
#==============================================================================
auto_learn_from_performance_advanced() {
    local command="$1"
    local execution_time="$2"
    local profile_used="$3"
    
    # Calcul de la confiance basée sur la performance
    local confidence=50
    
    # Analyse de la performance pour déterminer le profil optimal
    local optimal_profile=""
    
    if command -v bc >/dev/null 2>&1; then
        # Utilisation de bc pour les calculs de précision
        if (( $(echo "$execution_time < 0.050" | bc -l) )); then
            optimal_profile="MINIMAL"
            confidence=90
        elif (( $(echo "$execution_time < 0.200" | bc -l) )); then
            optimal_profile="NORMAL"
            confidence=80
        elif (( $(echo "$execution_time < 1.000" | bc -l) )); then
            optimal_profile="FULL"
            confidence=70
        else
            optimal_profile="FULL"
            confidence=60
        fi
    else
        # Fallback sans bc - comparaison approximative
        case "$execution_time" in
            0.0[0-4]*) optimal_profile="MINIMAL"; confidence=90 ;;
            0.0*|0.1*) optimal_profile="NORMAL"; confidence=80 ;;
            *) optimal_profile="FULL"; confidence=70 ;;
        esac
    fi
    
    # Apprentissage si la commande n'est pas encore connue ou si performance différente
    if [[ -z "${LEARNED_PATTERNS[$command]}" ]]; then
        learn_command_pattern "$command" "$optimal_profile" "auto-perf-analysis" "$confidence"
    elif [[ "${LEARNED_PATTERNS[$command]}" != "$optimal_profile" ]]; then
        # Conflit de profil - réévaluation
        local current_confidence="${COMMAND_CONTEXT_HISTORY[$command]##*:}"
        if (( confidence > current_confidence )); then
            learn_command_pattern "$command" "$optimal_profile" "auto-perf-correction" "$confidence"
        fi
    fi
}

#==============================================================================
# Fonction: get_learning_stats
# Description: Retourne les statistiques d'apprentissage détaillées
# Retour: Statistiques sur stdout
#==============================================================================
get_learning_stats() {
    local learned_count=${#LEARNED_PATTERNS[@]}
    local usage_count=${#COMMAND_USAGE_COUNT[@]}
    local performance_count=${#COMMAND_PERFORMANCE_DATA[@]}
    
    echo "=== Statistiques Learning Engine ==="
    echo "Commandes apprises: $learned_count"
    echo "Commandes avec usage: $usage_count"
    echo "Commandes avec données perf: $performance_count"
    echo "Opérations d'apprentissage: $LEARNING_OPERATIONS_COUNT"
    echo "Opérations de prédiction: $PREDICTION_OPERATIONS_COUNT"
    
    # Statistiques du cache
    local total_cache_ops=$((CACHE_HIT_COUNT + CACHE_MISS_COUNT))
    if (( total_cache_ops > 0 )); then
        local cache_hit_rate=$(( CACHE_HIT_COUNT * 100 / total_cache_ops ))
        echo "Cache hit rate: $cache_hit_rate% ($CACHE_HIT_COUNT/$total_cache_ops)"
    fi
    
    # Répartition par profil
    local minimal_count=0
    local normal_count=0
    local full_count=0
    local auto_count=0
    
    for command in "${!LEARNED_PATTERNS[@]}"; do
        case "${LEARNED_PATTERNS[$command]}" in
            "MINIMAL") minimal_count=$((minimal_count + 1)) ;;
            "NORMAL") normal_count=$((normal_count + 1)) ;;
            "FULL") full_count=$((full_count + 1)) ;;
            "AUTO") auto_count=$((auto_count + 1)) ;;
        esac
    done
    
    echo "Répartition des profils appris:"
    echo "  MINIMAL: $minimal_count ($((minimal_count * 100 / (learned_count > 0 ? learned_count : 1)))%)"
    echo "  NORMAL: $normal_count ($((normal_count * 100 / (learned_count > 0 ? learned_count : 1)))%)"
    echo "  FULL: $full_count ($((full_count * 100 / (learned_count > 0 ? learned_count : 1)))%)"
    echo "  AUTO: $auto_count ($((auto_count * 100 / (learned_count > 0 ? learned_count : 1)))%)"
}

#==============================================================================
# Fonction: save_learning_database
# Description: Sauvegarde la base de données d'apprentissage (format amélioré)
#==============================================================================
save_learning_database() {
    local temp_file="${LEARNING_DB_FILE}.tmp"
    
    # Création du fichier JSON avec métadonnées
    {
        echo "{"
        echo "  \"metadata\": {"
        echo "    \"version\": \"2.0\","
        echo "    \"timestamp\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
        echo "    \"learning_operations\": $LEARNING_OPERATIONS_COUNT,"
        echo "    \"prediction_operations\": $PREDICTION_OPERATIONS_COUNT"
        echo "  },"
        echo "  \"learned_patterns\": {"
        local first=true
        for command in "${!LEARNED_PATTERNS[@]}"; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            echo -n "    \"$command\": \"${LEARNED_PATTERNS[$command]}\""
        done
        echo ""
        echo "  },"
        echo "  \"usage_count\": {"
        first=true
        for command in "${!COMMAND_USAGE_COUNT[@]}"; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            echo -n "    \"$command\": ${COMMAND_USAGE_COUNT[$command]}"
        done
        echo ""
        echo "  },"
        echo "  \"context_history\": {"
        first=true
        for command in "${!COMMAND_CONTEXT_HISTORY[@]}"; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            echo -n "    \"$command\": \"${COMMAND_CONTEXT_HISTORY[$command]}\""
        done
        echo ""
        echo "  }"
        echo "}"
    } > "$temp_file" 2>/dev/null || return 1
    
    # Déplacement atomique
    mv "$temp_file" "$LEARNING_DB_FILE" 2>/dev/null || return 1
}

#==============================================================================
# Fonction: backup_learning_database
# Description: Crée une sauvegarde de la base de données
#==============================================================================
backup_learning_database() {
    if [[ -f "$LEARNING_DB_FILE" ]]; then
        mkdir -p "$LEARNING_BACKUP_DIR" 2>/dev/null || return 1
        
        local backup_file="${LEARNING_BACKUP_DIR}/learning_db_$(date '+%Y%m%d_%H%M%S').json"
        cp "$LEARNING_DB_FILE" "$backup_file" 2>/dev/null || return 1
        
        # Garde seulement les 10 dernières sauvegardes
        local backup_count
        backup_count=$(ls -1 "$LEARNING_BACKUP_DIR"/learning_db_*.json 2>/dev/null | wc -l)
        
        if (( backup_count > 10 )); then
            ls -1t "$LEARNING_BACKUP_DIR"/learning_db_*.json | tail -n +11 | xargs rm -f 2>/dev/null || true
        fi
    fi
}

#==============================================================================
# Fonction: load_learning_database
# Description: Charge la base de données d'apprentissage (format amélioré)
#==============================================================================
load_learning_database() {
    if [[ ! -f "$LEARNING_DB_FILE" ]]; then
        return 0  # Pas de base de données existante
    fi
    
    # Chargement des patterns (parsing JSON basique amélioré)
    local in_patterns=false
    local in_usage=false
    local in_context=false
    
    while IFS=': ' read -r key value; do
        # Détection des sections
        if [[ "$key" =~ \"learned_patterns\" ]]; then
            in_patterns=true
            in_usage=false
            in_context=false
            continue
        elif [[ "$key" =~ \"usage_count\" ]]; then
            in_patterns=false
            in_usage=true
            in_context=false
            continue
        elif [[ "$key" =~ \"context_history\" ]]; then
            in_patterns=false
            in_usage=false
            in_context=true
            continue
        fi
        
        # Traitement des données selon la section
        if [[ "$in_patterns" == "true" ]] && [[ "$key" =~ \"([^\"]+)\" ]] && [[ "$value" =~ \"([^\"]+)\" ]]; then
            local cmd="${BASH_REMATCH[1]}"
            local profile="${BASH_REMATCH[1]}"
            LEARNED_PATTERNS[$cmd]="$profile"
        elif [[ "$in_usage" == "true" ]] && [[ "$key" =~ \"([^\"]+)\" ]]; then
            local cmd="${BASH_REMATCH[1]}"
            local count=$(echo "$value" | tr -d ' ,')
            COMMAND_USAGE_COUNT[$cmd]="$count"
        elif [[ "$in_context" == "true" ]] && [[ "$key" =~ \"([^\"]+)\" ]] && [[ "$value" =~ \"([^\"]+)\" ]]; then
            local cmd="${BASH_REMATCH[1]}"
            local context="${BASH_REMATCH[1]}"
            COMMAND_CONTEXT_HISTORY[$cmd]="$context"
        fi
    done < "$LEARNING_DB_FILE" 2>/dev/null || return 1
}

#==============================================================================
# Fonction: log_learning_event
# Description: Enregistre un événement d'apprentissage avec métadonnées
# Paramètres: $1 - type, $2 - commande, $3 - profil, $4 - contexte
#==============================================================================
log_learning_event() {
    local event_type="$1"
    local command="$2"
    local profile="$3"
    local context="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$event_type] $command -> $profile ($context)" >> "$LEARNING_LOG_FILE" 2>/dev/null || true
}

#==============================================================================
# Fonction: optimize_learning_database
# Description: Optimise la base de données d'apprentissage
#==============================================================================
optimize_learning_database() {
    echo "=== Optimisation Learning Database ==="
    
    # Nettoyage des entrées obsolètes
    local cleaned_count=0
    
    # Suppression des commandes avec usage très faible (< 2)
    for command in "${!COMMAND_USAGE_COUNT[@]}"; do
        if (( COMMAND_USAGE_COUNT[$command] < 2 )); then
            unset LEARNED_PATTERNS[$command]
            unset COMMAND_USAGE_COUNT[$command]
            unset COMMAND_CONTEXT_HISTORY[$command]
            cleaned_count=$((cleaned_count + 1))
        fi
    done
    
    # Nettoyage du cache de similarité
    SIMILARITY_CACHE=()
    
    echo "Entrées nettoyées: $cleaned_count"
    echo "Commandes restantes: ${#LEARNED_PATTERNS[@]}"
    
    # Sauvegarde après optimisation
    save_learning_database
    
    echo "Base de données optimisée et sauvegardée"
}

# Initialisation du module
mkdir -p "$(dirname "$LEARNING_DB_FILE")" 2>/dev/null || true
mkdir -p "$(dirname "$LEARNING_LOG_FILE")" 2>/dev/null || true
mkdir -p "$LEARNING_BACKUP_DIR" 2>/dev/null || true

# Chargement de la base de données existante
load_learning_database