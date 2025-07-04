#!/bin/bash

#==============================================================================
# Test Suite pour Metrics Engine - TASK-13-7
#
# Auteur: AI_Agent
# Version: 1.0
# Tests unitaires pour le système de métriques avancées
#==============================================================================

# Configuration des tests
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Chargement du framework de test
source "${SCRIPT_DIR}/test_framework.sh"

# Variables de test
TEST_METRICS_DB="/tmp/test_metrics_history.db"
TEST_CACHE_DIR="/tmp/aklo_test_cache"

# Nettoyage avant tests
setup_test_environment() {
    rm -f "${TEST_METRICS_DB}"
    rm -rf "${TEST_CACHE_DIR}"
    mkdir -p "${TEST_CACHE_DIR}"
    export AKLO_CACHE_DIR="${TEST_CACHE_DIR}"
    export AKLO_METRICS_DB="${TEST_METRICS_DB}"
}

# Nettoyage après tests
cleanup_test_environment() {
    rm -f "${TEST_METRICS_DB}"
    rm -rf "${TEST_CACHE_DIR}"
}

#==============================================================================
# Test 1: Initialisation du système de métriques
#==============================================================================
test_metrics_engine_initialization() {
    echo "=== Test: Initialisation du système de métriques ==="
    
    # Chargement du module
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    
    # Test d'initialisation
    initialize_metrics_engine
    
    # Vérifications
    assert_file_exists "${TEST_METRICS_DB}" "Base de données des métriques doit être créée"
    assert_function_exists "collect_loading_metrics" "Fonction collect_loading_metrics doit exister"
    assert_function_exists "track_performance_metrics" "Fonction track_performance_metrics doit exister"
    assert_function_exists "monitor_learning_efficiency" "Fonction monitor_learning_efficiency doit exister"
    
    echo "✓ Initialisation du système de métriques réussie"
}

#==============================================================================
# Test 2: Collecte des métriques de chargement
#==============================================================================
test_collect_loading_metrics() {
    echo "=== Test: Collecte des métriques de chargement ==="
    
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    initialize_metrics_engine
    
    # Test de collecte de métriques
    local start_time=$(date +%s.%N)
    collect_loading_metrics "get_config" "MINIMAL" "cli" "${start_time}"
    
    # Vérification que les métriques sont enregistrées
    assert_file_contains "${TEST_METRICS_DB}" "get_config" "Métriques de get_config enregistrées"
    assert_file_contains "${TEST_METRICS_DB}" "MINIMAL" "Profil MINIMAL enregistré"
    
    echo "✓ Collecte des métriques de chargement réussie"
}

#==============================================================================
# Test 3: Suivi des performances par profil
#==============================================================================
test_track_performance_metrics() {
    echo "=== Test: Suivi des performances par profil ==="
    
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    initialize_metrics_engine
    
    # Test de suivi des performances
    track_performance_metrics "plan" "NORMAL" "0.150" "success"
    track_performance_metrics "optimize" "FULL" "0.800" "success"
    
    # Vérification des métriques de performance
    assert_file_contains "${TEST_METRICS_DB}" "plan" "Métriques de plan enregistrées"
    assert_file_contains "${TEST_METRICS_DB}" "optimize" "Métriques d'optimize enregistrées"
    
    echo "✓ Suivi des performances par profil réussi"
}

#==============================================================================
# Test 4: Monitoring de l'efficacité d'apprentissage
#==============================================================================
test_monitor_learning_efficiency() {
    echo "=== Test: Monitoring de l'efficacité d'apprentissage ==="
    
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    initialize_metrics_engine
    
    # Test de monitoring d'apprentissage
    monitor_learning_efficiency "new_command" "NORMAL" "85" "prediction"
    
    # Vérification des métriques d'apprentissage
    assert_file_contains "${TEST_METRICS_DB}" "new_command" "Métriques d'apprentissage enregistrées"
    assert_file_contains "${TEST_METRICS_DB}" "prediction" "Type de décision enregistré"
    
    echo "✓ Monitoring de l'efficacité d'apprentissage réussi"
}

#==============================================================================
# Test 5: Génération de rapport d'usage
#==============================================================================
test_generate_usage_report() {
    echo "=== Test: Génération de rapport d'usage ==="
    
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    initialize_metrics_engine
    
    # Ajout de données de test
    collect_loading_metrics "get_config" "MINIMAL" "cli" "$(date +%s.%N)"
    track_performance_metrics "plan" "NORMAL" "0.150" "success"
    
    # Test de génération de rapport
    local report=$(generate_usage_report "last_hour")
    
    # Vérifications
    assert_not_empty "$report" "Rapport d'usage généré"
    echo "$report" | grep -q "get_config" || fail "Rapport doit contenir get_config"
    echo "$report" | grep -q "plan" || fail "Rapport doit contenir plan"
    
    echo "✓ Génération de rapport d'usage réussie"
}

#==============================================================================
# Exécution des tests
#==============================================================================
main() {
    echo "🚀 Démarrage des tests du Metrics Engine - TASK-13-7"
    
    setup_test_environment
    
    # Exécution des tests
    test_metrics_engine_initialization
    test_collect_loading_metrics
    test_track_performance_metrics
    test_monitor_learning_efficiency
    test_generate_usage_report
    
    cleanup_test_environment
    
    echo "✅ Tous les tests du Metrics Engine sont passés avec succès !"
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi