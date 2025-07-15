#!/usr/bin/env bash
#==============================================================================
# AKLO REGEX CACHE MODULE
#==============================================================================

# Déclaration des variables globales (hors de toute fonction)
declare -A REGEX_PATTERNS_CACHE
REGEX_CACHE_INITIALIZED=false
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
    if [[ -n "${REGEX_PATTERNS_CACHE[$pattern_name]}" ]]; then
        REGEX_HITS_COUNT[$pattern_name]=$(( ${REGEX_HITS_COUNT[$pattern_name]:-0} + 1 ))
        echo "[DEBUG] hits=${REGEX_HITS_COUNT[$pattern_name]:-0} miss=${REGEX_MISS_COUNT:-0}" 1>&2
        echo "${REGEX_PATTERNS_CACHE[$pattern_name]}"
        return 0
    else
        REGEX_MISS_COUNT=$(( ${REGEX_MISS_COUNT:-0} + 1 ))
        echo "[DEBUG] hits=${REGEX_HITS_COUNT[$pattern_name]:-0} miss=${REGEX_MISS_COUNT:-0}" 1>&2
        return 1
    fi
}

# Getter pour les stats (pour les tests)
get_regex_cache_stats() {
    local pattern_name="$1"
    echo "hits=${REGEX_HITS_COUNT[$pattern_name]:-0} miss=${REGEX_MISS_COUNT:-0}"
}

#------------------------------------------------------------------------------
# Reset du cache regex (clear)
#------------------------------------------------------------------------------
clear_regex_cache() {
    REGEX_PATTERNS_CACHE=()
    REGEX_CACHE_INITIALIZED=false
    REGEX_HITS_COUNT=()
    REGEX_MISS_COUNT=0
}

#------------------------------------------------------------------------------
# Utilisation d'un pattern avec fallback
#------------------------------------------------------------------------------
use_regex_pattern() {
    local pattern_name="$1"
    local fallback="$2"
    local pattern
    if pattern=$(get_cached_regex "$pattern_name"); then
        echo "$pattern"
        return 0
    else
        # Miss : on utilise le fallback, mais on a déjà incrémenté le compteur de miss dans get_cached_regex
        echo "$fallback"
        return 1
    fi
}

#------------------------------------------------------------------------------
# Validation stricte du format de date AAAA-MM-JJ
#------------------------------------------------------------------------------
validate_date_format() {
    local date_str="$1"
    if [[ "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 0
    else
        return 1
    fi
}

#------------------------------------------------------------------------------
# Validation d'une ligne de config (clé=valeur ou section)
#------------------------------------------------------------------------------
validate_config_line() {
    local line="$1"
    if [[ "$line" =~ ^[A-Z_][A-Z0-9_]*=.*$ ]] || [[ "$line" =~ ^\[[a-zA-Z0-9_]+\]$ ]]; then
        return 0
    else
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

# Exporte les stats dans un fichier (pour les tests en sous-shell)
export_regex_cache_stats() {
    local outfile="$1"
    echo "PBI_ID_hits=${REGEX_HITS_COUNT[PBI_ID]:-0}" > "$outfile"
    echo "NONEXISTENT_miss=${REGEX_MISS_COUNT:-0}" >> "$outfile"
}