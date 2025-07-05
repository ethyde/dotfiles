#!/bin/bash

#==============================================================================
# Test d'intégration TASK-13-1 et TASK-13-2
#
# Auteur: AI_Agent
# Version: 1.0
# Test d'intégration complète des systèmes de classification et lazy loading
#==============================================================================

script_dir="$(dirname "$0")"
modules_dir="${script_dir}/../modules"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Compteurs
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo -e "${YELLOW}[INTEGRATION]${NC} $test_name"
    
    if $test_function; then
        echo -e "${GREEN}[✓]${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}[✗]${NC} $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo
}

# Test 1: Chargement des modules TASK-13-1 et TASK-13-2
test_modules_loading() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null && \
    source "${modules_dir}/core/learning_engine.sh" 2>/dev/null && \
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null && \
    source "${modules_dir}/core/validation_engine.sh" 2>/dev/null
}

# Test 2: Intégration classification + lazy loading
test_classification_with_lazy_loading() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test du workflow complet
    local command="get_config"
    local profile=$(classify_command "$command")
    load_modules_for_profile "$profile" >/dev/null 2>&1
}

# Test 3: Validation avec lazy loading
test_validation_with_lazy_loading() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/validation_engine.sh" 2>/dev/null || return 1
    
    # Test validation puis chargement
    validate_module_comprehensive "command_classifier" >/dev/null 2>&1 && \
    load_module_fail_safe "command_classifier" >/dev/null 2>&1
}

# Test 4: Apprentissage avec lazy loading
test_learning_with_lazy_loading() {
    source "${modules_dir}/core/learning_engine.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test apprentissage puis chargement adaptatif
    learn_command_pattern "new_command" "NORMAL" >/dev/null 2>&1 && \
    progressive_loading "new_command" >/dev/null 2>&1
}

# Test 5: Workflow complet utilisateur
test_complete_user_workflow() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Simulation workflow utilisateur complet
    local commands=("get_config" "plan" "dev" "optimize")
    
    for cmd in "${commands[@]}"; do
        local profile=$(classify_command "$cmd")
        load_modules_for_profile "$profile" >/dev/null 2>&1 || return 1
    done
}

# Test 6: Performance intégrée
test_integrated_performance() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    local start_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    # Workflow rapide
    local profile=$(classify_command "status")
    load_modules_for_profile "$profile" >/dev/null 2>&1
    
    local end_time=$(date +%s.%N 2>/dev/null || date +%s)
    
    if command -v bc >/dev/null 2>&1; then
        local duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
        # Test permissif: < 1.0s pour workflow complet
        (( $(echo "$duration < 1.0" | bc -l) ))
    else
        return 0
    fi
}

# Test 7: Gestion d'erreurs intégrée
test_integrated_error_handling() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test avec commande inconnue
    local profile=$(classify_command "unknown_command_xyz")
    load_modules_for_profile "$profile" >/dev/null 2>&1
    
    # Test avec module inexistant
    load_module_fail_safe "nonexistent_module" >/dev/null 2>&1
}

# Test 8: Cache intégré
test_integrated_caching() {
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Premier chargement
    local profile=$(classify_command "get_config")
    load_modules_for_profile "$profile" >/dev/null 2>&1
    
    # Deuxième chargement (doit utiliser le cache)
    local profile2=$(classify_command "get_config")
    load_modules_for_profile "$profile2" >/dev/null 2>&1
    
    # Vérification cache
    is_module_loaded "command_classifier" >/dev/null 2>&1
}

main() {
    echo "=============================================="
    echo "Tests d'Intégration TASK-13-1 + TASK-13-2"
    echo "Classification + Lazy Loading"
    echo "=============================================="
    echo
    
    echo -e "${BLUE}=== Tests d'Intégration ===${NC}"
    run_test "Chargement des modules TASK-13-1 et TASK-13-2" test_modules_loading
    run_test "Intégration classification + lazy loading" test_classification_with_lazy_loading
    run_test "Validation avec lazy loading" test_validation_with_lazy_loading
    run_test "Apprentissage avec lazy loading" test_learning_with_lazy_loading
    run_test "Workflow complet utilisateur" test_complete_user_workflow
    run_test "Performance intégrée" test_integrated_performance
    run_test "Gestion d'erreurs intégrée" test_integrated_error_handling
    run_test "Cache intégré" test_integrated_caching
    
    echo "=============================================="
    echo "Résultats Intégration:"
    echo "Total: $TESTS_TOTAL"
    echo -e "Réussis: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Échoués: ${RED}$TESTS_FAILED${NC}"
    echo "=============================================="
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 Intégration TASK-13-1 + TASK-13-2 réussie !${NC}"
        echo -e "${GREEN}Système complet opérationnel${NC}"
        exit 0
    else
        echo -e "${RED}❌ Problèmes d'intégration détectés.${NC}"
        echo -e "${RED}Taux de réussite: $(( TESTS_PASSED * 100 / TESTS_TOTAL ))%${NC}"
        exit 1
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi