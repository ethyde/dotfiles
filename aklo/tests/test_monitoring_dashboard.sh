#!/bin/bash

#==============================================================================
# Test Suite pour Monitoring Dashboard - TASK-13-7
#
# Auteur: AI_Agent
# Version: 1.1
# Tests unitaires pour le dashboard de monitoring
#==============================================================================

# Utilisation de AKLO_PROJECT_ROOT exporté par run_tests.sh
source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"

# Configuration des tests
TEST_TEMP_DIR=$(mktemp -d)
export AKLO_CACHE_DIR="${TEST_TEMP_DIR}/cache"
export AKLO_LOG_DIR="${TEST_TEMP_DIR}/logs"
mkdir -p "${AKLO_CACHE_DIR}" "${AKLO_LOG_DIR}"

# Sourcing des modules APRÈS avoir configuré l'environnement
source "${AKLO_PROJECT_ROOT}/aklo/modules/core/metrics_engine.sh"
# Le fichier dashboard.sh est manquant, nous le créons vide pour les tests
touch "${AKLO_PROJECT_ROOT}/aklo/modules/core/monitoring_dashboard.sh"
source "${AKLO_PROJECT_ROOT}/aklo/modules/core/monitoring_dashboard.sh"


#==============================================================================
# Setup & Teardown
#==============================================================================
cleanup() {
    rm -rf "${TEST_TEMP_DIR}"
}
trap cleanup EXIT

#==============================================================================
# Test 1: Chargement du module dashboard
#==============================================================================
test_dashboard_module_loading() {
    test_suite "Monitoring Dashboard: Chargement du module"
    
    # Le module est déjà sourcé, on vérifie juste si les fonctions existent
    # Ces tests échoueront si le fichier est vide, ce qui est normal pour l'instant
    assert_function_exists "display_dashboard_content" "Fonction display_dashboard_content doit exister"
    assert_function_exists "display_global_metrics" "Fonction display_global_metrics doit exister"
    assert_function_exists "export_dashboard_snapshot" "Fonction export_dashboard_snapshot doit exister"
}

#==============================================================================
# Test 2: Affichage des métriques globales
#==============================================================================
test_display_global_metrics() {
    test_suite "Monitoring Dashboard: Affichage des métriques"
    
    # On vérifie si la fonction existe avant de l'appeler pour éviter un échec
    if ! command -v display_global_metrics >/dev/null 2>&1; then
        fail "Fonction display_global_metrics non implémentée, test sauté"
        return
    fi
    
    # Ajout de données de test
    METRICS_OPERATIONS_COUNT=10
    PROFILE_USAGE_COUNT["MINIMAL"]=5
    LOADING_METRICS["test_MINIMAL"]="0.050"
    
    # Test d'affichage
    local output
    output=$(display_global_metrics)
    
    # Vérifications
    assert_contains "$output" "MÉTRIQUES GLOBALES" "Doit contenir le titre"
    assert_contains "$output" "Opérations totales: 10" "Doit afficher le nombre d'opérations"
}

#==============================================================================
# Test 3: Export d'un snapshot du dashboard
#==============================================================================
test_export_dashboard_snapshot() {
    test_suite "Monitoring Dashboard: Export de snapshot"
    
    if ! command -v export_dashboard_snapshot >/dev/null 2>&1; then
        fail "Fonction export_dashboard_snapshot non implémentée, test sauté"
        return
    fi
    
    # Test d'export
    local snapshot_file="${AKLO_CACHE_DIR}/test_snapshot.txt"
    export_dashboard_snapshot "$snapshot_file"
    
    # Vérifications
    assert_file_exists "$snapshot_file" "Le fichier snapshot doit être créé"
    assert_file_contains "$snapshot_file" "AKLO DASHBOARD SNAPSHOT" "Le snapshot doit contenir le titre"
}

#==============================================================================
# Test 4: Génération de rapport dashboard
#==============================================================================
test_generate_dashboard_report() {
    test_suite "Monitoring Dashboard: Génération de rapport"
    
    if ! command -v generate_dashboard_report >/dev/null 2>&1; then
        fail "Fonction generate_dashboard_report non implémentée, test sauté"
        return
    fi
    
    # Test de génération de rapport
    local report
    report=$(generate_dashboard_report "last_hour")
    
    # Vérifications
    assert_not_empty "$report" "Le rapport du dashboard n'est pas vide"
    assert_contains "$report" "RAPPORT DASHBOARD" "Le rapport doit contenir le titre"
}

#==============================================================================
# Test 5: Calcul du taux d'activité
#==============================================================================
test_calculate_activity_rate() {
    test_suite "Monitoring Dashboard: Calcul du taux d'activité"
    
    if ! command -v calculate_activity_rate >/dev/null 2>&1; then
        fail "Fonction calculate_activity_rate non implémentée, test sauté"
        return
    fi
    
    # Test avec différentes valeurs
    METRICS_OPERATIONS_COUNT=100
    local rate
    rate=$(calculate_activity_rate)
    
    # Vérifications
    assert_not_empty "$rate" "Le taux d'activité doit être calculé"
}

#==============================================================================
# Exécution des tests
#==============================================================================
run_all_tests() {
    # Initialisation de l'environnement de métriques pour les tests
    initialize_metrics_engine
    
    test_dashboard_module_loading
    test_display_global_metrics
    test_export_dashboard_snapshot
    test_generate_dashboard_report
    test_calculate_activity_rate
    
    test_summary
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi