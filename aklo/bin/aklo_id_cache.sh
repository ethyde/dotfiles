#!/bin/bash

# Fonctions de cache des IDs pour optimiser get_next_id()
# TASK-7-3: Cache intelligent pour éviter les opérations ls répétitives

# Source des fonctions de cache de base
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "${script_dir}/aklo_cache_functions.sh"

# Variables globales pour le cache des IDs
# Utiliser des fichiers temporaires pour persister les métriques entre les appels
AKLO_ID_CACHE_METRICS_FILE="/tmp/aklo_id_cache_metrics"

# Initialiser les métriques si le fichier n'existe pas
if [ ! -f "$AKLO_ID_CACHE_METRICS_FILE" ]; then
    echo "0 0" > "$AKLO_ID_CACHE_METRICS_FILE"
fi

# Fonction get_next_id_cached: Version optimisée de get_next_id avec cache
# Usage: get_next_id_cached SEARCH_PATH PREFIX
# Retourne: Le prochain ID disponible
get_next_id_cached() {
    local search_path="$1"
    local prefix="$2"
    
    if [ -z "$search_path" ] || [ -z "$prefix" ]; then
        echo "1"
        return 0
    fi
    
    local cache_key=$(echo "${search_path}_${prefix}" | tr '/' '_' | tr ':' '_')
    local cache_file="${AKLO_CACHE_DIR}/id_cache_${cache_key}.cache"
    local cache_mtime_file="${cache_file}.mtime"
    
    # Créer le répertoire cache si nécessaire
    init_cache_dir
    
    # Obtenir le timestamp du répertoire pour détecter les changements
    local dir_mtime
    if [ -d "$search_path" ]; then
        dir_mtime=$(stat -f %m "$search_path" 2>/dev/null || stat -c %Y "$search_path" 2>/dev/null || echo 0)
    else
        dir_mtime=0
    fi
    
    # Vérifier si le cache est valide
    if [ -f "$cache_file" ] && [ -f "$cache_mtime_file" ]; then
        local cached_mtime
        if cached_mtime=$(cat "$cache_mtime_file" 2>/dev/null); then
            if [ "$cached_mtime" = "$dir_mtime" ]; then
                # Cache valide - retourner la valeur mise en cache
                # Optimisation: Mise à jour des métriques en arrière-plan pour réduire la latence
                (
                    local metrics=$(cat "$AKLO_ID_CACHE_METRICS_FILE" 2>/dev/null || echo "0 0")
                    local hits=$(echo "$metrics" | cut -d' ' -f1)
                    local misses=$(echo "$metrics" | cut -d' ' -f2)
                    hits=$((hits + 1))
                    echo "$hits $misses" > "$AKLO_ID_CACHE_METRICS_FILE"
                ) &
                cat "$cache_file"
                return 0
            fi
        fi
    fi
    
    # Cache manqué - calculer la valeur
    # Optimisation: Mise à jour des métriques en arrière-plan
    (
        local metrics=$(cat "$AKLO_ID_CACHE_METRICS_FILE" 2>/dev/null || echo "0 0")
        local hits=$(echo "$metrics" | cut -d' ' -f1)
        local misses=$(echo "$metrics" | cut -d' ' -f2)
        misses=$((misses + 1))
        echo "$hits $misses" > "$AKLO_ID_CACHE_METRICS_FILE"
    ) &
    
    # Utiliser la logique originale de get_next_id
    local last_id
    last_id=$(ls "${search_path}/${prefix}"*-*.md 2>/dev/null | sed -n "s/.*${prefix}-\([0-9]*\)-.*/\1/p" | sort -n | tail -1)
    if [ -z "$last_id" ]; then
        last_id=0
    fi
    local next_id=$((last_id + 1))
    
    # Mettre en cache le résultat
    echo "$next_id" > "$cache_file"
    echo "$dir_mtime" > "$cache_mtime_file"
    
    echo "$next_id"
}

# Fonction invalidate_id_cache: Invalide le cache pour un répertoire/préfixe donné
# Usage: invalidate_id_cache SEARCH_PATH PREFIX
invalidate_id_cache() {
    local search_path="$1"
    local prefix="$2"
    
    if [ -z "$search_path" ] || [ -z "$prefix" ]; then
        return 1
    fi
    
    local cache_key=$(echo "${search_path}_${prefix}" | tr '/' '_' | tr ':' '_')
    local cache_file="${AKLO_CACHE_DIR}/id_cache_${cache_key}.cache"
    local cache_mtime_file="${cache_file}.mtime"
    
    # Supprimer les fichiers de cache
    rm -f "$cache_file" "$cache_mtime_file" 2>/dev/null
}

# Fonction update_id_cache: Met à jour le cache après création d'un artefact
# Usage: update_id_cache SEARCH_PATH PREFIX NEW_ID
update_id_cache() {
    local search_path="$1"
    local prefix="$2"
    local new_id="$3"
    
    if [ -z "$search_path" ] || [ -z "$prefix" ] || [ -z "$new_id" ]; then
        return 1
    fi
    
    local cache_key=$(echo "${search_path}_${prefix}" | tr '/' '_' | tr ':' '_')
    local cache_file="${AKLO_CACHE_DIR}/id_cache_${cache_key}.cache"
    local cache_mtime_file="${cache_file}.mtime"
    
    # Créer le répertoire cache si nécessaire
    init_cache_dir
    
    # Mettre à jour le cache avec le nouvel ID + 1
    local next_id=$((new_id + 1))
    echo "$next_id" > "$cache_file"
    
    # Mettre à jour le timestamp
    local dir_mtime
    if [ -d "$search_path" ]; then
        dir_mtime=$(stat -f %m "$search_path" 2>/dev/null || stat -c %Y "$search_path" 2>/dev/null || echo 0)
    else
        dir_mtime=0
    fi
    echo "$dir_mtime" > "$cache_mtime_file"
}

# Fonction get_id_cache_metrics: Retourne les métriques du cache des IDs
# Usage: get_id_cache_metrics
# Retourne: Statistiques hits/misses du cache
get_id_cache_metrics() {
    if [ -f "$AKLO_ID_CACHE_METRICS_FILE" ]; then
        local metrics=$(cat "$AKLO_ID_CACHE_METRICS_FILE")
        local hits=$(echo "$metrics" | cut -d' ' -f1)
        local misses=$(echo "$metrics" | cut -d' ' -f2)
        echo "ID Cache - Hits: $hits, Misses: $misses"
    else
        echo "ID Cache - Hits: 0, Misses: 0"
    fi
}

# Fonction reset_id_cache_metrics: Remet à zéro les métriques
# Usage: reset_id_cache_metrics
reset_id_cache_metrics() {
    echo "0 0" > "$AKLO_ID_CACHE_METRICS_FILE"
}