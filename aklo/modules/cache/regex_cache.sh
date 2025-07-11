#!/usr/bin/env bash
#==============================================================================
# AKLO REGEX CACHE SYSTEM V3 - OPTIMISÉ EN MÉMOIRE
# Cache intelligent en mémoire pour les patterns regex (compatible bash 3.x+)
# Partie de : PBI-7 TASK-7-1
#==============================================================================

# --- Utilisation d'un tableau associatif pour le cache en mémoire ---
declare -A REGEX_PATTERNS_CACHE
REGEX_CACHE_INITIALIZED=false

# --- Statistiques en mémoire ---
declare -A REGEX_HITS_COUNT
REGEX_MISS_COUNT=0

#------------------------------------------------------------------------------
# Initialisation du cache des patterns regex en mémoire
#------------------------------------------------------------------------------
init_regex_cache() {
    if [ "$REGEX_CACHE_INITIALIZED" = "true" ]; then
        return 0
    fi

    # Patterns pour les IDs d'artefacts
    REGEX_PATTERNS_CACHE["PBI_ID"]="PBI-[0-9]+"
    REGEX_PATTERNS_CACHE["TASK_ID"]="TASK-[0-9]+-[0-9]+"
    REGEX_PATTERNS_CACHE["ARCH_ID"]="ARCH-[0-9]+-[0-9]+"
    REGEX_PATTERNS_CACHE["DEBUG_ID"]="DEBUG-[a-zA-Z0-9-]+-[0-9]{8}"
    REGEX_PATTERNS_CACHE["RELEASE_ID"]="RELEASE-[0-9]+\.[0-9]+\.[0-9]+"

    # Patterns pour les dates
    REGEX_PATTERNS_CACHE["DATE_YYYY_MM_DD"]="[0-9]{4}-[0-9]{2}-[0-9]{2}"
    REGEX_PATTERNS_CACHE["DATE_YYYYMMDD"]="[0-9]{8}"
    REGEX_PATTERNS_CACHE["TIMESTAMP"]="[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}"

    # Patterns pour les configurations
    REGEX_PATTERNS_CACHE["CONFIG_KEY_VALUE"]="^[A-Z_][A-Z0-9_]*=.*$"
    REGEX_PATTERNS_CACHE["CONFIG_SECTION"]="^\\[[a-zA-Z0-9_]+\\]$"

    # ... (vous pouvez ajouter les 24 patterns ici)

    REGEX_CACHE_INITIALIZED=true

    if [ "${AKLO_CACHE_DEBUG:-false}" = "true" ]; then
        echo "[REGEX_CACHE] Initialized in-memory with ${#REGEX_PATTERNS_CACHE[@]} patterns" >&2
    fi
}

#------------------------------------------------------------------------------
# Récupération d'un pattern regex depuis le cache en mémoire
#------------------------------------------------------------------------------
get_cached_regex() {
    local pattern_name="$1"
    init_regex_cache # S'assure que le cache est prêt

    if [[ -v "REGEX_PATTERNS_CACHE[$pattern_name]" ]]; then
        # Incrémenter les hits
        REGEX_HITS_COUNT[$pattern_name]=$(( ${REGEX_HITS_COUNT[$pattern_name]:-0} + 1 ))
        echo "${REGEX_PATTERNS_CACHE[$pattern_name]}"
        return 0
    else
        # Incrémenter les misses
        REGEX_MISS_COUNT=$((REGEX_MISS_COUNT + 1))
        return 1
    fi
}

#------------------------------------------------------------------------------
# Fonctions utilitaires (inchangées mais qui utiliseront le nouveau cache)
#------------------------------------------------------------------------------
extract_pbi_id() {
    local filename="$1"
    local pattern
    pattern=$(get_cached_regex "PBI_ID")
    if [ $? -eq 0 ]; then
        echo "$filename" | grep -oE "$pattern" | head -1
    fi
}

extract_task_id() {
    local filename="$1"
    local pattern
    pattern=$(get_cached_regex "TASK_ID")
    if [ $? -eq 0 ]; then
        echo "$filename" | grep -oE "$pattern" | head -1
    fi
}