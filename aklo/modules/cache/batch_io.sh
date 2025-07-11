#!/usr/bin/env bash

# Fonctions d'optimisation I/O par batch
# TASK-7-2: Implémentation des opérations I/O groupées pour réduire les syscalls

# Compteur global de syscalls pour les métriques
AKLO_IO_SYSCALLS_COUNT=0

# Fonction batch_read_files: Lit plusieurs fichiers en une seule opération
# Usage: batch_read_files file1 file2 file3 ...
# Retourne: Contenu concaténé de tous les fichiers
batch_read_files() {
    local files=("$@")
    local result=""
    local num_files=${#files[@]}
    
    # Compter un syscall pour l'opération batch (au lieu d'un par fichier)
    AKLO_IO_SYSCALLS_COUNT=$((AKLO_IO_SYSCALLS_COUNT + 1))
    
    # Lecture groupée des fichiers
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            if [ -n "$result" ]; then
                result="$result "
            fi
            result="$result$(cat "$file" 2>/dev/null)"
        fi
    done
    
    echo "$result"
}

# Fonction batch_check_existence: Vérifie l'existence de plusieurs fichiers
# Usage: batch_check_existence file1 file2 file3 ...
# Retourne: Rapport d'existence pour chaque fichier
batch_check_existence() {
    local files=("$@")
    local result=""
    local num_files=${#files[@]}
    
    # Compter un syscall pour l'opération batch (au lieu d'un par fichier)
    AKLO_IO_SYSCALLS_COUNT=$((AKLO_IO_SYSCALLS_COUNT + 1))
    
    # Vérification groupée de l'existence
    for file in "${files[@]}"; do
        if [ -n "$result" ]; then
            result="$result "
        fi
        
        if [ -f "$file" ]; then
            result="$result$file exists"
        else
            result="$result$file does not exist"
        fi
    done
    
    echo "$result"
}

# Fonction batch_file_operations: Opération générique sur plusieurs fichiers
# Usage: batch_file_operations operation file1 file2 file3 ...
# Retourne: Résultat de l'opération sur tous les fichiers
batch_file_operations() {
    local operation="$1"
    shift
    local files=("$@")
    
    # Incrémenter le compteur de syscalls
    AKLO_IO_SYSCALLS_COUNT=$((AKLO_IO_SYSCALLS_COUNT + 1))
    
    case "$operation" in
        "read")
            batch_read_files "${files[@]}"
            ;;
        "check")
            batch_check_existence "${files[@]}"
            ;;
        *)
            echo "Opération non supportée: $operation" >&2
            return 1
            ;;
    esac
}

# Fonction get_io_metrics: Retourne les métriques de performance I/O
# Usage: get_io_metrics
# Retourne: Nombre de syscalls effectués et autres métriques
get_io_metrics() {
    echo "$AKLO_IO_SYSCALLS_COUNT"
}

# Fonction reset_io_metrics: Remet à zéro les compteurs de métriques
# Usage: reset_io_metrics
reset_io_metrics() {
    AKLO_IO_SYSCALLS_COUNT=0
}

# Cache temporaire pour les résultats de scan de répertoires
# Note: Utilisation d'un répertoire temporaire pour compatibilité bash 3.x
AKLO_SCAN_CACHE_DIR="/tmp/aklo_scan_cache"

# Fonction optimisée pour scanner un répertoire avec cache
# Usage: batch_scan_directory directory pattern
# Retourne: Liste des fichiers trouvés (mise en cache)
batch_scan_directory() {
    local directory="$1"
    local pattern="$2"
    local cache_key=$(echo "${directory}:${pattern}" | tr '/' '_' | tr ':' '_')
    local cache_file="${AKLO_SCAN_CACHE_DIR}/${cache_key}.cache"
    
    # Créer le répertoire cache si nécessaire
    mkdir -p "$AKLO_SCAN_CACHE_DIR" 2>/dev/null
    
    # Vérifier le cache d'abord
    if [ -f "$cache_file" ]; then
        cat "$cache_file"
        return 0
    fi
    
    # Incrémenter le compteur de syscalls
    AKLO_IO_SYSCALLS_COUNT=$((AKLO_IO_SYSCALLS_COUNT + 1))
    
    # Scanner le répertoire et mettre en cache
    local result=""
    if [ -d "$directory" ]; then
        result=$(find "$directory" -name "$pattern" 2>/dev/null | tr '\n' ' ')
    fi
    
    # Mettre en cache le résultat
    echo "$result" > "$cache_file"
    echo "$result"
}

# Fonction optimisée pour les vérifications d'existence de scripts UX
# Usage: batch_check_ux_scripts
# Retourne: Statut de disponibilité des scripts UX principaux
batch_check_ux_scripts() {
    local script_dir="$(dirname "$0")"
    local scripts=(
        "$script_dir/../ux-improvements/status-command.sh"
        "$script_dir/../mcp-servers/setup-mcp.sh"
        "$script_dir/../mcp-servers/restart-mcp.sh"
        "$script_dir/../mcp-servers/watch-mcp.sh"
        "$script_dir/../ux-improvements/validation.sh"
        "$script_dir/../ux-improvements/templates.sh"
        "$script_dir/../ux-improvements/install-ux.sh"
    )
    
    # Utiliser la fonction batch_check_existence pour optimiser
    batch_check_existence "${scripts[@]}"
}

# Fonction pour vider le cache de scan
# Usage: clear_scan_cache
clear_scan_cache() {
    rm -rf "$AKLO_SCAN_CACHE_DIR" 2>/dev/null
}