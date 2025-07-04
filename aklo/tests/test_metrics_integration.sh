#!/bin/bash

#==============================================================================
# Test d'Intégration - Metrics Engine + Monitoring Dashboard - TASK-13-7
#
# Auteur: AI_Agent
# Version: 1.0
# Tests d'intégration pour le système de métriques complet
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
# Test 1: Intégration complète du système de métriques
#==============================================================================
test_complete_metrics_integration() {
    echo "=== Test: Intégration complète du système de métriques ==="
    
    # Chargement des modules
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    source "${PROJECT_ROOT}/modules/core/monitoring_dashboard.sh"
    
    # Simulation d'une session d'usage complète
    
    # 1. Collecte de métriques de chargement
    collect_loading_metrics "get_config" "MINIMAL" "cli" "$(date +%s.%N)"
    collect_loading_metrics "plan" "NORMAL" "cli" "$(date +%s.%N)"
    collect_loading_metrics "optimize" "FULL" "cli" "$(date +%s.%N)"
    
    # 2. Suivi des performances
    track_performance_metrics "get_config" "MINIMAL" "0.045" "success"
    track_performance_metrics "plan" "NORMAL" "0.180" "success"
    track_performance_metrics "optimize" "FULL" "0.750" "success"
    
    # 3. Monitoring de l'apprentissage
    monitor_learning_efficiency "new_command" "NORMAL" "85" "prediction"
    monitor_learning_efficiency "unknown_cmd" "AUTO" "92" "learning"
    
    # Vérifications
    assert_file_exists "${TEST_METRICS_DB}" "Base de données des métriques créée"
    
    # Vérification du contenu
    local metrics_count=$(grep -c "^[0-9]" "${TEST_METRICS_DB}" || echo "0")
    [[ $metrics_count -ge 8 ]] || fail "Devrait avoir au moins 8 métriques enregistrées"
    
    # Test de génération de rapport
    local report=$(generate_usage_report "last_hour")
    assert_not_empty "$report" "Rapport d'usage généré"
    
    # Test d'export dashboard
    local snapshot_file="${TEST_CACHE_DIR}/integration_snapshot.txt"
    export_dashboard_snapshot "$snapshot_file"
    assert_file_exists "$snapshot_file" "Snapshot dashboard créé"
    
    echo "✓ Intégration complète du système de métriques réussie"
}

#==============================================================================
# Test 2: Performance du système de métriques
#==============================================================================
test_metrics_performance() {
    echo "=== Test: Performance du système de métriques ==="
    
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    
    # Test de performance avec de multiples opérations
    local start_time=$(date +%s.%N)
    
    # Simulation de 100 opérations
    for i in {1..100}; do
        collect_loading_metrics "test_cmd_$i" "MINIMAL" "cli" "$(date +%s.%N)"
    done
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "1.0")
    
    # Vérification que le système reste performant
    local performance_ok=$(echo "$duration < 2.0" | bc -l 2>/dev/null || echo "1")
    [[ "$performance_ok" == "1" ]] || fail "Système trop lent: ${duration}s pour 100 opérations"
    
    echo "✓ Performance du système de métriques acceptable: ${duration}s"
}

#==============================================================================
# Test 3: Robustesse et gestion d'erreurs
#==============================================================================
test_metrics_robustness() {
    echo "=== Test: Robustesse et gestion d'erreurs ==="
    
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    
    # Test avec paramètres manquants
    if collect_loading_metrics "" "MINIMAL" "cli" "$(date +%s.%N)" 2>/dev/null; then
        fail "Devrait échouer avec une commande vide"
    fi
    
    if track_performance_metrics "test" "" "0.1" "success" 2>/dev/null; then
        fail "Devrait échouer avec un profil vide"
    fi
    
    if monitor_learning_efficiency "test" "NORMAL" "" "prediction" 2>/dev/null; then
        fail "Devrait échouer avec une confiance vide"
    fi
    
    # Test avec des valeurs valides après les erreurs
    collect_loading_metrics "test_after_error" "MINIMAL" "cli" "$(date +%s.%N)"
    
    echo "✓ Gestion d'erreurs robuste"
}

#==============================================================================
# Test 4: Persistance des données
#==============================================================================
test_data_persistence() {
    echo "=== Test: Persistance des données ==="
    
    # Premier chargement
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    
    # Ajout de données
    collect_loading_metrics "persistent_test" "MINIMAL" "cli" "$(date +%s.%N)"
    track_performance_metrics "persistent_test" "MINIMAL" "0.050" "success"
    
    # Vérification que les données sont écrites
    assert_file_contains "${TEST_METRICS_DB}" "persistent_test" "Données persistées"
    
    # Simulation d'un redémarrage (nouveau chargement)
    unset LOADING_METRICS PERFORMANCE_METRICS LEARNING_METRICS
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    
    # Vérification que les données sont toujours là
    assert_file_contains "${TEST_METRICS_DB}" "persistent_test" "Données toujours présentes après redémarrage"
    
    echo "✓ Persistance des données validée"
}

#==============================================================================
# Test 5: Compatibilité avec l'architecture existante
#==============================================================================
test_architecture_compatibility() {
    echo "=== Test: Compatibilité avec l'architecture existante ==="
    
    # Vérification de la compatibilité avec les modules existants
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    
    # Test de compatibilité avec learning_engine
    if [[ -f "${PROJECT_ROOT}/modules/core/learning_engine.sh" ]]; then
        source "${PROJECT_ROOT}/modules/core/learning_engine.sh"
        
        # Test d'interaction
        monitor_learning_efficiency "compatibility_test" "NORMAL" "88" "integration"
        
        echo "✓ Compatibilité avec learning_engine validée"
    fi
    
    # Test de compatibilité avec les variables d'environnement
    local original_cache_dir="$AKLO_CACHE_DIR"
    export AKLO_CACHE_DIR="/tmp/test_compat"
    mkdir -p "$AKLO_CACHE_DIR"
    
    # Nouveau chargement avec différent cache dir
    source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
    
    # Test que le nouveau répertoire est utilisé
    collect_loading_metrics "compat_test" "MINIMAL" "cli" "$(date +%s.%N)"
    assert_file_exists "/tmp/test_compat/metrics_history.db" "Nouveau cache dir utilisé"
    
    # Nettoyage
    rm -rf "/tmp/test_compat"
    export AKLO_CACHE_DIR="$original_cache_dir"
    
    echo "✓ Compatibilité avec l'architecture existante validée"
}

#==============================================================================
# Exécution des tests
#==============================================================================
main() {
    echo "🚀 Démarrage des tests d'intégration - TASK-13-7"
    
    setup_test_environment
    
    # Exécution des tests
    test_complete_metrics_integration
    test_metrics_performance
    test_metrics_robustness
    test_data_persistence
    test_architecture_compatibility
    
    cleanup_test_environment
    
    echo "✅ Tous les tests d'intégration sont passés avec succès !"
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi