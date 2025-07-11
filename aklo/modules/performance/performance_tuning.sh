#!/usr/bin/env bash

# Système de configuration tuning et gestion mémoire
# TASK-7-5: Configuration adaptative et optimisation selon l'environnement

# Variables globales de configuration performance
PERF_CACHE_MAX_SIZE_MB=${PERF_CACHE_MAX_SIZE_MB:-100}
PERF_CACHE_TTL_HOURS=${PERF_CACHE_TTL_HOURS:-24}
PERF_AUTO_TUNE_ENABLED=${PERF_AUTO_TUNE_ENABLED:-true}
PERF_ENVIRONMENT=${PERF_ENVIRONMENT:-auto}
PERF_MEMORY_LIMIT_MB=${PERF_MEMORY_LIMIT_MB:-500}
PERF_CLEANUP_INTERVAL_MINUTES=${PERF_CLEANUP_INTERVAL_MINUTES:-30}
PERF_MONITORING_LEVEL=${PERF_MONITORING_LEVEL:-normal}

# Variables d'environnement détectées
DETECTED_ENVIRONMENT=""
SYSTEM_MEMORY_MB=""
SYSTEM_CPU_CORES=""

# Chargement de la configuration performance
load_performance_config() {
    local config_file="${AKLO_CONFIG_FILE:-$HOME/.aklo/config/.aklo.conf}"
    
    if [[ -f "$config_file" ]]; then
        # Charger les variables de la section [performance]
        local in_performance_section=false
        
        while IFS='=' read -r key value; do
            # Ignorer les commentaires et lignes vides
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            
            # Détecter le début de la section [performance]
            if [[ "$key" =~ ^\[performance\] ]]; then
                in_performance_section=true
                continue
            fi
            
            # Détecter le début d'une autre section
            if [[ "$key" =~ ^\[.*\] ]]; then
                in_performance_section=false
                continue
            fi
            
            # Charger les variables si on est dans la section [performance]
            if [[ "$in_performance_section" == true ]]; then
                # Nettoyer la valeur (supprimer espaces et guillemets)
                value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//')
                
                case "$key" in
                    cache_max_size_mb)
                        PERF_CACHE_MAX_SIZE_MB="$value"
                        ;;
                    cache_ttl_hours)
                        PERF_CACHE_TTL_HOURS="$value"
                        ;;
                    auto_tune_enabled)
                        PERF_AUTO_TUNE_ENABLED="$value"
                        ;;
                    environment)
                        PERF_ENVIRONMENT="$value"
                        ;;
                    memory_limit_mb)
                        PERF_MEMORY_LIMIT_MB="$value"
                        ;;
                    cleanup_interval_minutes)
                        PERF_CLEANUP_INTERVAL_MINUTES="$value"
                        ;;
                    monitoring_level)
                        PERF_MONITORING_LEVEL="$value"
                        ;;
                esac
            fi
        done < "$config_file"
    fi
    
    # Appliquer l'auto-tuning si activé
    if [[ "$PERF_AUTO_TUNE_ENABLED" == "true" && "$PERF_ENVIRONMENT" == "auto" ]]; then
        auto_tune_performance
    elif [[ "$PERF_ENVIRONMENT" != "auto" ]]; then
        apply_performance_profile "$PERF_ENVIRONMENT"
    fi
}

# Détection de l'environnement d'exécution
detect_environment() {
    # Détection CI/CD
    if [[ -n "$CI" || -n "$GITHUB_ACTIONS" || -n "$JENKINS_URL" || -n "$TRAVIS" || -n "$CIRCLECI" ]]; then
        echo "ci"
        return 0
    fi
    
    # Détection production
    if [[ "$NODE_ENV" == "production" || -n "$PRODUCTION" || -n "$PROD" ]]; then
        echo "production"
        return 0
    fi
    
    # Détection développement (par défaut)
    echo "local"
}

# Application des profils de performance prédéfinis
apply_performance_profile() {
    local profile="$1"
    
    case "$profile" in
        "dev"|"local")
            # Profil développement : ressources limitées, monitoring verbose
            PERF_CACHE_MAX_SIZE_MB=25
            PERF_CLEANUP_INTERVAL_MINUTES=10
            PERF_MONITORING_LEVEL="verbose"
            PERF_MEMORY_LIMIT_MB=100
            ;;
        "test"|"ci")
            # Profil test : équilibré, optimisé pour vitesse
            PERF_CACHE_MAX_SIZE_MB=50
            PERF_CLEANUP_INTERVAL_MINUTES=15
            PERF_MONITORING_LEVEL="normal"
            PERF_MEMORY_LIMIT_MB=200
            ;;
        "prod"|"production")
            # Profil production : ressources maximales, monitoring minimal
            PERF_CACHE_MAX_SIZE_MB=200
            PERF_CLEANUP_INTERVAL_MINUTES=60
            PERF_MONITORING_LEVEL="minimal"
            PERF_MEMORY_LIMIT_MB=1000
            ;;
        *)
            echo "⚠️  Profil inconnu: $profile, utilisation des valeurs par défaut" >&2
            ;;
    esac
    
    DETECTED_ENVIRONMENT="$profile"
}

# Auto-tuning basé sur la détection d'environnement et ressources système
auto_tune_performance() {
    # Détecter l'environnement
    local env=$(detect_environment)
    DETECTED_ENVIRONMENT="$env"
    
    # Détecter les ressources système
    detect_system_resources
    
    # Appliquer le profil de base selon l'environnement
    apply_performance_profile "$env"
    
    # Ajustements fins selon les ressources disponibles
    if [[ -n "$SYSTEM_MEMORY_MB" ]]; then
        # Ajuster la limite mémoire selon RAM disponible
        if [[ "$SYSTEM_MEMORY_MB" -lt 1000 ]]; then
            # Système avec peu de RAM
            PERF_CACHE_MAX_SIZE_MB=$((PERF_CACHE_MAX_SIZE_MB / 2))
            PERF_MEMORY_LIMIT_MB=$((SYSTEM_MEMORY_MB / 10))
        elif [[ "$SYSTEM_MEMORY_MB" -gt 8000 ]]; then
            # Système avec beaucoup de RAM
            PERF_CACHE_MAX_SIZE_MB=$((PERF_CACHE_MAX_SIZE_MB * 2))
            PERF_MEMORY_LIMIT_MB=$((SYSTEM_MEMORY_MB / 5))
        fi
    fi
    
    # Ajustements selon le nombre de CPU cores
    if [[ -n "$SYSTEM_CPU_CORES" && "$SYSTEM_CPU_CORES" -gt 4 ]]; then
        # Système multi-core : réduire l'intervalle de nettoyage
        PERF_CLEANUP_INTERVAL_MINUTES=$((PERF_CLEANUP_INTERVAL_MINUTES / 2))
    fi
    
    # Forcer la validation après auto-tuning
    validate_performance_config || {
        echo "⚠️  Auto-tuning a produit une configuration invalide, fallback vers défauts" >&2
        reset_to_defaults
    }
}

# Détection des ressources système
detect_system_resources() {
    # Détecter la RAM disponible (en MB)
    if command -v free >/dev/null 2>&1; then
        # Linux
        SYSTEM_MEMORY_MB=$(free -m | awk 'NR==2{print $2}')
    elif command -v sysctl >/dev/null 2>&1; then
        # macOS - utiliser sysctl pour la RAM totale
        local mem_bytes=$(sysctl -n hw.memsize 2>/dev/null)
        if [[ -n "$mem_bytes" ]]; then
            SYSTEM_MEMORY_MB=$((mem_bytes / 1024 / 1024))
        fi
    fi
    
    # Détecter le nombre de CPU cores
    if command -v nproc >/dev/null 2>&1; then
        # Linux
        SYSTEM_CPU_CORES=$(nproc)
    elif command -v sysctl >/dev/null 2>&1; then
        # macOS
        SYSTEM_CPU_CORES=$(sysctl -n hw.ncpu 2>/dev/null)
    fi
    
    # Valeurs par défaut si détection échoue
    SYSTEM_MEMORY_MB=${SYSTEM_MEMORY_MB:-2048}
    SYSTEM_CPU_CORES=${SYSTEM_CPU_CORES:-2}
}

# Validation de la configuration performance
validate_performance_config() {
    local errors=0
    
    # Vérifier que les valeurs sont des nombres positifs
    if ! [[ "$PERF_CACHE_MAX_SIZE_MB" =~ ^[0-9]+$ ]] || [[ "$PERF_CACHE_MAX_SIZE_MB" -le 0 ]]; then
        echo "❌ Erreur: cache_max_size_mb doit être un nombre positif" >&2
        errors=$((errors + 1))
    fi
    
    if ! [[ "$PERF_MEMORY_LIMIT_MB" =~ ^[0-9]+$ ]] || [[ "$PERF_MEMORY_LIMIT_MB" -le 0 ]]; then
        echo "❌ Erreur: memory_limit_mb doit être un nombre positif" >&2
        errors=$((errors + 1))
    fi
    
    if ! [[ "$PERF_CLEANUP_INTERVAL_MINUTES" =~ ^[0-9]+$ ]] || [[ "$PERF_CLEANUP_INTERVAL_MINUTES" -le 0 ]]; then
        echo "❌ Erreur: cleanup_interval_minutes doit être un nombre positif" >&2
        errors=$((errors + 1))
    fi
    
    # Vérifier la cohérence des limites
    if [[ "$PERF_CACHE_MAX_SIZE_MB" -gt "$PERF_MEMORY_LIMIT_MB" ]]; then
        echo "❌ Erreur: cache_max_size_mb ($PERF_CACHE_MAX_SIZE_MB) > memory_limit_mb ($PERF_MEMORY_LIMIT_MB)" >&2
        errors=$((errors + 1))
    fi
    
    # Vérifier les valeurs d'énumération
    case "$PERF_MONITORING_LEVEL" in
        minimal|normal|verbose) ;;
        *)
            echo "❌ Erreur: monitoring_level doit être minimal, normal ou verbose" >&2
            errors=$((errors + 1))
            ;;
    esac
    
    return $errors
}

# Nettoyage mémoire intelligent des caches
cleanup_memory_caches() {
    local cache_dir="${AKLO_CACHE_DIR:-$HOME/.aklo/cache}"
    [[ ! -d "$cache_dir" ]] && return 0
    
    # Calculer la taille actuelle des caches
    local current_size_kb=$(du -sk "$cache_dir" 2>/dev/null | cut -f1)
    local current_size_mb=$((current_size_kb / 1024))
    
    # Si la taille est dans la limite, pas de nettoyage nécessaire
    if [[ "$current_size_mb" -le "$PERF_CACHE_MAX_SIZE_MB" ]]; then
        return 0
    fi
    
    echo "🧹 Nettoyage des caches: ${current_size_mb}MB > ${PERF_CACHE_MAX_SIZE_MB}MB limite"
    
    # Stratégie LRU : supprimer les fichiers les plus anciens
    local target_size_mb=$((PERF_CACHE_MAX_SIZE_MB * 80 / 100)) # 80% de la limite
    local files_removed=0
    
    # Lister tous les fichiers de cache par date d'accès (LRU)
    find "$cache_dir" -type f -exec ls -ltu {} + 2>/dev/null | \
    sort -k6,8 | \
    while read -r line; do
        local file=$(echo "$line" | awk '{print $NF}')
        [[ -f "$file" ]] || continue
        
        # Supprimer le fichier
        rm -f "$file" 2>/dev/null && files_removed=$((files_removed + 1))
        
        # Vérifier si on a atteint la taille cible
        current_size_kb=$(du -sk "$cache_dir" 2>/dev/null | cut -f1)
        current_size_mb=$((current_size_kb / 1024))
        
        if [[ "$current_size_mb" -le "$target_size_mb" ]]; then
            break
        fi
    done
    
    echo "✅ Nettoyage terminé: ${files_removed} fichiers supprimés"
}

# Diagnostic mémoire détaillé
get_memory_diagnostics() {
    local cache_dir="${AKLO_CACHE_DIR:-$HOME/.aklo/cache}"
    
    echo "🔍 DIAGNOSTIC MÉMOIRE AKLO"
    echo "=========================="
    echo ""
    
    # Configuration actuelle
    echo "📋 Configuration Performance:"
    echo "   Cache Max Size: ${PERF_CACHE_MAX_SIZE_MB}MB"
    echo "   Memory Limit: ${PERF_MEMORY_LIMIT_MB}MB"
    echo "   Cleanup Interval: ${PERF_CLEANUP_INTERVAL_MINUTES}min"
    echo "   Monitoring Level: ${PERF_MONITORING_LEVEL}"
    echo "   Environment: ${DETECTED_ENVIRONMENT:-auto}"
    echo ""
    
    # Ressources système
    if [[ -n "$SYSTEM_MEMORY_MB" || -n "$SYSTEM_CPU_CORES" ]]; then
        echo "💻 Ressources Système:"
        [[ -n "$SYSTEM_MEMORY_MB" ]] && echo "   RAM Disponible: ${SYSTEM_MEMORY_MB}MB"
        [[ -n "$SYSTEM_CPU_CORES" ]] && echo "   CPU Cores: ${SYSTEM_CPU_CORES}"
        echo ""
    fi
    
    # Cache Usage
    echo "📊 Cache Usage:"
    if [[ -d "$cache_dir" ]]; then
        local total_size_kb=$(du -sk "$cache_dir" 2>/dev/null | cut -f1)
        local total_size_mb=$((total_size_kb / 1024))
        local usage_percent=$((total_size_mb * 100 / PERF_CACHE_MAX_SIZE_MB))
        
        echo "   Total Size: ${total_size_mb}MB / ${PERF_CACHE_MAX_SIZE_MB}MB (${usage_percent}%)"
        
        # Détail par type de cache
        for cache_type in regex id batch; do
            local cache_path="$cache_dir/$cache_type"
            if [[ -d "$cache_path" ]]; then
                local size_kb=$(du -sk "$cache_path" 2>/dev/null | cut -f1)
                local size_mb=$((size_kb / 1024))
                local file_count=$(find "$cache_path" -type f 2>/dev/null | wc -l)
                # Capitaliser le premier caractère proprement
                local cache_name
                case "$cache_type" in
                    regex) cache_name="Regex" ;;
                    id) cache_name="ID" ;;
                    batch) cache_name="Batch" ;;
                    *) cache_name="$(echo "${cache_type}" | sed 's/^./\U&/')" ;;
                esac
                echo "   ${cache_name} Cache: ${size_mb}MB (${file_count} fichiers)"
            else
                local cache_name
                case "$cache_type" in
                    regex) cache_name="Regex" ;;
                    id) cache_name="ID" ;;
                    batch) cache_name="Batch" ;;
                    *) cache_name="$(echo "${cache_type}" | sed 's/^./\U&/')" ;;
                esac
                echo "   ${cache_name} Cache: 0MB (non initialisé)"
            fi
        done
    else
        echo "   Aucun cache trouvé dans: $cache_dir"
    fi
    
    # Recommandations
    echo ""
    echo "💡 Recommandations:"
    if [[ -d "$cache_dir" ]]; then
        local total_size_kb=$(du -sk "$cache_dir" 2>/dev/null | cut -f1)
        local total_size_mb=$((total_size_kb / 1024))
        
        if [[ "$total_size_mb" -gt "$PERF_CACHE_MAX_SIZE_MB" ]]; then
            echo "   ⚠️  Cache dépasse la limite - nettoyage recommandé"
        elif [[ "$total_size_mb" -lt $((PERF_CACHE_MAX_SIZE_MB / 10)) ]]; then
            echo "   ✅ Cache sous-utilisé - limite peut être réduite"
        else
            echo "   ✅ Utilisation cache optimale"
        fi
    fi
}

# Vérification des limites de taille pour un cache spécifique
check_cache_size_limit() {
    local cache_type="$1"
    local cache_dir="${AKLO_CACHE_DIR:-$HOME/.aklo/cache}"
    local cache_path="$cache_dir/$cache_type"
    
    [[ ! -d "$cache_path" ]] && return 0
    
    local size_kb=$(du -sk "$cache_path" 2>/dev/null | cut -f1)
    local size_mb=$((size_kb / 1024))
    local limit_mb=$((PERF_CACHE_MAX_SIZE_MB / 3)) # 1/3 de la limite totale par cache
    
    if [[ "$size_mb" -gt "$limit_mb" ]]; then
        return 1
    fi
    
    return 0
}

# Reset vers les valeurs par défaut
reset_to_defaults() {
    PERF_CACHE_MAX_SIZE_MB=100
    PERF_CACHE_TTL_HOURS=24
    PERF_AUTO_TUNE_ENABLED=true
    PERF_ENVIRONMENT=auto
    PERF_MEMORY_LIMIT_MB=500
    PERF_CLEANUP_INTERVAL_MINUTES=30
    PERF_MONITORING_LEVEL=normal
}

# Initialisation automatique si pas en mode test
if [[ -z "$AKLO_TEST_MODE" ]]; then
    load_performance_config
fi