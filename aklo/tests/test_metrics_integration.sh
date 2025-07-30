#!/usr/bin/env bash

#==============================================================================
# Test d'Intégration - Metrics Engine + Monitoring Dashboard - TASK-13-7
#
# Auteur: AI_Agent
# Version: 1.1
# Tests d'intégration pour le système de métriques complet
#==============================================================================

# Utilisation du framework de test
source "$(dirname "$0")/framework/test_framework.sh"

# Configuration des tests
TEST_TEMP_DIR=$(mktemp -d)
export AKLO_CACHE_DIR="${TEST_TEMP_DIR}/cache"
export AKLO_LOG_DIR="${TEST_TEMP_DIR}/logs"
export METRICS_DB_FILE="${AKLO_CACHE_DIR}/metrics_history.db"
mkdir -p "${AKLO_CACHE_DIR}" "${AKLO_LOG_DIR}"

# Sourcing des modules APRÈS avoir configuré l'environnement
source "$(dirname "$0")/../modules/core/metrics_engine.sh"
source "$(dirname "$0")/../modules/core/monitoring_dashboard.sh"

#==============================================================================
# Setup & Teardown
#==============================================================================
setup_test() {
    TEST_TEMP_DIR=$(mktemp -d)
    export AKLO_CACHE_DIR="${TEST_TEMP_DIR}/cache"
    export AKLO_LOG_DIR="${TEST_TEMP_DIR}/logs"
    export METRICS_DB_FILE="${AKLO_CACHE_DIR}/metrics_history.db"
    mkdir -p "${AKLO_CACHE_DIR}" "${AKLO_LOG_DIR}"

    # Sourcing des modules APRÈS avoir configuré l'environnement
    source "$(dirname "$0")/../modules/core/metrics_engine.sh"
    source "$(dirname "$0")/../modules/core/monitoring_dashboard.sh"
}

cleanup() {
    rm -rf "$TEST_TEMP_DIR"
    unset AKLO_CACHE_DIR AKLO_LOG_DIR METRICS_DB_FILE
}
trap cleanup EXIT

#==============================================================================
# Test 1: Intégration complète du système de métriques
#==============================================================================
test_complete_metrics_integration() {
    test_suite "Metrics Integration: Session complète"
    setup_test

    # Simulation d'une session d'usage complète
    collect_loading_metrics "get_config" "MINIMAL" "cli" "0.05"
    collect_loading_metrics "plan" "NORMAL" "cli" "0.1"
    collect_loading_metrics "optimize" "FULL" "cli" "0.5"
    track_performance_metrics "get_config" "MINIMAL" "0.04" "success"
    track_performance_metrics "plan" "NORMAL" "0.08" "success"
    track_performance_metrics "optimize" "FULL" "0.45" "success"
    monitor_learning_efficiency "new_cmd" "NORMAL" "95" "prediction"
    monitor_learning_efficiency "another_cmd" "FULL" "80" "override"

    # Vérifications
    local db_file="${AKLO_CACHE_DIR}/metrics_history.db"
    assert_file_exists "$db_file" "La base de données des métriques est créée"
    
    # Vérification du contenu
    local metrics_count
    metrics_count=$(grep -c "^[0-9]" "$db_file" || echo "0")
    assert_equals "8" "$metrics_count" "Devrait avoir 8 métriques enregistrées"
    
    # Test de génération de rapport
    local report
    report=$(generate_usage_report "last_hour")
    assert_not_empty "$report" "Le rapport d'usage n'est pas vide"
    
    # Test d'export dashboard (si la fonction existe)
    if command -v export_dashboard_snapshot >/dev/null 2>&1; then
        local snapshot_file="${AKLO_CACHE_DIR}/integration_snapshot.txt"
        export_dashboard_snapshot "$snapshot_file"
        assert_file_exists "$snapshot_file" "Le snapshot du dashboard est créé"
    fi
    cleanup
}

#==============================================================================
# Test 2: Performance du système de métriques
#==============================================================================
test_metrics_performance() {
    test_suite "Metrics Integration: Performance"
    setup_test
    
    # Test de performance avec de multiples opérations
    local start_time
    start_time=$(date +%s.%N)
    
    # Simulation de 100 opérations
    for i in {1..100}; do
        collect_loading_metrics "test_cmd_$i" "MINIMAL" "cli" "$(date +%s.%N)"
    done
    
    local end_time
    end_time=$(date +%s.%N)
    local duration
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "1.0")
    
    # Vérification que le système reste performant
    local performance_ok
    performance_ok=$(echo "$duration < 2.0" | bc -l 2>/dev/null || echo "1")
    assert_equals "1" "$performance_ok" "Le système doit rester performant (a pris ${duration}s)"
    cleanup
}

#==============================================================================
# Test 3: Robustesse et gestion d'erreurs
#==============================================================================
test_metrics_robustness() {
    test_suite "Metrics Integration: Robustesse"
    setup_test
    
    # Test avec paramètres manquants (doit retourner un code d'erreur > 0)
    (collect_loading_metrics "" "MINIMAL" "cli" "$(date +%s.%N)")
    assert_exit_code "1" "collect_loading_metrics" "Doit échouer avec une commande vide"

    (track_performance_metrics "test" "" "0.1" "success")
    assert_exit_code "1" "track_performance_metrics" "Doit échouer avec un profil vide"
    
    (monitor_learning_efficiency "test" "NORMAL" "" "prediction")
    assert_exit_code "1" "monitor_learning_efficiency" "Doit échouer avec une confiance vide"
    
    # Test avec des valeurs valides après les erreurs
    collect_loading_metrics "test_after_error" "MINIMAL" "cli" "$(date +%s.%N)"
    assert_command_success "Le système fonctionne après des erreurs"
    cleanup
}

#==============================================================================
# Test 4: Persistance des données
#==============================================================================
test_data_persistence() {
    test_suite "Metrics Integration: Persistance"
    setup_test
    
    local db_file="${AKLO_CACHE_DIR}/metrics_history.db"

    # Ajout de données
    collect_loading_metrics "persistent_test" "MINIMAL" "cli" "$(date +%s.%N)"
    track_performance_metrics "persistent_test" "MINIMAL" "0.050" "success"
    
    # Vérification que les données sont écrites
    assert_file_contains "$db_file" "persistent_test" "Les données sont persistées"
    
    # Simulation d'un redémarrage (nouveau chargement des fonctions)
    unset -f collect_loading_metrics track_performance_metrics
    source "$(dirname "$0")/../modules/core/metrics_engine.sh"
    
    # Vérification que les données sont toujours là
    assert_file_contains "$db_file" "persistent_test" "Les données sont toujours présentes après redémarrage"
    cleanup
}

#==============================================================================
# Test 5: Compatibilité avec l'architecture existante
#==============================================================================
test_architecture_compatibility() {
    test_suite "Metrics Integration: Compatibilité"
    setup_test
    
    local db_file="${AKLO_CACHE_DIR}/metrics_history.db"

    # Test de compatibilité avec learning_engine
    if [[ -f "$(dirname "$0")/../modules/core/learning_engine.sh" ]]; then
        source "$(dirname "$0")/../modules/core/learning_engine.sh"
        
        # Test d'interaction
        monitor_learning_efficiency "compatibility_test" "NORMAL" "88" "integration"
        assert_file_contains "$db_file" "compatibility_test" "L'intégration avec learning_engine fonctionne"
    fi
    
    # Test de compatibilité avec les variables d'environnement
    local original_cache_dir="$AKLO_CACHE_DIR"
    local compat_test_dir
    compat_test_dir=$(mktemp -d)
    export AKLO_CACHE_DIR="${compat_test_dir}"
    mkdir -p "$AKLO_CACHE_DIR"
    
    # Nouveau chargement avec différent cache dir
    source "$(dirname "$0")/../modules/core/metrics_engine.sh"
    
    # Test que le nouveau répertoire est utilisé
    collect_loading_metrics "compat_test" "MINIMAL" "cli" "$(date +%s.%N)"
    assert_file_exists "${compat_test_dir}/metrics_history.db" "Le nouveau cache_dir est bien utilisé"
    
    # Nettoyage
    export AKLO_CACHE_DIR="$original_cache_dir"
    cleanup
}

#==============================================================================
# Exécution des tests
#==============================================================================
run_all_tests() {
    test_complete_metrics_integration
    test_metrics_performance
    test_metrics_robustness
    test_data_persistence
    test_architecture_compatibility
    test_summary
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi