#!/bin/bash

# Fonctions de cache pour le parser générique aklo
# TASK-6-1: Infrastructure de base du système de cache
# Phase BLUE: Version refactorisée et optimisée

# Configuration du cache
AKLO_CACHE_DIR="${AKLO_CACHE_DIR:-/tmp/aklo_cache}"

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

# Fonction utilitaire pour générer le nom de fichier cache
# Usage: generate_cache_filename <protocol_name> <artefact_type>
# Retourne: nom du fichier cache sur stdout
generate_cache_filename() {
    local protocol_name="$1"
    local artefact_type="$2"
    
    if [ -z "$protocol_name" ] || [ -z "$artefact_type" ]; then
        return 1
    fi
    
    echo "${AKLO_CACHE_DIR}/protocol_${protocol_name}_${artefact_type}.parsed"
}