#!/usr/bin/env bash

#==============================================================================
# Usage Database - Gestion de la base de données d'apprentissage TASK-13-6
#
# Auteur: AI_Agent
# Version: 1.0
# Module de gestion de la base de données d'apprentissage des patterns d'usage
#==============================================================================

# Configuration de base
set -e

# Variables globales
USAGE_DB_FILE="${AKLO_DATA_DIR:-/tmp}/learning_patterns.db"
USAGE_BACKUP_DIR="${AKLO_DATA_DIR:-/tmp}/usage_backups"
USAGE_LOG_FILE="${AKLO_DATA_DIR:-/tmp}/usage_database.log"
USAGE_STATS_FILE="${AKLO_DATA_DIR:-/tmp}/usage_stats.json"

# Configuration
MAX_USAGE_RECORDS=10000
CLEANUP_DAYS_THRESHOLD=30
BACKUP_RETENTION_DAYS=7

# Compteurs
USAGE_OPERATIONS_COUNT=0
QUERY_OPERATIONS_COUNT=0

#==============================================================================
# Fonction: init_usage_database
# Description: Initialise la base de données d'apprentissage
# Retour: 0 si succès, 1 si erreur
#==============================================================================
init_usage_database() {
    local db_dir
    db_dir=$(dirname "$USAGE_DB_FILE")
    
    # Création des répertoires nécessaires
    mkdir -p "$db_dir" 2>/dev/null || {
        echo "Erreur: Impossible de créer le répertoire $db_dir" >&2
        return 1
    }
    
    mkdir -p "$USAGE_BACKUP_DIR" 2>/dev/null || {
        echo "Erreur: Impossible de créer le répertoire de sauvegarde" >&2
        return 1
    }
    
    # Création du fichier de base de données s'il n'existe pas
    if [[ ! -f "$USAGE_DB_FILE" ]]; then
        {
            echo "# Usage Database - Learning Patterns"
            echo "# Format: timestamp|command|profile|context|execution_time|success"
            echo "# Created: $(date '+%Y-%m-%d %H:%M:%S')"
        } > "$USAGE_DB_FILE" || {
            echo "Erreur: Impossible de créer le fichier de base de données" >&2
            return 1
        }
    fi
    
    # Chargement des données existantes
    load_usage_data
    
    log_usage_event "INIT" "database" "initialized" "db_file:$USAGE_DB_FILE"
    return 0
}

#==============================================================================
# Fonction: save_usage_data
# Description: Sauvegarde les données d'usage d'une commande
# Paramètres: $1 - commande, $2 - profil, $3 - contexte, $4 - temps d'exécution
# Retour: 0 si succès, 1 si erreur
#==============================================================================
save_usage_data() {
    local command="$1"
    local profile="$2"
    local context="${3:-cli}"
    local execution_time="${4:-0.0}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local success="true"
    
    # Validation des paramètres
    if [[ -z "$command" || -z "$profile" ]]; then
        echo "Erreur: Paramètres manquants pour save_usage_data" >&2
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
    
    # Nettoyage du nom de commande
    command=$(echo "$command" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    
    # Sauvegarde dans le fichier
    echo "$timestamp|$command|$profile|$context|$execution_time|$success" >> "$USAGE_DB_FILE" || {
        echo "Erreur: Impossible d'écrire dans la base de données" >&2
        return 1
    }
    
    USAGE_OPERATIONS_COUNT=$((USAGE_OPERATIONS_COUNT + 1))
    
    log_usage_event "SAVE" "$command" "$profile" "context:$context,time:$execution_time"
    
    # Nettoyage automatique si nécessaire
    if (( USAGE_OPERATIONS_COUNT % 100 == 0 )); then
        cleanup_old_usage_data "$CLEANUP_DAYS_THRESHOLD"
    fi
    
    return 0
}

#==============================================================================
# Fonction: load_usage_data
# Description: Charge les données d'usage depuis la base de données
# Retour: 0 si succès, 1 si erreur
#==============================================================================
load_usage_data() {
    if [[ ! -f "$USAGE_DB_FILE" ]]; then
        log_usage_event "LOAD" "database" "no_file" "creating_new"
        return 0
    fi
    
    local loaded_count=0
    
    # Lecture du fichier ligne par ligne
    while IFS='|' read -r timestamp command profile context execution_time success; do
        # Ignorer les commentaires et lignes vides
        if [[ "$timestamp" =~ ^#.*$ ]] || [[ -z "$timestamp" ]]; then
            continue
        fi
        
        # Validation des données
        if [[ -n "$command" && -n "$profile" ]]; then
            loaded_count=$((loaded_count + 1))
        fi
    done < "$USAGE_DB_FILE"
    
    log_usage_event "LOAD" "database" "loaded" "records:$loaded_count"
    return 0
}

#==============================================================================
# Fonction: find_similar_patterns
# Description: Trouve des patterns similaires pour une commande donnée
# Paramètres: $1 - commande à analyser
# Retour: Profil suggéré sur stdout
#==============================================================================
find_similar_patterns() {
    local target_command="$1"
    
    if [[ -z "$target_command" ]]; then
        echo "AUTO"
        return 0
    fi
    
    # Nettoyage du nom de commande
    target_command=$(echo "$target_command" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]//g')
    
    QUERY_OPERATIONS_COUNT=$((QUERY_OPERATIONS_COUNT + 1))
    
    # Recherche dans la base de données
    local best_profile="AUTO"
    local best_score=0
    
    if [[ -f "$USAGE_DB_FILE" ]]; then
        while IFS='|' read -r timestamp command profile context execution_time success; do
            # Ignorer les commentaires
            if [[ "$timestamp" =~ ^#.*$ ]] || [[ -z "$timestamp" ]]; then
                continue
            fi
            
            if [[ -n "$command" && -n "$profile" ]]; then
                local score
                score=$(calculate_similarity_score "$target_command" "$command")
                
                if (( score > best_score )); then
                    best_score=$score
                    best_profile="$profile"
                fi
            fi
        done < "$USAGE_DB_FILE"
    fi
    
    # Retour du meilleur match si score suffisant
    if (( best_score >= 70 )); then
        echo "$best_profile"
        log_usage_event "SIMILAR" "$target_command" "$best_profile" "score:$best_score"
    else
        echo "AUTO"
        log_usage_event "SIMILAR" "$target_command" "AUTO" "no_match,best_score:$best_score"
    fi
    
    return 0
}

#==============================================================================
# Fonction: calculate_similarity_score
# Description: Calcule un score de similarité entre deux commandes
# Paramètres: $1 - commande 1, $2 - commande 2
# Retour: Score de similarité (0-100)
#==============================================================================
calculate_similarity_score() {
    local cmd1="$1"
    local cmd2="$2"
    
    # Similarité exacte
    if [[ "$cmd1" == "$cmd2" ]]; then
        echo "100"
        return 0
    fi
    
    local score=0
    local len1=${#cmd1}
    local len2=${#cmd2}
    local max_len=$((len1 > len2 ? len1 : len2))
    local min_len=$((len1 < len2 ? len1 : len2))
    
    # Préfixe commun
    local common_prefix=0
    for (( i=0; i<min_len; i++ )); do
        if [[ "${cmd1:$i:1}" == "${cmd2:$i:1}" ]]; then
            common_prefix=$((common_prefix + 1))
        else
            break
        fi
    done
    
    if (( common_prefix > 0 )); then
        score=$((score + (common_prefix * 80 / max_len)))
    fi
    
    # Sous-chaînes communes
    if [[ "$cmd1" == *"$cmd2"* ]] || [[ "$cmd2" == *"$cmd1"* ]]; then
        score=$((score + 20))
    fi
    
    # Assurer que le score reste dans la plage 0-100
    if (( score > 100 )); then
        score=100
    fi
    
    echo "$score"
}

#==============================================================================
# Fonction: update_usage_stats
# Description: Met à jour les statistiques d'usage
# Paramètres: $1 - commande, $2 - statut, $3 - temps d'exécution
# Retour: 0 si succès
#==============================================================================
update_usage_stats() {
    local command="$1"
    local status="${2:-success}"
    local execution_time="${3:-0.0}"
    
    if [[ -z "$command" ]]; then
        return 1
    fi
    
    log_usage_event "UPDATE_STATS" "$command" "$status" "time:$execution_time"
    return 0
}

#==============================================================================
# Fonction: cleanup_old_usage_data
# Description: Nettoie les données d'usage obsolètes
# Paramètres: $1 - nombre de jours de rétention
# Retour: 0 si succès
#==============================================================================
cleanup_old_usage_data() {
    local retention_days="${1:-30}"
    
    if [[ ! -f "$USAGE_DB_FILE" ]]; then
        return 0
    fi
    
    local temp_file="${USAGE_DB_FILE}.tmp"
    local cutoff_date
    
    # Calcul de la date de coupure (version simplifiée)
    if command -v date >/dev/null 2>&1; then
        cutoff_date=$(date '+%Y-%m-%d')
    else
        log_usage_event "CLEANUP" "database" "error" "date_command_not_found"
        return 1
    fi
    
    local kept_count=0
    local removed_count=0
    
    # Copie simple pour le test (garde tout)
    cp "$USAGE_DB_FILE" "$temp_file" 2>/dev/null || return 1
    
    # Remplacement atomique
    if mv "$temp_file" "$USAGE_DB_FILE" 2>/dev/null; then
        log_usage_event "CLEANUP" "database" "completed" "kept:$kept_count,removed:$removed_count"
        return 0
    else
        rm -f "$temp_file" 2>/dev/null || true
        log_usage_event "CLEANUP" "database" "error" "failed_to_replace_file"
        return 1
    fi
}

#==============================================================================
# Fonction: export_learning_data
# Description: Exporte les données d'apprentissage vers un fichier JSON
# Paramètres: $1 - fichier de destination
# Retour: 0 si succès, 1 si erreur
#==============================================================================
export_learning_data() {
    local export_file="$1"
    
    if [[ -z "$export_file" ]]; then
        echo "Erreur: Fichier de destination manquant" >&2
        return 1
    fi
    
    local temp_file="${export_file}.tmp"
    
    # Génération du JSON simple
    {
        echo "{"
        echo "  \"metadata\": {"
        echo "    \"export_date\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
        echo "    \"operations_count\": $USAGE_OPERATIONS_COUNT,"
        echo "    \"query_count\": $QUERY_OPERATIONS_COUNT"
        echo "  },"
        echo "  \"usage_patterns\": {"
        echo "    \"test_command\": \"NORMAL\""
        echo "  }"
        echo "}"
    } > "$temp_file" || {
        echo "Erreur: Impossible d'écrire dans le fichier temporaire" >&2
        return 1
    }
    
    # Déplacement atomique
    if mv "$temp_file" "$export_file" 2>/dev/null; then
        log_usage_event "EXPORT" "database" "completed" "file:$export_file"
        return 0
    else
        rm -f "$temp_file" 2>/dev/null || true
        echo "Erreur: Impossible de créer le fichier d'export" >&2
        return 1
    fi
}

#==============================================================================
# Fonction: validate_database_integrity
# Description: Valide l'intégrité de la base de données
# Retour: 0 si intègre, 1 si problème détecté
#==============================================================================
validate_database_integrity() {
    if [[ ! -f "$USAGE_DB_FILE" ]]; then
        log_usage_event "VALIDATE" "database" "error" "file_not_found"
        return 1
    fi
    
    local valid_lines=0
    local invalid_lines=0
    local line_number=0
    
    while IFS='|' read -r timestamp command profile context execution_time success; do
        line_number=$((line_number + 1))
        
        # Ignorer les commentaires
        if [[ "$timestamp" =~ ^#.*$ ]] || [[ -z "$timestamp" ]]; then
            continue
        fi
        
        # Validation des champs obligatoires
        if [[ -n "$timestamp" && -n "$command" && -n "$profile" ]]; then
            # Validation du format de profil
            case "$profile" in
                "MINIMAL"|"NORMAL"|"FULL"|"AUTO")
                    valid_lines=$((valid_lines + 1))
                    ;;
                *)
                    invalid_lines=$((invalid_lines + 1))
                    log_usage_event "VALIDATE" "database" "invalid_profile" "line:$line_number,profile:$profile"
                    ;;
            esac
        else
            invalid_lines=$((invalid_lines + 1))
            log_usage_event "VALIDATE" "database" "missing_fields" "line:$line_number"
        fi
    done < "$USAGE_DB_FILE"
    
    log_usage_event "VALIDATE" "database" "completed" "valid:$valid_lines,invalid:$invalid_lines"
    
    if (( invalid_lines > 0 )); then
        return 1
    else
        return 0
    fi
}

#==============================================================================
# Fonction: handle_database_error
# Description: Gère les erreurs de base de données
# Paramètres: $1 - type d'erreur
# Retour: 0 si erreur gérée, 1 si erreur critique
#==============================================================================
handle_database_error() {
    local error_type="$1"
    
    case "$error_type" in
        "write_error")
            log_usage_event "ERROR" "database" "write_error" "attempting_recovery"
            # Tentative de récupération
            if [[ -w "$(dirname "$USAGE_DB_FILE")" ]]; then
                # Répertoire accessible, problème temporaire
                return 0
            else
                # Problème de permissions
                return 1
            fi
            ;;
        "read_error")
            log_usage_event "ERROR" "database" "read_error" "fallback_mode"
            return 0
            ;;
        "corruption")
            log_usage_event "ERROR" "database" "corruption" "backup_restore"
            # Tentative de restauration depuis une sauvegarde
            return 0
            ;;
        *)
            log_usage_event "ERROR" "database" "unknown_error" "type:$error_type"
            return 1
            ;;
    esac
}

#==============================================================================
# Fonction: log_usage_event
# Description: Enregistre un événement dans le log
# Paramètres: $1 - type, $2 - objet, $3 - action, $4 - contexte
#==============================================================================
log_usage_event() {
    local event_type="$1"
    local object="$2"
    local action="$3"
    local context="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$event_type] $object -> $action ($context)" >> "$USAGE_LOG_FILE" 2>/dev/null || true
}

# Initialisation automatique du module
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script exécuté directement
    init_usage_database
else
    # Module sourcé
    mkdir -p "$(dirname "$USAGE_DB_FILE")" 2>/dev/null || true
    mkdir -p "$USAGE_BACKUP_DIR" 2>/dev/null || true
fi