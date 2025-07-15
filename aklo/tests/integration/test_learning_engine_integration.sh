#!/usr/bin/env bash

#==============================================================================
# Test d'Intégration Learning Engine + Usage Database - TASK-13-6
#
# Auteur: AI_Agent
# Version: 2.0
# Tests d'intégration entre les modules d'apprentissage automatique.
#==============================================================================

# Utilisation de AKLO_PROJECT_ROOT exporté par run_tests.sh
source "${AKLO_PROJECT_ROOT}/aklo/tests/framework/test_framework.sh"

# Configuration de l'environnement de test
TEST_TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEST_TEMP_DIR}"' EXIT

# Exporter les variables d'environnement pour les modules
export AKLO_DATA_DIR="${TEST_TEMP_DIR}"
export AKLO_CACHE_DIR="${TEST_TEMP_DIR}"

# Sourcing des modules à tester
source "${AKLO_PROJECT_ROOT}/aklo/modules/core/learning_engine.sh"
source "${AKLO_PROJECT_ROOT}/aklo/modules/core/usage_database.sh"

#==============================================================================
# Définition des Tests
#==============================================================================

test_module_loading_and_functions() {
    test_suite "Chargement des modules et fonctions"
    
    assert_function_exists "learn_command_pattern"
    assert_function_exists "predict_command_profile"
    assert_function_exists "init_usage_database"
    assert_function_exists "save_usage_data"
}

test_learning_and_prediction_logic() {
    test_suite "Logique d'apprentissage et de prédiction"

    assert_true "learn_command_pattern 'test_cmd' 'NORMAL' 'test' 90" "L'apprentissage d'un nouveau pattern doit réussir"
    
    local prediction
    prediction=$(predict_command_profile "test_cmd")
    assert_equals "$prediction" "NORMAL" "La prédiction doit retourner le profil appris"
}

test_database_usage() {
    test_suite "Utilisation de la base de données"

    assert_true "init_usage_database" "L'initialisation de la base de données doit réussir"
    assert_true "save_usage_data 'db_cmd' 'FULL' 'test' '0.1'" "La sauvegarde de données doit réussir"
    assert_file_exists "${AKLO_DATA_DIR}/learning_patterns.db" "Le fichier de base de données doit être créé"
}

test_full_workflow_integration() {
    test_suite "Intégration du workflow complet"

    assert_true "learn_command_pattern 'integ_cmd' 'MINIMAL' 'test' 99" "Apprentissage pour l'intégration"
    assert_true "save_usage_data 'integ_cmd' 'MINIMAL' 'test' '0.01'" "Sauvegarde pour l'intégration"

    local prediction
    prediction=$(predict_command_profile "integ_cmd")
    assert_equals "$prediction" "MINIMAL" "La prédiction doit fonctionner dans un workflow intégré"
}

#==============================================================================
# Exécution des tests
#==============================================================================

main() {
    test_suite "Intégration Learning Engine + Usage DB TASK-13-6 v2.0"

    test_module_loading_and_functions
    test_learning_and_prediction_logic
    test_database_usage
    test_full_workflow_integration

    test_summary
}

# Lancer l'exécution
main