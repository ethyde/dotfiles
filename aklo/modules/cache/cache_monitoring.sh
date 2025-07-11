#!/usr/bin/env bash

# Fonctions de monitoring et configuration cache (TASK-6-4)
# Phase GREEN : Implémentation minimale

# Configuration cache par défaut
CACHE_ENABLED="${CACHE_ENABLED:-true}"
CACHE_DIR="${AKLO_CACHE_DIR:-${CACHE_DIR:-/tmp/aklo_cache}}"
CACHE_MAX_SIZE_MB="${CACHE_MAX_SIZE_MB:-100}"
CACHE_TTL_DAYS="${CACHE_TTL_DAYS:-7}"
CACHE_CLEANUP_ON_START="${CACHE_CLEANUP_ON_START:-true}"
CACHE_DEBUG="${CACHE_DEBUG:-false}"

# Fichier de métriques
CACHE_METRICS_FILE="${CACHE_DIR}/cache_metrics.json"

# Fonction pour lire la configuration cache depuis .aklo.conf
get_cache_config() {
    local config_file=".aklo.conf"
    
    # Chercher le fichier de config
    if [ ! -f "$config_file" ]; then
        local script_dir="$(dirname "$0")"
        config_file="${script_dir}/../config/.aklo.conf"
    fi
    
    if [ -f "$config_file" ]; then
        # Lire la configuration cache (format INI et format simple)
        if grep -q "^\[cache\]" "$config_file" 2>/dev/null; then
            # Format INI
            local in_cache_section=false
            while IFS= read -r line; do
                if [[ "$line" =~ ^\[cache\]$ ]]; then
                    in_cache_section=true
                elif [[ "$line" =~ ^\[.*\]$ ]]; then
                    in_cache_section=false
                elif [ "$in_cache_section" = true ] && [[ "$line" =~ ^[^#]*= ]]; then
                    local key=$(echo "$line" | cut -d'=' -f1 | tr -d ' ')
                    local value=$(echo "$line" | cut -d'=' -f2- | tr -d ' ')
                    
                    case "$key" in
                        enabled) CACHE_ENABLED="$value" ;;
                        cache_dir) CACHE_DIR="$value" ;;
                        max_size_mb) CACHE_MAX_SIZE_MB="$value" ;;
                        ttl_days) CACHE_TTL_DAYS="$value" ;;
                        cleanup_on_start) CACHE_CLEANUP_ON_START="$value" ;;
                    esac
                fi
            done < "$config_file"
        fi
        
        # Format simple (rétrocompatibilité)
        if grep -q "^CACHE_ENABLED=" "$config_file" 2>/dev/null; then
            CACHE_ENABLED=$(grep "^CACHE_ENABLED=" "$config_file" | cut -d'=' -f2) 2>/dev/null || true
        fi
        if grep -q "^CACHE_DEBUG=" "$config_file" 2>/dev/null; then
            CACHE_DEBUG=$(grep "^CACHE_DEBUG=" "$config_file" | cut -d'=' -f2) 2>/dev/null || true
        fi
    fi
    # Priorité à la variable d'environnement AKLO_CACHE_DIR
    CACHE_DIR="${AKLO_CACHE_DIR:-${CACHE_DIR:-/tmp/aklo_cache}}"
    # Mettre à jour le fichier de métriques
    CACHE_METRICS_FILE="${CACHE_DIR}/cache_metrics.json"
}

# Fonction pour initialiser les métriques
init_cache_metrics() {
    mkdir -p "$CACHE_DIR"
    
    if [ ! -f "$CACHE_METRICS_FILE" ]; then
        cat > "$CACHE_METRICS_FILE" << EOF
{
  "hits": 0,
  "misses": 0,
  "total_requests": 0,
  "total_time_saved_ms": 0,
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "cache_size_bytes": 0,
  "files_count": 0
}
EOF
    fi
}

# Fonction pour enregistrer une métrique
record_cache_metric() {
    local metric_type="$1"  # "hit" ou "miss"
    local time_saved_ms="$2"  # temps économisé en ms (optionnel)
    
    [ "$CACHE_ENABLED" != "true" ] && return 0
    
    mkdir -p "$CACHE_DIR"
    init_cache_metrics
    
    # Lire les métriques actuelles
    local current_hits=0
    local current_misses=0
    local current_total=0
    local current_time_saved=0
    
    if [ -f "$CACHE_METRICS_FILE" ]; then
        current_hits=$(grep '"hits":' "$CACHE_METRICS_FILE" | grep -o '[0-9]\+' | head -1)
        current_misses=$(grep '"misses":' "$CACHE_METRICS_FILE" | grep -o '[0-9]\+' | head -1)
        current_total=$(grep '"total_requests":' "$CACHE_METRICS_FILE" | grep -o '[0-9]\+' | head -1)
        current_time_saved=$(grep '"total_time_saved_ms":' "$CACHE_METRICS_FILE" | grep -o '[0-9]\+' | head -1)
        
        # Valeurs par défaut
        current_hits=${current_hits:-0}
        current_misses=${current_misses:-0}
        current_total=${current_total:-0}
        current_time_saved=${current_time_saved:-0}
    fi
    
    # Mettre à jour les métriques
    case "$metric_type" in
        "hit")
            current_hits=$((current_hits + 1))
            current_time_saved=$((current_time_saved + ${time_saved_ms:-0}))
            ;;
        "miss")
            current_misses=$((current_misses + 1))
            ;;
    esac
    
    current_total=$((current_hits + current_misses))
    
    # Calculer la taille du cache
    local cache_size=0
    local files_count=0
    if [ -d "$CACHE_DIR" ]; then
        cache_size=$(du -sb "$CACHE_DIR" 2>/dev/null | cut -f1 || echo 0)
        files_count=$(find "$CACHE_DIR" -name "*.parsed" 2>/dev/null | wc -l || echo 0)
    fi
    
    # Écrire les nouvelles métriques
    cat > "$CACHE_METRICS_FILE" << EOF
{
  "hits": $current_hits,
  "misses": $current_misses,
  "total_requests": $current_total,
  "total_time_saved_ms": $current_time_saved,
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "cache_size_bytes": $cache_size,
  "files_count": $files_count
}
EOF
}

# Fonction pour afficher les statistiques cache
show_cache_status() {
    get_cache_config
    
    echo "🗂️  STATUT DU CACHE AKLO"
    echo "======================================="
    echo "Configuration:"
    echo "  Activé: $CACHE_ENABLED"
    echo "  Répertoire: $CACHE_DIR"
    echo "  Taille max: ${CACHE_MAX_SIZE_MB}MB"
    echo "  TTL: ${CACHE_TTL_DAYS} jours"
    echo "  Debug: $CACHE_DEBUG"
    echo ""
    
    if [ "$CACHE_ENABLED" != "true" ]; then
        echo "❌ Cache désactivé"
        return 0
    fi
    
    if [ ! -f "$CACHE_METRICS_FILE" ]; then
        echo "📊 Aucune métrique disponible"
        echo "💡 Utilisez aklo pour générer des artefacts et créer des métriques"
        return 0
    fi
    
    # Lire les métriques avec extraction robuste
    local hits=$(grep '"hits":' "$CACHE_METRICS_FILE" | grep -o '[0-9]\+' | head -1)
    local misses=$(grep '"misses":' "$CACHE_METRICS_FILE" | grep -o '[0-9]\+' | head -1)
    local total=$(grep '"total_requests":' "$CACHE_METRICS_FILE" | grep -o '[0-9]\+' | head -1)
    local time_saved=$(grep '"total_time_saved_ms":' "$CACHE_METRICS_FILE" | grep -o '[0-9]\+' | head -1)
    local cache_size=$(grep '"cache_size_bytes":' "$CACHE_METRICS_FILE" | grep -o '[0-9]\+' | head -1)
    local files_count=$(grep '"files_count":' "$CACHE_METRICS_FILE" | grep -o '[0-9]\+' | head -1)
    
    # Valeurs par défaut si extraction échoue
    hits=${hits:-0}
    misses=${misses:-0}
    total=${total:-0}
    time_saved=${time_saved:-0}
    cache_size=${cache_size:-0}
    files_count=${files_count:-0}
    local last_updated=$(grep '"last_updated"' "$CACHE_METRICS_FILE" | cut -d'"' -f4 || echo "N/A")
    
    # Calculer les ratios
    local hit_ratio=0
    local miss_ratio=0
    if [ $total -gt 0 ]; then
        hit_ratio=$((hits * 100 / total))
        miss_ratio=$((misses * 100 / total))
    fi
    
    # Convertir la taille en format lisible
    local size_display
    if [ $cache_size -gt 1048576 ]; then
        size_display="$((cache_size / 1048576))MB"
    elif [ $cache_size -gt 1024 ]; then
        size_display="$((cache_size / 1024))KB"
    else
        size_display="${cache_size}B"
    fi
    
    echo "📊 Statistiques:"
    echo "  Hits: $hits (${hit_ratio}%)"
    echo "  Misses: $misses (${miss_ratio}%)"
    echo "  Total requêtes: $total"
    echo "  Temps économisé: ${time_saved}ms"
    echo "  Fichiers en cache: $files_count"
    echo "  Taille cache: $size_display"
    echo "  Dernière MAJ: $last_updated"
    
    # Afficher les fichiers cache
    if [ $files_count -gt 0 ]; then
        echo ""
        echo "📁 Fichiers en cache:"
        find "$CACHE_DIR" -name "*.parsed" -exec basename {} \; 2>/dev/null | sort | sed 's/^/  /'
    fi
}

# Fonction pour vider le cache
clear_cache() {
    get_cache_config
    
    if [ "$CACHE_ENABLED" != "true" ]; then
        echo "❌ Cache désactivé - Rien à vider"
        return 0
    fi
    
    if [ ! -d "$CACHE_DIR" ]; then
        echo "✅ Cache déjà vide"
        return 0
    fi
    
    local files_count=$(find "$CACHE_DIR" -name "*.parsed" 2>/dev/null | wc -l || echo 0)
    
    if [ $files_count -eq 0 ]; then
        echo "✅ Cache déjà vide"
        return 0
    fi
    
    echo "🗑️  Vidage du cache..."
    find "$CACHE_DIR" -type f -name "*.parsed" -exec rm -f {} + 2>/dev/null || true
    rm -f "$CACHE_METRICS_FILE" 2>/dev/null || true
    
    echo "✅ Cache vidé ($files_count fichiers supprimés)"
}

# Fonction pour benchmarker le cache
benchmark_cache() {
    get_cache_config
    
    echo "🏃 BENCHMARK CACHE AKLO"
    echo "======================================="
    
    if [ "$CACHE_ENABLED" != "true" ]; then
        echo "❌ Cache désactivé - Impossible de benchmarker"
        return 1
    fi
    
    # Vider le cache pour test propre
    clear_cache >/dev/null 2>&1
    
    echo "📊 Test de performance avec protocole PRODUCT-OWNER..."
    
    # Test 1: Cache miss (première fois)
    echo "🔴 Test cache miss..."
    local start_time=$(date +%s%N)
    if command -v parse_and_generate_artefact >/dev/null 2>&1; then
        parse_and_generate_artefact "00-PRODUCT-OWNER" "PBI" "full" "/tmp/benchmark_miss.xml" "" >/dev/null 2>&1
    else
        echo "⚠️  Fonction parse_and_generate_artefact non disponible"
        return 1
    fi
    local end_time=$(date +%s%N)
    local duration_miss=$((($end_time - $start_time) / 1000000))
    log_cache_event "MISS" "Cache miss: ${duration_miss}ms"
    
    # Test 2: Cache hit (deuxième fois)
    echo "🟢 Test cache hit..."
    start_time=$(date +%s%N)
    parse_and_generate_artefact "00-PRODUCT-OWNER" "PBI" "full" "/tmp/benchmark_hit.xml" "" >/dev/null 2>&1
    end_time=$(date +%s%N)
    local duration_hit=$((($end_time - $start_time) / 1000000))
    log_cache_event "HIT" "Cache hit: ${duration_hit}ms"
    
    # Calculer le gain
    local gain=$((duration_miss - duration_hit))
    local gain_percent=0
    if [ $duration_miss -gt 0 ]; then
        gain_percent=$((gain * 100 / duration_miss))
    fi
    log_cache_event "GAIN" "Gain: ${gain}ms (${gain_percent}%)"
    
    if [ $gain -gt 0 ]; then
        echo "✅ Cache efficace !"
    else
        echo "⚠️  Pas de gain mesurable"
    fi
    
    # Nettoyer
    rm -f /tmp/benchmark_miss.xml /tmp/benchmark_hit.xml 2>/dev/null || true
}

# Fonction pour nettoyer le cache selon TTL
cleanup_cache_by_ttl() {
    get_cache_config
    
    [ "$CACHE_ENABLED" != "true" ] && return 0
    [ ! -d "$CACHE_DIR" ] && return 0
    
    local ttl_seconds=$((CACHE_TTL_DAYS * 24 * 3600))
    local current_time=$(date +%s)
    local cleaned_count=0
    
    find "$CACHE_DIR" -name "*.parsed" -type f 2>/dev/null | while read -r file; do
        if [ -f "$file" ]; then
            local file_mtime=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null || echo 0)
            local file_age=$((current_time - file_mtime))
            
            if [ $file_age -gt $ttl_seconds ]; then
                rm -f "$file" 2>/dev/null || true
                cleaned_count=$((cleaned_count + 1))
            fi
        fi
    done
    
    if [ $cleaned_count -gt 0 ]; then
        echo "🧹 Cache nettoyé: $cleaned_count fichiers expirés supprimés"
    fi
}