#!/bin/bash

#==============================================================================
# Tests pour l'architecture fail-safe TASK-13-8
#
# Auteur: AI_Agent
# Version: 2.0
# Tests unitaires complets pour validation_engine.sh, fail_safe_loader.sh, progressive_loading.sh
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

# Fonction pour créer un module de test temporaire
create_test_module() {
    local module_name="$1"
    local module_content="$2"
    local temp_file="/tmp/test_module_${module_name}.sh"
    
    cat > "$temp_file" << EOF
#!/bin/bash
# Module de test temporaire
$module_content
EOF
    echo "$temp_file"
}

# Fonction pour nettoyer les modules de test
cleanup_test_modules() {
    rm -f /tmp/test_module_*.sh 2>/dev/null || true
}

#==============================================================================
# Tests du Validation Engine
#==============================================================================

# Test 1: Validation Engine - Vérification d'existence des modules
test_validation_engine_exists() {
    [ -f "${modules_dir}/core/validation_engine.sh" ]
}

# Test 2: Validation Engine - Fonction validate_module_integrity existe
test_validate_module_integrity_function() {
    source "${modules_dir}/core/validation_engine.sh" 2>/dev/null || return 1
    command -v validate_module_integrity >/dev/null 2>&1
}

# Test 3: Validation Engine - Fonction check_dependencies_chain existe
test_check_dependencies_chain_function() {
    source "${modules_dir}/core/validation_engine.sh" 2>/dev/null || return 1
    command -v check_dependencies_chain >/dev/null 2>&1
}

# Test 4: Validation Engine - Validation d'un module valide
test_validate_valid_module() {
    source "${modules_dir}/core/validation_engine.sh" 2>/dev/null || return 1
    
    local test_module
    test_module=$(create_test_module "valid" "
test_function() {
    echo 'Hello World'
}
")
    
    validate_module_integrity "$test_module"
    local result=$?
    cleanup_test_modules
    return $result
}

# Test 5: Validation Engine - Détection d'erreur de syntaxe
test_validate_syntax_error() {
    source "${modules_dir}/core/validation_engine.sh" 2>/dev/null || return 1
    
    local test_module
    test_module=$(create_test_module "invalid" "
test_function() {
    echo 'Hello World'
    # Erreur de syntaxe intentionnelle
    if [ missing_bracket
")
    
    ! validate_module_integrity "$test_module"
    local result=$?
    cleanup_test_modules
    return $result
}

# Test 6: Validation Engine - Gestion des erreurs et avertissements
test_validation_errors_handling() {
    source "${modules_dir}/core/validation_engine.sh" 2>/dev/null || return 1
    
    reset_validation_errors
    local errors_before
    errors_before=$(get_validation_errors | wc -l)
    
    # Test avec un module inexistant
    validate_module_integrity "/nonexistent/module.sh" 2>/dev/null || true
    
    local errors_after
    errors_after=$(get_validation_errors | wc -l)
    
    [[ $errors_after -gt $errors_before ]]
}

#==============================================================================
# Tests du Fail Safe Loader
#==============================================================================

# Test 7: Fail Safe Loader - Vérification d'existence
test_fail_safe_loader_exists() {
    [ -f "${modules_dir}/core/fail_safe_loader.sh" ]
}

# Test 8: Fail Safe Loader - Fonction transparent_fallback existe
test_transparent_fallback_function() {
    source "${modules_dir}/core/fail_safe_loader.sh" 2>/dev/null || return 1
    command -v transparent_fallback >/dev/null 2>&1
}

# Test 9: Fail Safe Loader - Fonction safe_load_module existe
test_safe_load_module_function() {
    source "${modules_dir}/core/fail_safe_loader.sh" 2>/dev/null || return 1
    command -v safe_load_module >/dev/null 2>&1
}

# Test 10: Fail Safe Loader - Chargement sécurisé d'un module valide
test_safe_load_valid_module() {
    source "${modules_dir}/core/fail_safe_loader.sh" 2>/dev/null || return 1
    
    local test_module
    test_module=$(create_test_module "safe_valid" "
safe_test_function() {
    echo 'Safe loading test'
}
")
    
    safe_load_module "$test_module"
    local result=$?
    
    # Vérification que la fonction a été chargée
    command -v safe_test_function >/dev/null 2>&1
    local function_loaded=$?
    
    cleanup_test_modules
    return $((result + function_loaded))
}

# Test 11: Fail Safe Loader - Fallback transparent sur module invalide
test_transparent_fallback_on_invalid() {
    source "${modules_dir}/core/fail_safe_loader.sh" 2>/dev/null || return 1
    
    local test_module
    test_module=$(create_test_module "fallback_invalid" "
# Module avec erreur de syntaxe
test_function() {
    echo 'Test'
    if [ missing_bracket
")
    
    # Le safe_load_module ne doit jamais échouer
    safe_load_module "$test_module"
    local result=$?
    
    # Vérification que le fallback a été déclenché
    is_fallback_triggered
    local fallback_triggered=$?
    
    cleanup_test_modules
    [[ $result -eq 0 && $fallback_triggered -eq 0 ]]
}

# Test 12: Fail Safe Loader - Détection des problèmes de chargement
test_detect_loading_issues() {
    source "${modules_dir}/core/fail_safe_loader.sh" 2>/dev/null || return 1
    
    # Simulation de plusieurs échecs
    FAILED_MODULES=("module1" "module2" "module3" "module4")
    
    ! detect_loading_issues
}

#==============================================================================
# Tests du Progressive Loading
#==============================================================================

# Test 13: Progressive Loading - Vérification d'existence
test_progressive_loading_exists() {
    [ -f "${modules_dir}/core/progressive_loading.sh" ]
}

# Test 14: Progressive Loading - Fonction progressive_load_with_escalation existe
test_progressive_load_with_escalation_function() {
    source "${modules_dir}/core/progressive_loading.sh" 2>/dev/null || return 1
    command -v progressive_load_with_escalation >/dev/null 2>&1
}

# Test 15: Progressive Loading - Chargement profil MINIMAL
test_progressive_load_minimal() {
    source "${modules_dir}/core/progressive_loading.sh" 2>/dev/null || return 1
    
    progressive_load_with_escalation "MINIMAL" "$modules_dir" "test_command"
    local result=$?
    
    # Vérification que le profil actuel est MINIMAL
    local current_profile
    current_profile=$(get_current_profile)
    
    [[ $result -eq 0 && "$current_profile" == "MINIMAL" ]]
}

# Test 16: Progressive Loading - Analyse des besoins de commande
test_analyze_command_requirements() {
    source "${modules_dir}/core/progressive_loading.sh" 2>/dev/null || return 1
    
    # Test avec commande simple
    local profile_simple
    profile_simple=$(analyze_command_requirements "get_config" "NORMAL")
    
    # Test avec commande complexe
    local profile_complex
    profile_complex=$(analyze_command_requirements "optimize" "MINIMAL")
    
    [[ "$profile_simple" == "MINIMAL" && "$profile_complex" == "FULL" ]]
}

# Test 17: Progressive Loading - Escalation automatique
test_escalation_functionality() {
    source "${modules_dir}/core/progressive_loading.sh" 2>/dev/null || return 1
    
    # Démarrage avec MINIMAL
    progressive_load_with_escalation "MINIMAL" "$modules_dir" "test"
    
    # Escalation vers NORMAL
    escalate_profile "NORMAL" "Test escalation"
    
    # Vérification de l'escalation
    local current_profile
    current_profile=$(get_current_profile)
    
    local escalation_history
    escalation_history=$(get_escalation_history | wc -l)
    
    [[ "$current_profile" == "NORMAL" && $escalation_history -gt 0 ]]
}

#==============================================================================
# Tests d'intégration
#==============================================================================

# Test 18: Intégration - Tous les modules se chargent sans erreur
test_integration_all_modules_load() {
    source "${modules_dir}/core/validation_engine.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/fail_safe_loader.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/progressive_loading.sh" 2>/dev/null || return 1
    return 0
}

# Test 19: Intégration - Architecture fail-safe complète
test_integration_fail_safe_architecture() {
    source "${modules_dir}/core/validation_engine.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/fail_safe_loader.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/progressive_loading.sh" 2>/dev/null || return 1
    
    # Test du workflow complet
    local test_modules=(
        "$(create_test_module "integration1" "test_func1() { echo 'test1'; }")"
        "$(create_test_module "integration2" "test_func2() { echo 'test2'; }")"
    )
    
    # Validation des modules
    check_dependencies_chain "${test_modules[@]}"
    local validation_result=$?
    
    # Chargement sécurisé
    safe_load_module_list "${test_modules[@]}"
    local loading_result=$?
    
    # Chargement progressif
    progressive_load_with_escalation "MINIMAL" "$modules_dir" "integration_test"
    local progressive_result=$?
    
    cleanup_test_modules
    
    [[ $validation_result -eq 0 && $loading_result -eq 0 && $progressive_result -eq 0 ]]
}

# Test 20: Intégration - Performance et métriques
test_integration_metrics_and_performance() {
    source "${modules_dir}/core/validation_engine.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/fail_safe_loader.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/progressive_loading.sh" 2>/dev/null || return 1
    
    # Test des fonctions de métriques
    get_validation_stats >/dev/null
    local validation_stats=$?
    
    get_loading_stats >/dev/null
    local loading_stats=$?
    
    get_progressive_stats >/dev/null
    local progressive_stats=$?
    
    [[ $validation_stats -eq 0 && $loading_stats -eq 0 && $progressive_stats -eq 0 ]]
}

# Exécution des tests
main() {
    echo "=============================================="
    echo "Tests Architecture Fail-Safe TASK-13-8 v2.0"
    echo "=============================================="
    echo
    
    echo -e "${BLUE}=== Tests Validation Engine ===${NC}"
    run_test "Validation Engine - Existence du module" test_validation_engine_exists
    run_test "Validation Engine - Fonction validate_module_integrity" test_validate_module_integrity_function
    run_test "Validation Engine - Fonction check_dependencies_chain" test_check_dependencies_chain_function
    run_test "Validation Engine - Validation module valide" test_validate_valid_module
    run_test "Validation Engine - Détection erreur syntaxe" test_validate_syntax_error
    run_test "Validation Engine - Gestion erreurs" test_validation_errors_handling
    
    echo -e "${BLUE}=== Tests Fail Safe Loader ===${NC}"
    run_test "Fail Safe Loader - Existence du module" test_fail_safe_loader_exists
    run_test "Fail Safe Loader - Fonction transparent_fallback" test_transparent_fallback_function
    run_test "Fail Safe Loader - Fonction safe_load_module" test_safe_load_module_function
    run_test "Fail Safe Loader - Chargement sécurisé valide" test_safe_load_valid_module
    run_test "Fail Safe Loader - Fallback transparent invalide" test_transparent_fallback_on_invalid
    run_test "Fail Safe Loader - Détection problèmes chargement" test_detect_loading_issues
    
    echo -e "${BLUE}=== Tests Progressive Loading ===${NC}"
    run_test "Progressive Loading - Existence du module" test_progressive_loading_exists
    run_test "Progressive Loading - Fonction progressive_load_with_escalation" test_progressive_load_with_escalation_function
    run_test "Progressive Loading - Chargement profil MINIMAL" test_progressive_load_minimal
    run_test "Progressive Loading - Analyse besoins commande" test_analyze_command_requirements
    run_test "Progressive Loading - Escalation automatique" test_escalation_functionality
    
    echo -e "${BLUE}=== Tests d'Intégration ===${NC}"
    run_test "Intégration - Tous les modules se chargent" test_integration_all_modules_load
    run_test "Intégration - Architecture fail-safe complète" test_integration_fail_safe_architecture
    run_test "Intégration - Performance et métriques" test_integration_metrics_and_performance
    
    echo "=============================================="
    echo "Résultats des tests:"
    echo "Total: $TESTS_TOTAL"
    echo -e "Réussis: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Échoués: ${RED}$TESTS_FAILED${NC}"
    echo "=============================================="
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les tests sont passés !${NC}"
        echo -e "${GREEN}Architecture fail-safe TASK-13-8 validée${NC}"
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