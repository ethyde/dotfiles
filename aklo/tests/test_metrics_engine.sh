#!/usr/bin/env bash

#==============================================================================
# Test Suite pour Metrics Engine - TASK-13-7
#
# Auteur: AI_Agent
# Version: 1.2
# Tests unitaires pour le système de métriques avancées
#==============================================================================

# Utilisation de AKLO_PROJECT_ROOT exporté par run_tests.sh
source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"

# Configuration des tests
# Créer un répertoire de test temporaire et unique pour cette exécution
TEST_TEMP_DIR=$(mktemp -d)
export AKLO_CACHE_DIR="${TEST_TEMP_DIR}/cache"
export AKLO_LOG_DIR="${TEST_TEMP_DIR}/logs"
mkdir -p "${AKLO_CACHE_DIR}" "${AKLO_LOG_DIR}"

# Sourcing du module à tester APRÈS avoir configuré l'environnement
source "${AKLO_PROJECT_ROOT}/aklo/modules/core/metrics_engine.sh"

#==============================================================================
# Setup & Teardown
#==============================================================================
setup() {
    # Le setup se fait maintenant avant le sourcing
    :
}

cleanup() {
    rm -rf "${TEST_TEMP_DIR}"
}

# Assurer le nettoyage à la fin du script
trap cleanup EXIT

#==============================================================================
# Test 1: Initialisation du système de métriques
#==============================================================================
test_metrics_engine_initialization() {
    test_suite "Metrics Engine: Initialisation"
    
    # Test d'initialisation
    initialize_metrics_engine
    
    # Vérifications
    assert_file_exists "${METRICS_DB_FILE}" "La base de données des métriques doit être créée"
    assert_function_exists "collect_loading_metrics" "Fonction collect_loading_metrics doit exister"
    assert_function_exists "track_performance_metrics" "Fonction track_performance_metrics doit exister"
    assert_function_exists "monitor_learning_efficiency" "Fonction monitor_learning_efficiency doit exister"
}

#==============================================================================
# Test 2: Collecte des métriques de chargement
#==============================================================================
test_collect_loading_metrics() {
    test_suite "Metrics Engine: Collecte des métriques de chargement"
    
    # Test de collecte de métriques
    local start_time
    start_time=$(date +%s.%N)
    collect_loading_metrics "get_config" "MINIMAL" "cli" "${start_time}"
    
    # Vérification que les métriques sont enregistrées
    assert_file_contains "${METRICS_DB_FILE}" "get_config" "Les métriques de get_config sont enregistrées"
    assert_file_contains "${METRICS_DB_FILE}" "MINIMAL" "Le profil MINIMAL est enregistré"
}

#==============================================================================
# Test 3: Suivi des performances par profil
#==============================================================================
test_track_performance_metrics() {
    test_suite "Metrics Engine: Suivi des performances"
    
    # Test de suivi des performances
    track_performance_metrics "plan" "NORMAL" "0.150" "success"
    track_performance_metrics "optimize" "FULL" "0.800" "success"
    
    # Vérification des métriques de performance
    assert_file_contains "${METRICS_DB_FILE}" "plan" "Les métriques de plan sont enregistrées"
    assert_file_contains "${METRICS_DB_FILE}" "optimize" "Les métriques d'optimize sont enregistrées"
}

#==============================================================================
# Test 4: Monitoring de l'efficacité d'apprentissage
#==============================================================================
test_monitor_learning_efficiency() {
    test_suite "Metrics Engine: Monitoring de l'apprentissage"
    
    # Test de monitoring d'apprentissage
    monitor_learning_efficiency "new_command" "NORMAL" "85" "prediction"
    
    # Vérification des métriques d'apprentissage
    assert_file_contains "${METRICS_DB_FILE}" "new_command" "Les métriques d'apprentissage sont enregistrées"
    assert_file_contains "${METRICS_DB_FILE}" "prediction" "Le type de décision est enregistré"
}

#==============================================================================
# Test 5: Génération de rapport d'usage
#==============================================================================
test_generate_usage_report() {
    test_suite "Metrics Engine: Génération de rapport"
    
    # Ajout de données de test
    collect_loading_metrics "get_config" "MINIMAL" "cli" "$(date +%s.%N)"
    track_performance_metrics "plan" "NORMAL" "0.150" "success"
    
    # Test de génération de rapport
    local report
    report=$(generate_usage_report "last_hour")
    
    # Vérifications
    assert_not_empty "$report" "Le rapport d'usage n'est pas vide"
    assert_contains "$report" "get_config" "Le rapport doit contenir get_config"
    assert_contains "$report" "plan" "Le rapport doit contenir plan"
}

#==============================================================================
# Exécution des tests
#==============================================================================
run_all_tests() {
    test_metrics_engine_initialization
    test_collect_loading_metrics
    test_track_performance_metrics
    test_monitor_learning_efficiency
    test_generate_usage_report
    test_summary
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi