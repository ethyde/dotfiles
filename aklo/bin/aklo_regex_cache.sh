#!/bin/bash

#==============================================================================
# AKLO REGEX CACHE SYSTEM V2
# Cache intelligent pour les patterns regex (compatible bash 3.x+)
# 
# Partie de : PBI-7 TASK-7-1 - Optimisation des patterns regex
# Date : 2025-07-03
#==============================================================================

# Variables globales pour le cache regex (approche compatible)
REGEX_CACHE_INITIALIZED=false
REGEX_CACHE_DIR="${TMPDIR:-/tmp}/aklo_regex_cache_$$"

#------------------------------------------------------------------------------
# Initialisation du cache des patterns regex
#------------------------------------------------------------------------------
init_regex_cache() {
    if [ "$REGEX_CACHE_INITIALIZED" = "true" ]; then
        return 0
    fi
    
    # Créer le répertoire de cache temporaire
    mkdir -p "$REGEX_CACHE_DIR"
    
    # Définir les patterns dans des fichiers individuels (compatible bash 3.x)
    
    # Patterns pour les IDs d'artefacts
    echo "PBI-[0-9]+" > "$REGEX_CACHE_DIR/PBI_ID"
    echo "TASK-[0-9]+-[0-9]+" > "$REGEX_CACHE_DIR/TASK_ID"
    echo "ARCH-[0-9]+-[0-9]+" > "$REGEX_CACHE_DIR/ARCH_ID"
    echo "DEBUG-[a-zA-Z0-9-]+-[0-9]{8}" > "$REGEX_CACHE_DIR/DEBUG_ID"
    echo "RELEASE-[0-9]+\\.[0-9]+\\.[0-9]+" > "$REGEX_CACHE_DIR/RELEASE_ID"
    
    # Patterns pour les dates
    echo "[0-9]{4}-[0-9]{2}-[0-9]{2}" > "$REGEX_CACHE_DIR/DATE_YYYY_MM_DD"
    echo "[0-9]{8}" > "$REGEX_CACHE_DIR/DATE_YYYYMMDD"
    echo "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}" > "$REGEX_CACHE_DIR/TIMESTAMP"
    
    # Patterns pour les configurations
    echo "^[A-Z_][A-Z0-9_]*=.*$" > "$REGEX_CACHE_DIR/CONFIG_KEY_VALUE"
    echo "^\\[[a-zA-Z0-9_]+\\]$" > "$REGEX_CACHE_DIR/CONFIG_SECTION"
    
    # Patterns pour le parsing des protocoles
    echo "^## [0-9]+\\. " > "$REGEX_CACHE_DIR/PROTOCOL_SECTION"
    echo "^### [0-9]+\\.[0-9]+\\. " > "$REGEX_CACHE_DIR/PROTOCOL_SUBSECTION"
    echo "^#{1,6} " > "$REGEX_CACHE_DIR/MARKDOWN_HEADER"
    
    # Patterns pour les remplacements de templates
    echo "\\[PBI_ID\\]" > "$REGEX_CACHE_DIR/TEMPLATE_PBI_ID"
    echo "\\[Task_ID\\]" > "$REGEX_CACHE_DIR/TEMPLATE_TASK_ID"
    echo "\\[DATE\\]" > "$REGEX_CACHE_DIR/TEMPLATE_DATE"
    echo "\\[TITRE\\]" > "$REGEX_CACHE_DIR/TEMPLATE_TITLE"
    
    # Patterns pour les statuts d'artefacts
    echo "PROPOSED" > "$REGEX_CACHE_DIR/STATUS_PROPOSED"
    echo "AGREED" > "$REGEX_CACHE_DIR/STATUS_AGREED"
    echo "TODO" > "$REGEX_CACHE_DIR/STATUS_TODO"
    echo "IN_PROGRESS" > "$REGEX_CACHE_DIR/STATUS_IN_PROGRESS"
    echo "DONE" > "$REGEX_CACHE_DIR/STATUS_DONE"
    
    # Patterns pour les fichiers
    echo "\\.[a-zA-Z0-9]+$" > "$REGEX_CACHE_DIR/FILENAME_EXTENSION"
    echo "^(.+)\\.[^.]+$" > "$REGEX_CACHE_DIR/FILENAME_WITHOUT_EXT"
    
    # Initialiser les fichiers de statistiques
    echo "0" > "$REGEX_CACHE_DIR/stats_total_hits"
    echo "0" > "$REGEX_CACHE_DIR/stats_total_misses"
    
    REGEX_CACHE_INITIALIZED=true
    
    # Debug si activé
    if [ "$AKLO_CACHE_DEBUG" = "true" ]; then
        local pattern_count
        pattern_count=$(ls "$REGEX_CACHE_DIR" | grep -v "stats_" | wc -l)
        echo "[REGEX_CACHE] Initialized with $pattern_count patterns" >&2
    fi
}

#------------------------------------------------------------------------------
# Récupération d'un pattern regex depuis le cache
#------------------------------------------------------------------------------
get_cached_regex() {
    local pattern_name="$1"
    
    # Initialiser le cache si nécessaire
    if [ "$REGEX_CACHE_INITIALIZED" = "false" ]; then
        init_regex_cache
    fi
    
    local pattern_file="$REGEX_CACHE_DIR/$pattern_name"
    
    # Vérifier si le pattern existe
    if [ -f "$pattern_file" ]; then
        # Incrémenter les hits
        local hits
        hits=$(cat "$REGEX_CACHE_DIR/stats_total_hits" 2>/dev/null || echo "0")
        echo $((hits + 1)) > "$REGEX_CACHE_DIR/stats_total_hits"
        
        # Incrémenter les hits spécifiques pour ce pattern
        local pattern_hits
        pattern_hits=$(cat "$REGEX_CACHE_DIR/stats_${pattern_name}_hits" 2>/dev/null || echo "0")
        echo $((pattern_hits + 1)) > "$REGEX_CACHE_DIR/stats_${pattern_name}_hits"
        
        # Debug si activé
        if [ "$AKLO_CACHE_DEBUG" = "true" ]; then
            local pattern_content
            pattern_content=$(cat "$pattern_file")
            echo "[REGEX_CACHE] HIT: $pattern_name -> $pattern_content" >&2
        fi
        
        cat "$pattern_file"
        return 0
    else
        # Incrémenter les misses
        local misses
        misses=$(cat "$REGEX_CACHE_DIR/stats_total_misses" 2>/dev/null || echo "0")
        echo $((misses + 1)) > "$REGEX_CACHE_DIR/stats_total_misses"
        
        # Incrémenter les misses spécifiques pour ce pattern
        local pattern_misses
        pattern_misses=$(cat "$REGEX_CACHE_DIR/stats_${pattern_name}_misses" 2>/dev/null || echo "0")
        echo $((pattern_misses + 1)) > "$REGEX_CACHE_DIR/stats_${pattern_name}_misses"
        
        # Debug si activé
        if [ "$AKLO_CACHE_DEBUG" = "true" ]; then
            echo "[REGEX_CACHE] MISS: $pattern_name (not found)" >&2
        fi
        
        return 1
    fi
}

#------------------------------------------------------------------------------
# Utilisation sécurisée d'un pattern regex avec fallback
#------------------------------------------------------------------------------
use_regex_pattern() {
    local pattern_name="$1"
    local fallback_pattern="$2"
    
    local cached_pattern
    cached_pattern=$(get_cached_regex "$pattern_name" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$cached_pattern" ]; then
        echo "$cached_pattern"
    else
        echo "$fallback_pattern"
    fi
}

#------------------------------------------------------------------------------
# Affichage des statistiques du cache regex
#------------------------------------------------------------------------------
show_regex_cache_stats() {
    if [ "$REGEX_CACHE_INITIALIZED" = "false" ]; then
        echo "Cache regex non initialisé"
        return 1
    fi
    
    echo "📊 Statistiques du Cache Regex"
    echo "================================"
    
    local pattern_count
    pattern_count=$(ls "$REGEX_CACHE_DIR" | grep -v "stats_" | wc -l)
    echo "Patterns cachés: $pattern_count"
    echo ""
    
    local total_hits
    total_hits=$(cat "$REGEX_CACHE_DIR/stats_total_hits" 2>/dev/null || echo "0")
    local total_misses
    total_misses=$(cat "$REGEX_CACHE_DIR/stats_total_misses" 2>/dev/null || echo "0")
    
    # Afficher les stats par pattern
    for pattern_file in "$REGEX_CACHE_DIR"/*; do
        local filename
        filename=$(basename "$pattern_file")
        
        # Ignorer les fichiers de stats
        if echo "$filename" | grep -q "^stats_"; then
            continue
        fi
        
        local hits
        hits=$(cat "$REGEX_CACHE_DIR/stats_${filename}_hits" 2>/dev/null || echo "0")
        local misses
        misses=$(cat "$REGEX_CACHE_DIR/stats_${filename}_misses" 2>/dev/null || echo "0")
        local total=$((hits + misses))
        
        if [ $total -gt 0 ]; then
            local hit_rate=$((hits * 100 / total))
            printf "%-20s: %3d hits, %3d misses (%3d%% hit rate)\n" \
                   "$filename" "$hits" "$misses" "$hit_rate"
        fi
    done
    
    echo ""
    local grand_total=$((total_hits + total_misses))
    if [ $grand_total -gt 0 ]; then
        local overall_hit_rate=$((total_hits * 100 / grand_total))
        echo "Total: $total_hits hits, $total_misses misses (${overall_hit_rate}% hit rate)"
    else
        echo "Aucune utilisation enregistrée"
    fi
}

#------------------------------------------------------------------------------
# Nettoyage du cache regex
#------------------------------------------------------------------------------
clear_regex_cache() {
    if [ -d "$REGEX_CACHE_DIR" ]; then
        rm -rf "$REGEX_CACHE_DIR"
    fi
    REGEX_CACHE_INITIALIZED=false
    
    echo "Cache regex nettoyé"
}

#------------------------------------------------------------------------------
# Fonctions utilitaires pour les patterns courants
#------------------------------------------------------------------------------

# Extraction d'ID PBI depuis un nom de fichier
extract_pbi_id() {
    local filename="$1"
    local pattern
    pattern=$(get_cached_regex "PBI_ID" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "$filename" | grep -oE "$pattern" | head -1
    fi
}

# Extraction d'ID TASK depuis un nom de fichier  
extract_task_id() {
    local filename="$1"
    local pattern
    pattern=$(get_cached_regex "TASK_ID" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "$filename" | grep -oE "$pattern" | head -1
    fi
}

# Validation d'une date au format YYYY-MM-DD
validate_date_format() {
    local date_string="$1"
    local pattern
    pattern=$(get_cached_regex "DATE_YYYY_MM_DD" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "$date_string" | grep -qE "^${pattern}$"
    else
        return 1
    fi
}

# Validation d'une ligne de configuration
validate_config_line() {
    local config_line="$1"
    local pattern
    pattern=$(get_cached_regex "CONFIG_KEY_VALUE" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "$config_line" | grep -qE "$pattern"
    else
        return 1
    fi
}

#------------------------------------------------------------------------------
# Nettoyage automatique à la sortie
#------------------------------------------------------------------------------
cleanup_regex_cache() {
    if [ -d "$REGEX_CACHE_DIR" ]; then
        rm -rf "$REGEX_CACHE_DIR"
    fi
}

# Configurer le nettoyage automatique
trap cleanup_regex_cache EXIT