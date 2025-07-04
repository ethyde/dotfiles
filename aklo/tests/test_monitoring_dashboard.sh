#!/bin/bash

#==============================================================================
# Test Suite pour Monitoring Dashboard - TASK-13-7
#
# Auteur: AI_Agent
# Version: 1.0
# Tests unitaires pour le dashboard de monitoring
#==============================================================================

# Configuration des tests
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Chargement du framework de test
source "${SCRIPT_DIR}/test_framework.sh"

# Variables de test
TEST_CACHE_DIR="/tmp/aklo_test_cache"
TEST_METRICS_DB="/tmp/test_metrics_history.db"

# Nettoyage avant tests
setup_test_environment() {
    rm -rf "${TEST_CACHE_DIR}"
    mkdir -p "${TEST_CACHE_DIR}"
    export AKLO_CACHE_DIR="${TEST_CACHE_DIR}"
    export AKLO_METRICS_DB="${TEST_METRICS_DB}"
}

# Nettoyage après tests
cleanup_test_environment() {
    rm -rf "${TEST_CACHE_DIR}"
}

#==============================================================================
# Test 1: Chargement du module dashboard
#==============================================================================
test_dashboard_module_loading() {
    echo "=== Test: Chargement du module dashboard ==="
    
    # Chargement du module
    source "${PROJECT_ROOT}/modules/core/monitoring_dashboard.sh"
    
    # Vérifications
    assert_function_exists "display_dashboard_content" "Fonction display_dashboard_content doit exister"
    assert_function_exists "display_global_metrics" "Fonction display_global_metrics doit exister"
    assert_function_exists "export_dashboard_snapshot" "Fonction export_dashboard_snapshot doit exister"
    
    echo "✓ Chargement du module dashboard réussi"
}

#==============================================================================
# Test 2: Affichage des métriques globales
#==============================================================================
test_display_global_metrics() {
    echo "=== Test: Affichage des métriques globales ==="
    
    source "${PROJECT_ROOT}/modules/core/monitoring_dashboard.sh"
    
    # Ajout de données de test
    METRICS_OPERATIONS_COUNT=10
    PROFILE_USAGE_COUNT["MINIMAL"]=5
    LOADING_METRICS["test_MINIMAL"]="0.050"
    
    # Test d'affichage
    local output=$(display_global_metrics)
    
    # Vérifications
    echo "$output" | grep -q "MÉTRIQUES GLOBALES" || fail "Doit contenir le titre"
    echo "$output" | grep -q "Opérations totales: 10" || fail "Doit afficher le nombre d'opérations"
    
    echo "✓ Affichage des métriques globales réussi"
}

#==============================================================================
# Test 3: Export d'un snapshot du dashboard
#==============================================================================
test_export_dashboard_snapshot() {
    echo "=== Test: Export d'un snapshot du dashboard ==="
    
    source "${PROJECT_ROOT}/modules/core/monitoring_dashboard.sh"
    
    # Test d'export
    local snapshot_file="${TEST_CACHE_DIR}/test_snapshot.txt"
    export_dashboard_snapshot "$snapshot_file"
    
    # Vérifications
    assert_file_exists "$snapshot_file" "Fichier snapshot doit être créé"
    assert_file_contains "$snapshot_file" "AKLO DASHBOARD SNAPSHOT" "Snapshot doit contenir le titre"
    
    echo "✓ Export d'un snapshot du dashboard réussi"
}

#==============================================================================
# Test 4: Génération de rapport dashboard
#==============================================================================
test_generate_dashboard_report() {
    echo "=== Test: Génération de rapport dashboard ==="
    
    source "${PROJECT_ROOT}/modules/core/monitoring_dashboard.sh"
    
    # Test de génération de rapport
    local report=$(generate_dashboard_report "last_hour")
    
    # Vérifications
    assert_not_empty "$report" "Rapport dashboard généré"
    echo "$report" | grep -q "RAPPORT DASHBOARD" || fail "Rapport doit contenir le titre"
    
    echo "✓ Génération de rapport dashboard réussi"
}

#==============================================================================
# Test 5: Calcul du taux d'activité
#==============================================================================
test_calculate_activity_rate() {
    echo "=== Test: Calcul du taux d'activité ==="
    
    source "${PROJECT_ROOT}/modules/core/monitoring_dashboard.sh"
    
    # Test avec différentes valeurs
    METRICS_OPERATIONS_COUNT=100
    local rate=$(calculate_activity_rate)
    
    # Vérifications
    assert_not_empty "$rate" "Taux d'activité calculé"
    [[ $rate -ge 0 ]] || fail "Taux d'activité doit être positif"
    [[ $rate -le 100 ]] || fail "Taux d'activité doit être <= 100"
    
    echo "✓ Calcul du taux d'activité réussi"
}

#==============================================================================
# Exécution des tests
#==============================================================================
main() {
    echo "🚀 Démarrage des tests du Monitoring Dashboard - TASK-13-7"
    
    setup_test_environment
    
    # Exécution des tests
    test_dashboard_module_loading
    test_display_global_metrics
    test_export_dashboard_snapshot
    test_generate_dashboard_report
    test_calculate_activity_rate
    
    cleanup_test_environment
    
    echo "✅ Tous les tests du Monitoring Dashboard sont passés avec succès !"
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi