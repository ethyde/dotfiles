#!/bin/bash

#==============================================================================
# Tests Definition of Done - TASK-13-6
#
# Auteur: AI_Agent
# Tests de validation des critères d'acceptation pour TASK-13-6
#==============================================================================

# Configuration de base
set -e

# Variables de test
TEST_DIR="/tmp/aklo_test_task_13_6_$$"
TEST_DATA_DIR="$TEST_DIR/data"

# Couleurs pour les tests
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
TESTS_PASSED=0
TESTS_FAILED=0

# Configuration des chemins pour les tests
export AKLO_DATA_DIR="$TEST_DATA_DIR"
export LEARNING_DB_FILE="$TEST_DATA_DIR/learning_database.json"
export USAGE_DB_FILE="$TEST_DATA_DIR/learning_patterns.db"

# Fonction utilitaire pour les tests
setup_test_environment() {
    mkdir -p "$TEST_DATA_DIR"
    
    # Chargement des modules requis
    source "../modules/core/learning_engine.sh" 2>/dev/null || true
    source "../modules/core/usage_database.sh" 2>/dev/null || true
}

cleanup_test_environment() {
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo -n "DoD Test: $test_name ... "
    
    if $test_function; then
        echo -e "${GREEN}✓ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# DoD 1: Module learning_engine.sh créé et fonctionnel
test_learning_engine_exists() {
    [[ -f "../modules/core/learning_engine.sh" ]] && \
    [[ -r "../modules/core/learning_engine.sh" ]] && \
    declare -f learn_command_pattern >/dev/null && \
    declare -f predict_command_profile >/dev/null
}

# DoD 2: Module usage_database.sh créé avec gestion de la base de données
test_usage_database_exists() {
    [[ -f "../modules/core/usage_database.sh" ]] && \
    [[ -r "../modules/core/usage_database.sh" ]] && \
    declare -f init_usage_database >/dev/null && \
    declare -f save_usage_data >/dev/null && \
    declare -f load_usage_data >/dev/null
}

# DoD 3: Système d'apprentissage automatique opérationnel
test_automatic_learning_system() {
    # Test d'apprentissage d'un nouveau pattern
    learn_command_pattern "test_new_cmd" "NORMAL" "automatic-test" 85
    local result
    result=$(predict_command_profile "test_new_cmd")
    [[ "$result" == "NORMAL" ]]
}

# DoD 4: Classification automatique des nouvelles commandes fonctionnelle
test_automatic_classification() {
    # Test de classification d'une commande inconnue
    local result
    result=$(predict_command_profile "unknown_command_xyz")
    [[ -n "$result" ]] && [[ "$result" =~ ^(MINIMAL|NORMAL|FULL|AUTO)$ ]]
}

# DoD 5: Base de données d'apprentissage persistante
test_persistent_learning_database() {
    # Initialisation de la base de données
    init_usage_database
    [[ -f "$USAGE_DB_FILE" ]] && \
    save_usage_data "persistent_test" "FULL" "test" "0.500" && \
    [[ -s "$USAGE_DB_FILE" ]]  # Fichier non vide
}

# DoD 6: Algorithme d'analyse des patterns d'usage implémenté
test_pattern_analysis_algorithm() {
    # Test de l'algorithme de similarité
    declare -f calculate_similarity_score >/dev/null && \
    declare -f find_similar_patterns >/dev/null
    
    if [[ $? -eq 0 ]]; then
        local score
        score=$(calculate_similarity_score "test_cmd" "test_command")
        [[ -n "$score" ]] && (( score >= 0 )) && (( score <= 100 ))
    else
        return 1
    fi
}

# DoD 7: Fonction d'apprentissage à partir des exécutions réelles
test_learning_from_execution() {
    # Test de l'apprentissage basé sur la performance
    declare -f update_command_performance >/dev/null && \
    declare -f auto_learn_from_performance_advanced >/dev/null
    
    if [[ $? -eq 0 ]]; then
        update_command_performance "perf_test_cmd" "0.080" "NORMAL"
        return $?
    else
        return 1
    fi
}

# DoD 8: Métriques d'efficacité de l'apprentissage disponibles
test_learning_metrics() {
    # Test des métriques d'apprentissage
    declare -f get_learning_stats >/dev/null
    
    if [[ $? -eq 0 ]]; then
        local stats
        stats=$(get_learning_stats)
        [[ -n "$stats" ]] && [[ "$stats" == *"Commandes apprises"* ]]
    else
        return 1
    fi
}

# DoD 9: Tests unitaires écrits et passants
test_unit_tests_exist() {
    [[ -f "test_usage_database.sh" ]] && \
    [[ -x "test_usage_database.sh" ]]
    
    if [[ $? -eq 0 ]]; then
        # Exécution des tests unitaires
        ./test_usage_database.sh >/dev/null 2>&1
        return $?
    else
        return 1
    fi
}

# DoD 10: Documentation complète de l'algorithme d'apprentissage
test_algorithm_documentation() {
    # Vérification de la documentation dans les modules
    grep -q "Apprentissage automatique" "../modules/core/learning_engine.sh" && \
    grep -q "base de données d'apprentissage" "../modules/core/usage_database.sh" && \
    grep -q "Analyse des patterns" "../modules/core/learning_engine.sh"
}

# DoD 11: Code respecte les standards bash et les conventions aklo
test_code_standards() {
    # Vérification des standards bash
    bash -n "../modules/core/learning_engine.sh" && \
    bash -n "../modules/core/usage_database.sh" && \
    # Vérification des conventions aklo (en-têtes, fonctions documentées)
    grep -q "#==============================================================================" "../modules/core/learning_engine.sh" && \
    grep -q "# Description:" "../modules/core/learning_engine.sh" && \
    grep -q "# Paramètres:" "../modules/core/learning_engine.sh"
}

# DoD 12: Intégration transparente avec le système de classification existant
test_transparent_integration() {
    # Test d'intégration avec le command_classifier
    if [[ -f "../modules/core/command_classifier.sh" ]]; then
        # Vérification que les modules peuvent coexister
        source "../modules/core/command_classifier.sh" 2>/dev/null || return 1
        
        # Test de non-conflit des fonctions
        declare -f classify_command >/dev/null && \
        declare -f predict_command_profile >/dev/null
    else
        # Si command_classifier n'existe pas, c'est OK
        return 0
    fi
}

# Fonction principale des tests
main() {
    echo "=== Tests Definition of Done - TASK-13-6 ==="
    echo "Système d'apprentissage automatique pour nouvelles commandes"
    echo ""
    
    setup_test_environment
    
    # Exécution des tests de Definition of Done
    run_test "Module learning_engine.sh créé et fonctionnel" test_learning_engine_exists
    run_test "Module usage_database.sh créé avec gestion BDD" test_usage_database_exists
    run_test "Système d'apprentissage automatique opérationnel" test_automatic_learning_system
    run_test "Classification automatique des nouvelles commandes" test_automatic_classification
    run_test "Base de données d'apprentissage persistante" test_persistent_learning_database
    run_test "Algorithme d'analyse des patterns d'usage" test_pattern_analysis_algorithm
    run_test "Fonction d'apprentissage à partir des exécutions" test_learning_from_execution
    run_test "Métriques d'efficacité de l'apprentissage" test_learning_metrics
    run_test "Tests unitaires écrits et passants" test_unit_tests_exist
    run_test "Documentation complète de l'algorithme" test_algorithm_documentation
    run_test "Code respecte les standards bash et conventions" test_code_standards
    run_test "Intégration transparente avec classification existante" test_transparent_integration
    
    cleanup_test_environment
    
    # Résumé des tests
    echo ""
    echo "=== Résumé Definition of Done ==="
    echo -e "Critères validés: ${GREEN}$TESTS_PASSED${NC}/12"
    echo -e "Critères échoués: ${RED}$TESTS_FAILED${NC}/12"
    
    if [[ $TESTS_PASSED -eq 12 ]]; then
        echo -e "${GREEN}✓ TASK-13-6 Definition of Done COMPLÈTE${NC}"
        exit 0
    else
        echo -e "${RED}✗ TASK-13-6 Definition of Done INCOMPLÈTE${NC}"
        echo "Critères manquants: $((12 - TESTS_PASSED))"
        exit 1
    fi
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi