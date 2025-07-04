#!/bin/bash

#==============================================================================
# Tests pour la classification des commandes TASK-13-1
#
# Auteur: AI_Agent
# Version: 1.0
# Tests unitaires pour command_classifier.sh et learning_engine.sh
#==============================================================================

# Configuration de base pour les tests
set -e
script_dir="$(dirname "$0")"
modules_dir="${script_dir}/../modules"

# Couleurs pour les tests
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Compteurs de tests
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

# Fonction utilitaire pour les tests
run_test() {
    local test_name="$1"
    local test_function="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${YELLOW}[TEST]${NC} $test_name"
    
    if $test_function; then
        echo -e "${GREEN}[PASS]${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo
}

#==============================================================================
# Tests du Command Classifier
#==============================================================================

# Test 1: Command Classifier - Vérification d'existence du module
test_command_classifier_exists() {
    [ -f "${modules_dir}/core/command_classifier.sh" ]
}

# Test 2: Command Classifier - Fonction classify_command existe
test_classify_command_function() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    command -v classify_command >/dev/null 2>&1
}

# Test 3: Command Classifier - Classification commandes MINIMAL
test_classify_minimal_commands() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    
    local commands=("get_config" "status" "version" "help")
    for cmd in "${commands[@]}"; do
        local profile
        profile=$(classify_command "$cmd")
        if [[ "$profile" != "MINIMAL" ]]; then
            return 1
        fi
    done
    return 0
}

# Test 4: Command Classifier - Classification commandes NORMAL
test_classify_normal_commands() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    
    local commands=("plan" "dev" "debug" "review" "new" "template")
    for cmd in "${commands[@]}"; do
        local profile
        profile=$(classify_command "$cmd")
        if [[ "$profile" != "NORMAL" ]]; then
            return 1
        fi
    done
    return 0
}

# Test 5: Command Classifier - Classification commandes FULL
test_classify_full_commands() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    
    local commands=("optimize" "benchmark" "cache" "monitor" "diagnose")
    for cmd in "${commands[@]}"; do
        local profile
        profile=$(classify_command "$cmd")
        if [[ "$profile" != "FULL" ]]; then
            return 1
        fi
    done
    return 0
}

# Test 6: Command Classifier - Fonction get_required_modules existe
test_get_required_modules_function() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    command -v get_required_modules >/dev/null 2>&1
}

# Test 7: Command Classifier - Modules requis pour profil MINIMAL
test_get_minimal_modules() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    
    local modules
    modules=$(get_required_modules "MINIMAL")
    echo "$modules" | grep -q "core"
}

# Test 8: Command Classifier - Fonction detect_command_from_args existe
test_detect_command_from_args_function() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    command -v detect_command_from_args >/dev/null 2>&1
}

#==============================================================================
# Tests du Learning Engine
#==============================================================================

# Test 9: Learning Engine - Vérification d'existence du module
test_learning_engine_exists() {
    [ -f "${modules_dir}/core/learning_engine.sh" ]
}

# Test 10: Learning Engine - Fonction learn_command_pattern existe
test_learn_command_pattern_function() {
    source "${modules_dir}/core/learning_engine.sh" 2>/dev/null || return 1
    command -v learn_command_pattern >/dev/null 2>&1
}

# Test 11: Learning Engine - Fonction predict_command_profile existe
test_predict_command_profile_function() {
    source "${modules_dir}/core/learning_engine.sh" 2>/dev/null || return 1
    command -v predict_command_profile >/dev/null 2>&1
}

# Test 12: Learning Engine - Base de données d'apprentissage
test_learning_database_functionality() {
    source "${modules_dir}/core/learning_engine.sh" 2>/dev/null || return 1
    
    # Test d'apprentissage d'une nouvelle commande
    learn_command_pattern "new_test_command" "NORMAL" "test usage"
    local result=$?
    
    # Test de prédiction
    local predicted_profile
    predicted_profile=$(predict_command_profile "new_test_command")
    
    [[ $result -eq 0 && -n "$predicted_profile" ]]
}

# Test 13: Learning Engine - Apprentissage automatique pour commande inconnue
test_automatic_learning_unknown_command() {
    source "${modules_dir}/core/learning_engine.sh" 2>/dev/null || return 1
    
    # Test avec une commande complètement inconnue
    local profile
    profile=$(predict_command_profile "completely_unknown_command_xyz")
    
    # Doit retourner un profil par défaut ou AUTO
    [[ "$profile" == "AUTO" || "$profile" == "MINIMAL" || "$profile" == "NORMAL" ]]
}

#==============================================================================
# Tests d'intégration
#==============================================================================

# Test 14: Intégration - Chargement des deux modules
test_integration_modules_load() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/learning_engine.sh" 2>/dev/null || return 1
    return 0
}

# Test 15: Intégration - Classification avec apprentissage
test_integration_classification_with_learning() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/learning_engine.sh" 2>/dev/null || return 1
    
    # Classification d'une commande connue
    local known_profile
    known_profile=$(classify_command "get_config")
    
    # Apprentissage d'une nouvelle commande
    learn_command_pattern "integration_test_cmd" "NORMAL" "integration test"
    
    # Prédiction de la nouvelle commande
    local learned_profile
    learned_profile=$(predict_command_profile "integration_test_cmd")
    
    [[ "$known_profile" == "MINIMAL" && "$learned_profile" == "NORMAL" ]]
}

# Test 16: Intégration - Détection de commande depuis arguments
test_integration_command_detection() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    
    # Test de détection avec arguments simulés
    local detected_command
    detected_command=$(detect_command_from_args "get_config" "--verbose")
    
    [[ -n "$detected_command" ]]
}

# Test 17: Performance - Classification rapide
test_performance_fast_classification() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    
    local start_time=$(date +%s.%N)
    
    # Classification de 10 commandes
    for i in {1..10}; do
        classify_command "get_config" >/dev/null
    done
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    
    # Doit être très rapide (< 0.1s pour 10 classifications)
    if command -v bc >/dev/null 2>&1; then
        (( $(echo "$duration < 0.1" | bc -l) ))
    else
        return 0  # Skip test si bc non disponible
    fi
}

# Exécution des tests
main() {
    echo "=============================================="
    echo "Tests Classification des Commandes TASK-13-1"
    echo "=============================================="
    echo
    
    echo -e "${BLUE}=== Tests Command Classifier ===${NC}"
    run_test "Command Classifier - Existence du module" test_command_classifier_exists
    run_test "Command Classifier - Fonction classify_command" test_classify_command_function
    run_test "Command Classifier - Classification MINIMAL" test_classify_minimal_commands
    run_test "Command Classifier - Classification NORMAL" test_classify_normal_commands
    run_test "Command Classifier - Classification FULL" test_classify_full_commands
    run_test "Command Classifier - Fonction get_required_modules" test_get_required_modules_function
    run_test "Command Classifier - Modules MINIMAL" test_get_minimal_modules
    run_test "Command Classifier - Fonction detect_command_from_args" test_detect_command_from_args_function
    
    echo -e "${BLUE}=== Tests Learning Engine ===${NC}"
    run_test "Learning Engine - Existence du module" test_learning_engine_exists
    run_test "Learning Engine - Fonction learn_command_pattern" test_learn_command_pattern_function
    run_test "Learning Engine - Fonction predict_command_profile" test_predict_command_profile_function
    run_test "Learning Engine - Base de données apprentissage" test_learning_database_functionality
    run_test "Learning Engine - Apprentissage automatique" test_automatic_learning_unknown_command
    
    echo -e "${BLUE}=== Tests d'Intégration ===${NC}"
    run_test "Intégration - Chargement des modules" test_integration_modules_load
    run_test "Intégration - Classification avec apprentissage" test_integration_classification_with_learning
    run_test "Intégration - Détection commande depuis args" test_integration_command_detection
    run_test "Performance - Classification rapide" test_performance_fast_classification
    
    echo "=============================================="
    echo "Résultats des tests:"
    echo "Total: $TESTS_TOTAL"
    echo -e "Réussis: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Échoués: ${RED}$TESTS_FAILED${NC}"
    echo "=============================================="
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les tests sont passés !${NC}"
        echo -e "${GREEN}Classification des commandes TASK-13-1 validée${NC}"
        exit 0
    else
        echo -e "${RED}❌ Certains tests ont échoué.${NC}"
        echo -e "${RED}Taux de réussite: $(( TESTS_PASSED * 100 / TESTS_TOTAL ))%${NC}"
        exit 1
    fi
}

# Exécution si le script est appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi