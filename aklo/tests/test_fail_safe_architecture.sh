#!/bin/bash

#==============================================================================
# Test Suite pour l'Architecture Fail-Safe - TASK-13-8
#
# Auteur: AI_Agent
# Version: 3.0
# Tests unitaires pour validation_engine.sh, fail_safe_loader.sh, progressive_loading.sh
#==============================================================================

# Utilisation de AKLO_PROJECT_ROOT exporté par run_tests.sh
source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"

# Configuration de l'environnement de test
TEST_TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEST_TEMP_DIR}"' EXIT

export AKLO_CACHE_DIR="${TEST_TEMP_DIR}"

# Sourcing des modules à tester
source "${AKLO_PROJECT_ROOT}/aklo/modules/core/validation_engine.sh"
echo "DEBUG: Ligne après le source dans le test"
source "${AKLO_PROJECT_ROOT}/aklo/modules/core/fail_safe_loader.sh"
source "${AKLO_PROJECT_ROOT}/aklo/modules/core/progressive_loading.sh"

# Fonctions utilitaires pour créer des modules de test
create_test_module() {
    local module_name="$1"
    local module_content="$2"
    local module_path="${TEST_TEMP_DIR}/${module_name}.sh"
    echo "$module_content" > "$module_path"
    echo "$module_path"
}

#==============================================================================
# Définition des Tests
#==============================================================================

test_validation_engine() {
    test_suite "Validation Engine"

    local valid_module
    valid_module=$(create_test_module "valid_module" "echo 'hello'")
    local invalid_module
    invalid_module=$(create_test_module "invalid_module" "if [; then")

    assert_function_exists "validate_module_syntax"
    assert_function_exists "validate_module_dependencies"

    assert_true "validate_module_syntax '${valid_module}'" "Un module valide doit passer la validation de syntaxe"
    assert_false "validate_module_syntax '${invalid_module}'" "Un module invalide doit échouer la validation de syntaxe"
}

test_fail_safe_loader() {
    test_suite "Fail Safe Loader"
    
    local valid_module
    valid_module=$(create_test_module "safe_valid" "my_safe_func() { echo 'ok'; }")
    
    assert_function_exists "safe_load_module"
    
    assert_true "safe_load_module '${valid_module}' && command -v my_safe_func &>/dev/null" "Doit charger un module valide et ses fonctions"
}

test_progressive_loading() {
    test_suite "Progressive Loading"
    
    # Simuler le répertoire des modules
    local fake_modules_dir="${TEST_TEMP_DIR}/modules"
    mkdir -p "${fake_modules_dir}/core"
    create_test_module "modules/core/cache_functions" "# dummy"
    
    export AKLO_MODULES_PATH="$fake_modules_dir" # Override pour le test

    assert_function_exists "progressive_load_with_escalation"
    
    # Ce test est simplifié car la logique complète est complexe
    assert_true "progressive_load_with_escalation 'MINIMAL' '${fake_modules_dir}' 'test_cmd'" "Le chargement progressif MINIMAL doit réussir"

    unset AKLO_MODULES_PATH
}

#==============================================================================
# Exécution des tests
#==============================================================================

main() {
    test_suite "Architecture Fail-Safe TASK-13-8 v3.0"
    
    test_validation_engine
    test_fail_safe_loader
    test_progressive_loading

    test_summary
}

# Lancer l'exécution
main