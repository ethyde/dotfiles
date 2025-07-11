#!/usr/bin/env bash

# Test du système de configuration tuning et gestion mémoire
# TASK-7-5: Tests unitaires pour le tuning de performance et gestion mémoire

# Import du framework de test
source "$(dirname "$0")/test_framework.sh"

# Variables de test
TEST_CONFIG_DIR="/tmp/aklo_test_config"
TEST_CONFIG_FILE="/tmp/aklo_test_config/.aklo.conf"
TEST_CACHE_DIR="/tmp/aklo_test_cache"

setup() {
    echo "=== Setup test performance tuning ==="
    rm -rf "$TEST_CONFIG_DIR" "$TEST_CACHE_DIR"
    mkdir -p "$TEST_CONFIG_DIR" "$TEST_CACHE_DIR"
    
    # Configuration de test avec section [performance]
    cat > "$TEST_CONFIG_FILE" << 'EOF'
# Configuration Aklo de test
[cache]
enabled=true
cache_dir=/tmp/aklo_test_cache
ttl_days=1

[performance]
cache_max_size_mb=50
cache_ttl_hours=12
auto_tune_enabled=true
environment=auto
memory_limit_mb=200
cleanup_interval_minutes=15
monitoring_level=normal
EOF
    
    # Source du module de tuning (sera créé)
    if [[ -f "$(dirname "$0")/../modules/performance/performance_tuning.sh" ]]; then
        source "$(dirname "$0")/../modules/performance/performance_tuning.sh"
    fi
    
    export AKLO_TEST_MODE=1
    export AKLO_CONFIG_FILE="$TEST_CONFIG_FILE"
    export AKLO_CACHE_DIR="$TEST_CACHE_DIR"
}

teardown() {
    echo "=== Teardown test performance tuning ==="
    rm -rf "$TEST_CONFIG_DIR" "$TEST_CACHE_DIR"
    unset AKLO_TEST_MODE AKLO_CONFIG_FILE AKLO_CACHE_DIR
    unset CI GITHUB_ACTIONS NODE_ENV
}

# Test 1: Chargement de la configuration performance
test_load_performance_config() {
    echo "Test 1: Chargement de la configuration performance"
    
    # Charger la configuration
    load_performance_config
    
    # Vérifier que les variables sont définies
    [[ "$PERF_CACHE_MAX_SIZE_MB" == "50" ]] || fail "PERF_CACHE_MAX_SIZE_MB not loaded correctly"
    [[ "$PERF_CACHE_TTL_HOURS" == "12" ]] || fail "PERF_CACHE_TTL_HOURS not loaded correctly"
    [[ "$PERF_AUTO_TUNE_ENABLED" == "true" ]] || fail "PERF_AUTO_TUNE_ENABLED not loaded correctly"
    [[ "$PERF_MEMORY_LIMIT_MB" == "200" ]] || fail "PERF_MEMORY_LIMIT_MB not loaded correctly"
    [[ "$PERF_MONITORING_LEVEL" == "normal" ]] || fail "PERF_MONITORING_LEVEL not loaded correctly"
    
    echo "✓ Test 1 réussi"
}

# Test 2: Détection d'environnement
test_environment_detection() {
    echo "Test 2: Détection d'environnement"
    
    # Test détection locale (par défaut)
    unset CI GITHUB_ACTIONS NODE_ENV
    local env=$(detect_environment)
    [[ "$env" == "local" ]] || fail "Environment detection failed for local"
    
    # Test détection CI
    export CI=true
    env=$(detect_environment)
    [[ "$env" == "ci" ]] || fail "Environment detection failed for CI"
    
    # Test détection GitHub Actions
    unset CI
    export GITHUB_ACTIONS=true
    env=$(detect_environment)
    [[ "$env" == "ci" ]] || fail "Environment detection failed for GitHub Actions"
    
    # Test détection production
    unset GITHUB_ACTIONS
    export NODE_ENV=production
    env=$(detect_environment)
    [[ "$env" == "production" ]] || fail "Environment detection failed for production"
    
    echo "✓ Test 2 réussi"
}

# Test 3: Application des profils d'environnement
test_performance_profiles() {
    echo "Test 3: Application des profils d'environnement"
    
    # Test profil développement
    apply_performance_profile "dev"
    [[ "$PERF_CACHE_MAX_SIZE_MB" -le 25 ]] || fail "Dev profile cache size not applied"
    [[ "$PERF_CLEANUP_INTERVAL_MINUTES" -le 10 ]] || fail "Dev profile cleanup interval not applied"
    [[ "$PERF_MONITORING_LEVEL" == "verbose" ]] || fail "Dev profile monitoring level not applied"
    
    # Test profil test
    apply_performance_profile "test"
    [[ "$PERF_CACHE_MAX_SIZE_MB" -le 50 ]] || fail "Test profile cache size not applied"
    [[ "$PERF_MONITORING_LEVEL" == "normal" ]] || fail "Test profile monitoring level not applied"
    
    # Test profil production
    apply_performance_profile "prod"
    [[ "$PERF_CACHE_MAX_SIZE_MB" -ge 100 ]] || fail "Prod profile cache size not applied"
    [[ "$PERF_CLEANUP_INTERVAL_MINUTES" -ge 30 ]] || fail "Prod profile cleanup interval not applied"
    [[ "$PERF_MONITORING_LEVEL" == "minimal" ]] || fail "Prod profile monitoring level not applied"
    
    echo "✓ Test 3 réussi"
}

# Test 4: Auto-tuning selon l'environnement
test_auto_tune_performance() {
    echo "Test 4: Auto-tuning selon l'environnement"
    
    # Simuler environnement local
    export AKLO_ENVIRONMENT=local
    auto_tune_performance
    
    # Vérifier que les paramètres ont été ajustés
    [[ -n "$PERF_CACHE_MAX_SIZE_MB" ]] || fail "Auto-tune did not set cache max size"
    [[ -n "$PERF_CLEANUP_INTERVAL_MINUTES" ]] || fail "Auto-tune did not set cleanup interval"
    
    # Simuler environnement CI
    export AKLO_ENVIRONMENT=ci
    auto_tune_performance
    
    # En CI, les paramètres doivent être optimisés pour la vitesse
    [[ "$PERF_CACHE_MAX_SIZE_MB" -ge 25 ]] || fail "CI auto-tune cache size too small"
    
    echo "✓ Test 4 réussi"
}

# Test 5: Validation de la configuration
test_config_validation() {
    echo "Test 5: Validation de la configuration"
    
    # Configuration valide
    PERF_CACHE_MAX_SIZE_MB=50
    PERF_MEMORY_LIMIT_MB=200
    PERF_CLEANUP_INTERVAL_MINUTES=15
    
    validate_performance_config
    assert_command_success "Valid configuration should pass validation"
    
    # Configuration invalide - cache plus grand que limite mémoire
    PERF_CACHE_MAX_SIZE_MB=300
    PERF_MEMORY_LIMIT_MB=200
    
    if validate_performance_config 2>/dev/null; then
        fail "Invalid configuration should fail validation"
    fi
    
    # Configuration invalide - intervalle de nettoyage négatif
    PERF_CACHE_MAX_SIZE_MB=50
    PERF_CLEANUP_INTERVAL_MINUTES=-5
    
    if validate_performance_config 2>/dev/null; then
        fail "Negative cleanup interval should fail validation"
    fi
    
    echo "✓ Test 5 réussi"
}

# Test 6: Nettoyage mémoire des caches
test_memory_cleanup() {
    echo "Test 6: Nettoyage mémoire des caches"
    
    # Créer des fichiers de cache simulés
    mkdir -p "$TEST_CACHE_DIR"/{regex,id,batch}
    
    # Créer des fichiers de différentes tailles
    dd if=/dev/zero of="$TEST_CACHE_DIR/regex/large_cache.tmp" bs=1024 count=100 2>/dev/null
    dd if=/dev/zero of="$TEST_CACHE_DIR/id/medium_cache.tmp" bs=1024 count=50 2>/dev/null
    dd if=/dev/zero of="$TEST_CACHE_DIR/batch/small_cache.tmp" bs=1024 count=10 2>/dev/null
    
    # Définir une limite de cache très petite pour forcer le nettoyage
    PERF_CACHE_MAX_SIZE_MB=1
    
    # Exécuter le nettoyage
    cleanup_memory_caches
    
    # Vérifier que le nettoyage a eu lieu
    local cache_size=$(du -s "$TEST_CACHE_DIR" 2>/dev/null | cut -f1)
    cache_size=$((cache_size / 1024)) # Convertir en MB
    
    [[ "$cache_size" -le 1 ]] || fail "Memory cleanup did not reduce cache size sufficiently"
    
    echo "✓ Test 6 réussi"
}

# Test 7: Diagnostic mémoire
test_memory_diagnostics() {
    echo "Test 7: Diagnostic mémoire"
    
    # Créer des caches de test
    mkdir -p "$TEST_CACHE_DIR"/{regex,id,batch}
    echo "test data" > "$TEST_CACHE_DIR/regex/test1.cache"
    echo "test data" > "$TEST_CACHE_DIR/id/test2.cache"
    echo "test data" > "$TEST_CACHE_DIR/batch/test3.cache"
    
    # Obtenir le diagnostic
    local diagnostic_output
    diagnostic_output=$(get_memory_diagnostics)
    
    # Vérifier que le diagnostic contient les informations attendues
    echo "$diagnostic_output" | grep -q "Cache Usage" || fail "Diagnostic missing cache usage info"
    echo "$diagnostic_output" | grep -q "Total Size" || fail "Diagnostic missing total size info"
    echo "$diagnostic_output" | grep -q "Regex Cache" || fail "Diagnostic missing regex cache info"
    echo "$diagnostic_output" | grep -q "ID Cache" || fail "Diagnostic missing ID cache info"
    echo "$diagnostic_output" | grep -q "Batch Cache" || fail "Diagnostic missing batch cache info"
    
    echo "✓ Test 7 réussi"
}

# Test 8: Limites de taille des caches
test_cache_size_limits() {
    echo "Test 8: Limites de taille des caches"
    
    # Définir une limite très petite
    PERF_CACHE_MAX_SIZE_MB=1
    
    # Simuler l'ajout d'une entrée de cache
    mkdir -p "$TEST_CACHE_DIR/regex"
    
    # Créer un fichier qui dépasse la limite
    dd if=/dev/zero of="$TEST_CACHE_DIR/regex/oversized.cache" bs=1024 count=2048 2>/dev/null
    
    # Vérifier la limite
    if check_cache_size_limit "regex"; then
        fail "Cache size limit check should fail for oversized cache"
    fi
    
    # Créer un fichier dans la limite
    rm -f "$TEST_CACHE_DIR/regex/oversized.cache"
    dd if=/dev/zero of="$TEST_CACHE_DIR/regex/normal.cache" bs=1024 count=512 2>/dev/null
    
    # Vérifier que la limite est respectée
    check_cache_size_limit "regex"
    assert_command_success "Cache size limit check should pass for normal cache"
    
    echo "✓ Test 8 réussi"
}

# Exécution des tests
main() {
    echo "🧪 Tests du système de tuning de performance - TASK-7-5"
    echo "======================================================="
    
    setup
    
    test_load_performance_config
    test_environment_detection
    test_performance_profiles
    test_auto_tune_performance
    test_config_validation
    test_memory_cleanup
    test_memory_diagnostics
    test_cache_size_limits
    
    teardown
    
    echo ""
    echo "✅ Tous les tests du tuning de performance sont réussis (8/8)"
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi