#!/usr/bin/env bash
#==============================================================================
# Système de monitoring des opérations I/O (V2 - Robuste)
#==============================================================================

# --- CORRECTION ---
# Au lieu de définir des variables globales, on utilise une fonction de configuration
# qui s'appuie sur la configuration centrale et des chemins robustes.
load_monitoring_config() {
    IO_MONITORING_ENABLED=$(get_config "IO_MONITORING_ENABLED" "monitoring" "true")
    local default_metrics_dir="${AKLO_PROJECT_ROOT}/.aklo_metrics"
    IO_METRICS_DIR=$(get_config "IO_METRICS_DIR" "monitoring" "$default_metrics_dir")
    IO_ALERT_THRESHOLD_MS=$(get_config "IO_ALERT_THRESHOLD_MS" "monitoring" "1000")
    IO_RETENTION_DAYS=$(get_config "IO_RETENTION_DAYS" "monitoring" "7")
    IO_DASHBOARD_ENABLED=$(get_config "IO_DASHBOARD_ENABLED" "monitoring" "true")
}

# La fonction start_io_monitoring appellera load_monitoring_config
# et utilisera IO_METRICS_DIR qui est maintenant correctement défini.
start_io_monitoring() {
    load_monitoring_config
    [[ "$IO_MONITORING_ENABLED" != "true" ]] && return 0
    
    # Créer les répertoires nécessaires
    mkdir -p "$IO_METRICS_DIR"/{io_operations,cache_stats,performance,benchmarks,alerts}
    
    # Initialiser la session
    IO_SESSION_ID="session_$(date +%Y%m%d_%H%M%S)"
    IO_SESSION_START=$(date +%s)
    IO_CURRENT_SESSION_FILE="$IO_METRICS_DIR/current_session.log"
    
    # Créer le fichier de session
    {
        echo "# Aklo I/O Monitoring Session"
        echo "# Session ID: $IO_SESSION_ID"
        echo "# Start time: $(date)"
        echo "# Format: timestamp|operation_type|target|duration_ms|status|details"
        echo ""
    } > "$IO_CURRENT_SESSION_FILE"
    
    # Nettoyer les anciennes métriques en arrière-plan
    cleanup_old_metrics &
}

# Enregistrement d'une opération I/O
track_io_operation() {
    [[ "$IO_MONITORING_ENABLED" != "true" ]] && return 0
    
    # Vérifier à nouveau après le chargement de la config
    load_monitoring_config
    [[ "$IO_MONITORING_ENABLED" != "true" ]] && return 0
    
    [[ -z "$IO_CURRENT_SESSION_FILE" ]] && start_io_monitoring
    
    local operation_type="$1"
    local target="$2"
    local duration_ms="$3"
    local status="$4"
    local details="${5:-}"
    
    local timestamp=$(date +%s)
    local iso_time=$(date -r "$timestamp" '+%Y-%m-%d %H:%M:%S')
    
    # Enregistrer l'opération
    echo "$timestamp|$operation_type|$target|$duration_ms|$status|$details" >> "$IO_CURRENT_SESSION_FILE"
    
    # Vérifier les seuils d'alerte
    if [[ "$duration_ms" -gt "$IO_ALERT_THRESHOLD_MS" ]]; then
        log_performance_alert "$operation_type" "$target" "$duration_ms" "$iso_time"
    fi
    
    # Mettre à jour les statistiques en temps réel
    update_realtime_stats "$operation_type" "$duration_ms" "$status"
}

# Chargement de la configuration
load_monitoring_config() {
    local config_file="${AKLO_CONFIG_FILE:-$HOME/.aklo/config/.aklo.conf}"
    
    if [[ -f "$config_file" ]]; then
        # Charger uniquement les variables de monitoring
        while IFS='=' read -r key value; do
            [[ "$key" =~ ^IO_ ]] && export "$key=$value"
        done < <(grep '^IO_' "$config_file" 2>/dev/null || true)
    fi
}

# Génération d'un rapport de performance
generate_io_report() {
    [[ ! -f "$IO_CURRENT_SESSION_FILE" ]] && {
        echo "No monitoring data available"
        return 1
    }
    
    local session_file="$IO_CURRENT_SESSION_FILE"
    local total_ops=$(grep -c '^[0-9]' "$session_file" 2>/dev/null || echo "0")
    
    echo "=== I/O Performance Report ==="
    echo "Session: $IO_SESSION_ID"
    echo "Generated: $(date)"
    echo ""
    
    if [[ "$total_ops" -eq 0 ]]; then
        echo "No operations recorded in this session."
        return 0
    fi
    
    echo "Total operations: $total_ops"
    echo ""
    
    # Statistiques par type d'opération
    echo "Operations by type:"
    awk -F'|' 'NF >= 4 && /^[0-9]/ { ops[$2]++; total_time[$2] += $4 } 
               END { for (op in ops) printf "  %s: %d (avg: %.1fms)\n", op, ops[op], total_time[op]/ops[op] }' \
        "$session_file" | sort
    echo ""
    
    # Durée moyenne globale
    local avg_duration=$(awk -F'|' 'NF >= 4 && /^[0-9]/ { sum += $4; count++ } 
                                   END { if (count > 0) printf "%.1f", sum/count; else print "0" }' "$session_file")
    echo "Average duration: ${avg_duration}ms"
    
    # Statistiques de cache
    echo ""
    echo "Cache Performance:"
    local cache_hits=$(grep -c '|hit|' "$session_file" 2>/dev/null || echo "0")
    local cache_misses=$(grep -c '|miss|' "$session_file" 2>/dev/null || echo "0")
    local cache_total=$((cache_hits + cache_misses))
    
    if [[ "$cache_total" -gt 0 ]]; then
        local hit_rate=$(( (cache_hits * 100) / cache_total ))
        echo "  Cache hit rate: ${hit_rate}% ($cache_hits/$cache_total)"
    else
        echo "  No cache operations recorded"
    fi
    
    # Opérations les plus lentes
    echo ""
    echo "Slowest operations:"
    awk -F'|' 'NF >= 4 && /^[0-9]/ { printf "%s|%s|%s|%s\n", $4, $2, $3, $5 }' "$session_file" | \
        sort -nr | head -5 | \
        awk -F'|' '{ printf "  %sms - %s: %s (%s)\n", $1, $2, $3, $4 }'
}

# Vérification des alertes de performance
check_performance_alerts() {
    [[ ! -f "$IO_CURRENT_SESSION_FILE" ]] && return 0
    
    # Cette fonction est appelée automatiquement par track_io_operation
    # mais peut aussi être appelée manuellement
    return 0
}

# Enregistrement d'une alerte de performance
log_performance_alert() {
    local operation_type="$1"
    local target="$2"
    local duration_ms="$3"
    local timestamp="$4"
    
    local alerts_file="$IO_METRICS_DIR/alerts.log"
    
    {
        echo "[$timestamp] SLOW_OPERATION: $operation_type on '$target' took ${duration_ms}ms (threshold: ${IO_ALERT_THRESHOLD_MS}ms)"
    } >> "$alerts_file"
}

# Affichage du dashboard textuel
show_io_dashboard() {
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    echo "║                           I/O MONITORING DASHBOARD                          ║"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [[ ! -f "$IO_CURRENT_SESSION_FILE" ]]; then
        echo "⚠️  No monitoring session active"
        echo "   Run 'aklo status' to start monitoring"
        return 0
    fi
    
    # Section: Résumé des opérations
    echo "📊 Operations Summary"
    echo "─────────────────────"
    local total_ops=$(grep -c '^[0-9]' "$IO_CURRENT_SESSION_FILE" 2>/dev/null || echo "0")
    # Correction: nettoyer les caractères non-numériques
    total_ops=$(echo "$total_ops" | tr -d '\n\r' | sed 's/[^0-9]//g')
    total_ops=${total_ops:-0}
    local session_duration=$(($(date +%s) - IO_SESSION_START))
    
    echo "   Active session: $IO_SESSION_ID"
    echo "   Duration: ${session_duration}s"
    echo "   Total operations: $total_ops"
    
    if [[ "$total_ops" -gt 0 ]]; then
        echo "   Operations per second: $(( total_ops / (session_duration + 1) ))"
    fi
    echo ""
    
    # Section: Performance des caches
    echo "🚀 Cache Performance"
    echo "───────────────────"
    local cache_hits=$(grep -c '|hit|' "$IO_CURRENT_SESSION_FILE" 2>/dev/null || echo "0")
    local cache_misses=$(grep -c '|miss|' "$IO_CURRENT_SESSION_FILE" 2>/dev/null || echo "0")
    # Correction: nettoyer et s'assurer que les variables sont des nombres entiers
    cache_hits=$(echo "$cache_hits" | tr -d '\n\r' | sed 's/[^0-9]//g')
    cache_misses=$(echo "$cache_misses" | tr -d '\n\r' | sed 's/[^0-9]//g')
    cache_hits=${cache_hits:-0}
    cache_misses=${cache_misses:-0}
    local cache_total=$((cache_hits + cache_misses))
    
    if [[ "$cache_total" -gt 0 ]]; then
        local hit_rate=$(( (cache_hits * 100) / cache_total ))
        echo "   Hit rate: ${hit_rate}% ($cache_hits hits, $cache_misses misses)"
        
        # Détail par type de cache
        echo "   Cache breakdown:"
        awk -F'|' '/cache_lookup/ && /hit|miss/ { 
            gsub(/cache_lookup/, "", $2); gsub(/^_/, "", $3); 
            cache_type = ($3 != "") ? $3 : "unknown"
            if ($5 == "hit") hits[cache_type]++; else misses[cache_type]++
        } 
        END { 
            for (type in hits) printf "     %s: %.0f%% (%d/%d)\n", type, (hits[type]*100)/(hits[type]+misses[type]), hits[type], hits[type]+misses[type]
        }' "$IO_CURRENT_SESSION_FILE" 2>/dev/null || echo "     No cache data available"
    else
        echo "   No cache operations recorded"
    fi
    echo ""
    
    # Section: Alertes récentes
    echo "⚠️  Recent Alerts"
    echo "─────────────────"
    local alerts_file="$IO_METRICS_DIR/alerts.log"
    if [[ -f "$alerts_file" ]]; then
        local recent_alerts=$(tail -3 "$alerts_file" 2>/dev/null)
        if [[ -n "$recent_alerts" ]]; then
            echo "$recent_alerts" | sed 's/^/   /'
        else
            echo "   No recent alerts"
        fi
    else
        echo "   No alerts recorded"
    fi
    echo ""
    
    # Section: Opérations récentes
    echo "📈 Recent Operations (last 5)"
    echo "─────────────────────────────"
    if [[ "$total_ops" -gt 0 ]]; then
        tail -5 "$IO_CURRENT_SESSION_FILE" | grep '^[0-9]' | \
        awk -F'|' '{ 
            cmd = "date -r " $1 " +\"%H:%M:%S\""
            cmd | getline time_str
            close(cmd)
            printf "   %s %s %s (%sms) %s\n", time_str, $2, $3, $4, $5 
        }' 2>/dev/null || echo "   No recent operations"
    else
        echo "   No operations recorded"
    fi
}

# Nettoyage des métriques anciennes
cleanup_old_metrics() {
    [[ ! -d "$IO_METRICS_DIR" ]] && return 0
    
    # Nettoyer les fichiers plus anciens que IO_RETENTION_DAYS
    # Utiliser une approche compatible macOS et Linux
    if command -v find >/dev/null 2>&1; then
        # Pour macOS, utiliser -mtime +N pour les fichiers plus anciens que N jours
        find "$IO_METRICS_DIR" -type f -name "*.log" -mtime +${IO_RETENTION_DAYS} -exec rm -f {} \; 2>/dev/null || true
        
        # Nettoyer les répertoires vides
        find "$IO_METRICS_DIR" -type d -empty -exec rmdir {} \; 2>/dev/null || true
    fi
}

# Mise à jour des statistiques en temps réel
update_realtime_stats() {
    local operation_type="$1"
    local duration_ms="$2"
    local status="$3"
    
    # Fichier de statistiques rapides
    local stats_file="$IO_METRICS_DIR/realtime_stats.tmp"
    
    # Mise à jour en arrière-plan pour éviter la latence
    {
        echo "$(date +%s)|$operation_type|$duration_ms|$status" >> "$stats_file"
        
        # Garder seulement les 1000 dernières entrées
        tail -1000 "$stats_file" > "${stats_file}.tmp" && mv "${stats_file}.tmp" "$stats_file"
    } &
}

# Gestion des sessions de benchmark
start_benchmark_session() {
    local benchmark_name="$1"
    
    IO_BENCHMARK_SESSION="$benchmark_name"
    IO_BENCHMARK_START=$(date +%s)
    IO_BENCHMARK_FILE="$IO_METRICS_DIR/benchmarks/${benchmark_name}.log"
    
    {
        echo "# Benchmark: $benchmark_name"
        echo "# Start: $(date)"
        echo ""
    } > "$IO_BENCHMARK_FILE"
}

end_benchmark_session() {
    local benchmark_name="$1"
    
    if [[ -n "$IO_BENCHMARK_SESSION" && "$IO_BENCHMARK_SESSION" == "$benchmark_name" ]]; then
        local duration=$(($(date +%s) - IO_BENCHMARK_START))
        
        {
            echo ""
            echo "# End: $(date)"
            echo "# Duration: ${duration}s"
        } >> "$IO_BENCHMARK_FILE"
        
        # Copier les opérations de la session courante vers le benchmark
        if [[ -f "$IO_CURRENT_SESSION_FILE" ]]; then
            grep "^$IO_BENCHMARK_START" "$IO_CURRENT_SESSION_FILE" >> "$IO_BENCHMARK_FILE" 2>/dev/null || true
        fi
        
        unset IO_BENCHMARK_SESSION IO_BENCHMARK_START IO_BENCHMARK_FILE
    fi
}

# Fonction d'aide pour les tests
get_io_monitoring_status() {
    echo "Monitoring enabled: $IO_MONITORING_ENABLED"
    echo "Metrics directory: $IO_METRICS_DIR"
    echo "Current session: ${IO_SESSION_ID:-none}"
    echo "Session file: ${IO_CURRENT_SESSION_FILE:-none}"
}

# Initialisation automatique si le monitoring est activé
if [[ "$IO_MONITORING_ENABLED" == "true" && -z "$AKLO_TEST_MODE" ]]; then
    start_io_monitoring
fi