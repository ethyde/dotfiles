#!/bin/bash

# Fonctions de cache pour le parser générique aklo
# Toutes les opérations de log de statuts de cache (MISS, HIT, etc.) doivent utiliser la fonction centralisée log_cache_event définie ci-dessous.
# Voir la documentation inline de log_cache_event pour la liste des statuts standards et l’usage recommandé.
# TASK-6-1: Infrastructure de base du système de cache
# Phase BLUE: Version refactorisée et optimisée

# Configuration du cache (centralisée le 2025-07-10)
# AKLO_PROJECT_ROOT doit être défini par le script appelant.
# Configuration du cache. Utilise un répertoire de test si disponible, sinon un
# répertoire cache central dans le projet.
if [ -n "$TEST_PROJECT_DIR" ]; then
    AKLO_CACHE_DIR="${TEST_PROJECT_DIR}/cache"
else
    AKLO_CACHE_DIR="${AKLO_PROJECT_ROOT:-$PWD}/.aklo_cache"
fi
mkdir -p "$AKLO_CACHE_DIR"

# Fonction utilitaire pour créer le répertoire cache
# Crée le répertoire cache s'il n'existe pas
init_cache_dir() {
    local cache_dir="${AKLO_CACHE_DIR}"
    
    # Création avec gestion d'erreur
    if ! mkdir -p "$cache_dir" 2>/dev/null; then
        echo "Erreur: Impossible de créer le répertoire cache $cache_dir" >&2
        return 1
    fi
    
    return 0
}

#==============================================================================
# Fonction: get_cache_filepath
# Description: Construit le chemin absolu pour un fichier de cache donné.
# Usage: get_cache_filepath <identifier>
#==============================================================================
get_cache_filepath() {
    local identifier="$1"
    echo "${AKLO_CACHE_DIR}/${identifier}.parsed"
}

#==============================================================================
# Fonction: find_protocol_file
# Description: Localise un fichier de protocole en cherchant à plusieurs
#              endroits standards.
# Usage: find_protocol_file <protocol_name>
#==============================================================================
find_protocol_file() {
    local protocol_name="$1"
    local search_paths=(
        "${AKLO_PROTOCOLS_PATH:-./aklo/charte/PROTOCOLES}"
        "./aklo/charte/PROTOCOLES"
        "$(dirname "$0")/../charte/PROTOCOLES"
    )
    
    for path in "${search_paths[@]}"; do
        if [ -f "${path}/${protocol_name}.xml" ]; then
            echo "${path}/${protocol_name}.xml"
            return 0
        fi
    done
    return 1
}

# Fonction de validation cache
# Vérifie si le cache est valide en comparant les timestamps
# Usage: cache_is_valid <cache_file> <protocol_mtime>
# Retourne: 0 si valide, 1 si invalide
cache_is_valid() {
    local cache_file="$1"
    local protocol_mtime="$2"
    
    # Validation des paramètres d'entrée
    if [ -z "$cache_file" ] || [ -z "$protocol_mtime" ]; then
        return 1
    fi
    
    # Vérification existence du fichier cache
    if [ ! -f "$cache_file" ]; then
        return 1
    fi
    
    # Vérification existence du fichier mtime
    local mtime_file="${cache_file}.mtime"
    if [ ! -f "$mtime_file" ]; then
        return 1
    fi
    
    # Lecture et comparaison des timestamps
    local cached_mtime
    if ! cached_mtime=$(cat "$mtime_file" 2>/dev/null); then
        return 1
    fi
    
    # Comparaison exacte des timestamps
    [ "$cached_mtime" = "$protocol_mtime" ]
}

#==============================================================================
# Fonction: update_cache_mtime
# Description: Met à jour le fichier .mtime associé à un fichier cache.
# Usage: update_cache_mtime <cache_file> <protocol_mtime>
#==============================================================================
update_cache_mtime() {
    local cache_file="$1"
    local protocol_mtime="$2"
    local mtime_file="${cache_file}.mtime"
    
    if [ -n "$cache_file" ] && [ -n "$protocol_mtime" ]; then
        echo "$protocol_mtime" > "$mtime_file"
    fi
}

# Fonction de lecture cache
# Lit le contenu du cache et le retourne sur stdout
# Usage: use_cached_structure <cache_file>
# Retourne: 0 si succès, 1 si erreur
use_cached_structure() {
    local cache_file="$1"
    
    # Validation des paramètres d'entrée
    if [ -z "$cache_file" ]; then
        return 1
    fi
    
    # Vérification existence du fichier
    if [ ! -f "$cache_file" ]; then
        return 1
    fi
    
    # Lecture sécurisée du contenu
    if ! cat "$cache_file" 2>/dev/null; then
        return 1
    fi
    
    return 0
}

# Fonction de nettoyage cache
# Supprime les fichiers cache anciens selon TTL configuré
# Usage: cleanup_cache [ttl_days]
# Retourne: 0 si succès, 1 si erreur
cleanup_cache() {
    local ttl_days="${1:-7}"  # TTL par défaut: 7 jours
    local cache_dir="${AKLO_CACHE_DIR}"
    
    # Initialisation du répertoire cache
    if ! init_cache_dir; then
        return 1
    fi
    
    # Nettoyage des fichiers .parsed anciens
    if ! find "$cache_dir" -name "*.parsed" -mtime "+$ttl_days" -delete 2>/dev/null; then
        # Échec silencieux - pas critique
        true
    fi
    
    # Nettoyage des fichiers .mtime anciens
    if ! find "$cache_dir" -name "*.mtime" -mtime "+$ttl_days" -delete 2>/dev/null; then
        # Échec silencieux - pas critique
        true
    fi
    
    return 0
}

# Fonction utilitaire pour obtenir le mtime d'un fichier
# Usage: get_file_mtime <file_path>
# Retourne: timestamp mtime sur stdout
get_file_mtime() {
    local file_path="$1"
    
    if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
        return 1
    fi
    
    # Compatible macOS et Linux
    if command -v stat >/dev/null 2>&1; then
        # macOS
        stat -f %m "$file_path" 2>/dev/null || \
        # Linux
        stat -c %Y "$file_path" 2>/dev/null
    else
        return 1
    fi
}

# Fonction utilitaire pour le logging des statuts de cache
# Statuts standards : MISS, HIT, DISABLED, RECALC, CACHED, SUCCESS, ERROR, FALLBACK, COMPLETE, CHECK
# Usage : log_cache_event <STATUT> <details>
log_cache_event() {
    local type="$1"
    local message="$2"
    # Écrire systématiquement sur stdout pour être capturé par les tests.
    echo "[CACHE] $type: $message"
}

# Fonction utilitaire pour forcer la création d'un fichier cache .parsed vide
force_create_cache_file() {
    local cache_file="$1"
    if [ -n "$cache_file" ] && [ ! -f "$cache_file" ]; then
        mkdir -p "$(dirname "$cache_file")"
        touch "$cache_file"
        log_cache_event "CACHED" "Fichier cache forcé: $cache_file"
    fi
}

record_cache_metric() {
    local event_type="$1"
    # Centralisation du cache (décision du 2025-07-10)
    # Le fichier de métriques est maintenant dans le répertoire de cache central.
    local metrics_file="${AKLO_CACHE_DIR}/cache_metrics.json"

    # Ne fait rien si le cache est désactivé, pour éviter de créer le fichier
    if [ "${AKLO_CACHE_ENABLED}" = "false" ]; then
        return 0
    fi

    mkdir -p "$(dirname "$metrics_file")"
    local hits=0
    local misses=0
    if [ -f "$metrics_file" ]; then
        hits=$(grep -o '"hits"[ ]*:[ ]*[0-9]*' "$metrics_file" | head -1 | sed 's/[^0-9]*//g')
        misses=$(grep -o '"misses"[ ]*:[ ]*[0-9]*' "$metrics_file" | head -1 | sed 's/[^0-9]*//g')
    fi
    if [ "$event_type" = "hit" ]; then
        hits=$((hits+1))
    elif [ "$event_type" = "miss" ]; then
        misses=$((misses+1))
    fi
    local total=$((hits+misses))
    echo -n '{' > "$metrics_file"
    echo -n '"hits":' >> "$metrics_file"
    echo -n "$hits" >> "$metrics_file"
    echo -n ',"misses":' >> "$metrics_file"
    echo -n "$misses" >> "$metrics_file"
    echo -n ',"total":' >> "$metrics_file"
    echo -n "$total" >> "$metrics_file"
    echo '}' >> "$metrics_file"
    echo "[CACHE] METRICS: hits=$hits misses=$misses total=$total ($metrics_file)"
}