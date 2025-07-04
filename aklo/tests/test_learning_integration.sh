#!/bin/bash

#==============================================================================
# Tests d'intégration Learning Engine + Usage Database - TASK-13-6
#
# Auteur: AI_Agent
# Tests d'intégration entre les modules d'apprentissage automatique
#==============================================================================

# Configuration de base
set -e

# Variables de test
TEST_DIR="/tmp/aklo_test_learning_integration_$$"

# Couleurs pour les tests
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
TESTS_PASSED=0
TESTS_FAILED=0

# Configuration des chemins pour les tests
export AKLO_DATA_DIR="$TEST_DIR"
export AKLO_CACHE_DIR="$TEST_DIR"

# Fonction utilitaire pour les tests
setup_test_environment() {
    mkdir -p "$TEST_DIR"
    echo "Test environment: $TEST_DIR"
}

cleanup_test_environment() {
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo -n "Test: $test_name ... "
    
    if $test_function; then
        echo -e "${GREEN}PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: Chargement des modules
test_modules_loading() {
    # Test de chargement du learning_engine
    if [[ -f "../modules/core/learning_engine.sh" ]]; then
        source "../modules/core/learning_engine.sh" 2>/dev/null || return 1
    else
        return 1
    fi
    
    # Test de chargement du usage_database
    if [[ -f "../modules/core/usage_database.sh" ]]; then
        source "../modules/core/usage_database.sh" 2>/dev/null || return 1
    else
        return 1
    fi
    
    return 0
}

# Test 2: Fonctions principales disponibles
test_core_functions() {
    # Vérification des fonctions du learning_engine
    declare -f learn_command_pattern >/dev/null || return 1
    declare -f predict_command_profile >/dev/null || return 1
    
    # Vérification des fonctions du usage_database
    declare -f init_usage_database >/dev/null || return 1
    declare -f save_usage_data >/dev/null || return 1
    
    return 0
}

# Test 3: Apprentissage et prédiction
test_learning_and_prediction() {
    # Apprentissage d'un pattern
    learn_command_pattern "test_cmd" "NORMAL" "integration-test" 90 || return 1
    
    # Prédiction du même pattern
    local result
    result=$(predict_command_profile "test_cmd")
    [[ "$result" == "NORMAL" ]] || return 1
    
    return 0
}

# Test 4: Base de données d'usage
test_usage_database() {
    # Initialisation de la base de données
    init_usage_database || return 1
    
    # Sauvegarde de données
    save_usage_data "db_test_cmd" "FULL" "test" "0.250" || return 1
    
    # Vérification que le fichier existe
    [[ -f "$TEST_DIR/learning_patterns.db" ]] || return 1
    
    return 0
}

# Test 5: Intégration complète
test_complete_integration() {
    # Cycle complet : apprentissage -> sauvegarde -> prédiction
    
    # 1. Apprentissage via learning_engine
    learn_command_pattern "integration_cmd" "MINIMAL" "complete-test" 95 || return 1
    
    # 2. Sauvegarde via usage_database
    save_usage_data "integration_cmd" "MINIMAL" "test" "0.030" || return 1
    
    # 3. Prédiction
    local result
    result=$(predict_command_profile "integration_cmd")
    [[ "$result" == "MINIMAL" ]] || return 1
    
    # 4. Recherche de patterns similaires
    result=$(find_similar_patterns "integration_cmd")
    [[ "$result" == "MINIMAL" ]] || return 1
    
    return 0
}

# Fonction principale des tests
main() {
    echo "=== Tests d'Intégration Learning Engine + Usage Database ==="
    echo "TASK-13-6: Système d'apprentissage automatique"
    echo ""
    
    setup_test_environment
    
    # Exécution des tests d'intégration
    run_test "Chargement des modules" test_modules_loading
    run_test "Fonctions principales disponibles" test_core_functions
    run_test "Apprentissage et prédiction" test_learning_and_prediction
    run_test "Base de données d'usage" test_usage_database
    run_test "Intégration complète" test_complete_integration
    
    cleanup_test_environment
    
    # Résumé des tests
    echo ""
    echo "=== Résumé des Tests d'Intégration ==="
    echo -e "Tests passés: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests échoués: ${RED}$TESTS_FAILED${NC}"
    echo -e "Total: $((TESTS_PASSED + TESTS_FAILED))"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✓ Intégration TASK-13-6 RÉUSSIE${NC}"
        exit 0
    else
        echo -e "${RED}✗ Intégration TASK-13-6 ÉCHOUÉE${NC}"
        exit 1
    fi
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi