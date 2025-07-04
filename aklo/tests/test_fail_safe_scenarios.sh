#!/bin/bash

#==============================================================================
# Tests des scénarios d'échec - Architecture Fail-Safe TASK-13-8
#
# Auteur: AI_Agent
# Version: 1.0
# Tests spécifiques pour tous les scénarios d'échec possibles
#==============================================================================

# Configuration de base
set -e
script_dir="$(dirname "$0")"
modules_dir="${script_dir}/../modules"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Compteurs
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

# Chargement des modules
source "${modules_dir}/core/validation_engine.sh" 2>/dev/null || {
    echo "Erreur: Impossible de charger validation_engine.sh"
    exit 1
}
source "${modules_dir}/core/fail_safe_loader.sh" 2>/dev/null || {
    echo "Erreur: Impossible de charger fail_safe_loader.sh"
    exit 1
}
source "${modules_dir}/core/progressive_loading.sh" 2>/dev/null || {
    echo "Erreur: Impossible de charger progressive_loading.sh"
    exit 1
}

# Test 1: Scénario - Module complètement manquant
test_scenario_missing_module() {
    local missing_module="/nonexistent/path/module.sh"
    
    # Le chargement sécurisé ne doit jamais échouer
    safe_load_module "$missing_module"
    local result=$?
    
    # Vérification que le fallback a été déclenché
    is_fallback_triggered
    local fallback_result=$?
    
    [[ $result -eq 0 && $fallback_result -eq 0 ]]
}

# Test 2: Scénario - Module avec erreur de syntaxe
test_scenario_syntax_error() {
    local temp_module="/tmp/syntax_error_module.sh"
    
    # Création d'un module avec erreur de syntaxe
    cat > "$temp_module" << 'EOF'
#!/bin/bash
# Module avec erreur de syntaxe intentionnelle
function test_func() {
    echo "Test"
    if [ true  # Erreur: crochet manquant
    then
        echo "Never reached"
    fi
}
EOF
    
    # Le chargement sécurisé ne doit jamais échouer
    safe_load_module "$temp_module"
    local result=$?
    
    # Nettoyage
    rm -f "$temp_module"
    
    [[ $result -eq 0 ]]
}

# Test 3: Scénario - Module avec permissions insuffisantes
test_scenario_permission_denied() {
    local temp_module="/tmp/permission_denied_module.sh"
    
    # Création d'un module avec permissions restreintes
    cat > "$temp_module" << 'EOF'
#!/bin/bash
test_func() {
    echo "Test"
}
EOF
    
    # Suppression des permissions de lecture
    chmod 000 "$temp_module" 2>/dev/null || true
    
    # Le chargement sécurisé ne doit jamais échouer
    safe_load_module "$temp_module"
    local result=$?
    
    # Nettoyage
    chmod 644 "$temp_module" 2>/dev/null || true
    rm -f "$temp_module"
    
    [[ $result -eq 0 ]]
}

# Test 4: Scénario - Chargement de multiples modules défaillants
test_scenario_multiple_failures() {
    local temp_modules=(
        "/tmp/fail_module1.sh"
        "/tmp/fail_module2.sh"
        "/nonexistent/module3.sh"
    )
    
    # Création de modules défaillants
    cat > "${temp_modules[0]}" << 'EOF'
#!/bin/bash
# Erreur de syntaxe
function bad_func() {
    if [ missing_bracket
EOF
    
    cat > "${temp_modules[1]}" << 'EOF'
#!/bin/bash
# Module qui va générer une erreur à l'exécution
source /nonexistent/dependency.sh
EOF
    
    # Le chargement sécurisé ne doit jamais échouer
    safe_load_module_list "${temp_modules[@]}"
    local result=$?
    
    # Nettoyage
    rm -f "${temp_modules[0]}" "${temp_modules[1]}" 2>/dev/null || true
    
    [[ $result -eq 0 ]]
}

# Test 5: Scénario - Escalation forcée avec module manquant
test_scenario_escalation_with_missing() {
    # Tentative d'escalation vers un profil avec des modules manquants
    escalate_profile "FULL" "Test escalation with missing modules"
    local result=$?
    
    # L'escalation ne doit jamais échouer grâce au fallback
    [[ $result -eq 0 ]]
}

# Test 6: Scénario - Validation de chaîne avec dépendances circulaires
test_scenario_circular_dependencies() {
    local temp_module1="/tmp/circular1.sh"
    local temp_module2="/tmp/circular2.sh"
    
    # Création de modules avec références circulaires
    cat > "$temp_module1" << EOF
#!/bin/bash
source "$temp_module2"
test_func1() {
    echo "Test 1"
}
EOF
    
    cat > "$temp_module2" << EOF
#!/bin/bash
source "$temp_module1"
test_func2() {
    echo "Test 2"
}
EOF
    
    # La validation ne doit pas se bloquer
    check_dependencies_chain "$temp_module1" "$temp_module2"
    local result=$?
    
    # Nettoyage
    rm -f "$temp_module1" "$temp_module2"
    
    # Le test passe si la fonction retourne (pas de boucle infinie)
    return 0
}

# Test 7: Scénario - Chargement progressif avec échec d'escalation
test_scenario_progressive_with_escalation_failure() {
    # Simulation d'un environnement dégradé
    local original_modules_dir="$modules_dir"
    modules_dir="/nonexistent/modules"
    
    # Le chargement progressif ne doit jamais échouer
    progressive_load_with_escalation "FULL" "$modules_dir" "test_command"
    local result=$?
    
    # Restauration
    modules_dir="$original_modules_dir"
    
    [[ $result -eq 0 ]]
}

# Test 8: Scénario - Détection d'issues avec taux d'échec élevé
test_scenario_high_failure_rate() {
    # Simulation d'un taux d'échec élevé
    FAILED_MODULES=(
        "module1.sh" "module2.sh" "module3.sh" "module4.sh" "module5.sh"
    )
    LOADED_MODULES=("module6.sh")
    
    # La détection doit identifier le problème
    ! detect_loading_issues
    local detection_result=$?
    
    # Réinitialisation
    FAILED_MODULES=()
    LOADED_MODULES=()
    
    [[ $detection_result -eq 0 ]]
}

# Test 9: Scénario - Fallback d'urgence complet
test_scenario_emergency_fallback() {
    # Test du chargement d'urgence
    load_profile_emergency "$modules_dir"
    local result=$?
    
    # Le chargement d'urgence ne doit jamais échouer
    [[ $result -eq 0 ]]
}

# Test 10: Scénario - Validation avec module corrompu
test_scenario_corrupted_module() {
    local temp_module="/tmp/corrupted_module.sh"
    
    # Création d'un fichier corrompu (binaire)
    echo -e "\x00\x01\x02\x03\x04\x05" > "$temp_module"
    
    # La validation doit détecter le problème
    ! validate_module_integrity "$temp_module"
    local validation_result=$?
    
    # Mais le chargement sécurisé ne doit jamais échouer
    safe_load_module "$temp_module"
    local loading_result=$?
    
    # Nettoyage
    rm -f "$temp_module"
    
    [[ $validation_result -eq 0 && $loading_result -eq 0 ]]
}

# Exécution des tests
main() {
    echo "================================================="
    echo "Tests des Scénarios d'Échec - Architecture Fail-Safe"
    echo "================================================="
    echo
    
    run_test "Scénario - Module complètement manquant" test_scenario_missing_module
    run_test "Scénario - Module avec erreur de syntaxe" test_scenario_syntax_error
    run_test "Scénario - Module avec permissions insuffisantes" test_scenario_permission_denied
    run_test "Scénario - Chargement multiples modules défaillants" test_scenario_multiple_failures
    run_test "Scénario - Escalation forcée avec module manquant" test_scenario_escalation_with_missing
    run_test "Scénario - Validation avec dépendances circulaires" test_scenario_circular_dependencies
    run_test "Scénario - Chargement progressif avec échec escalation" test_scenario_progressive_with_escalation_failure
    run_test "Scénario - Détection issues avec taux échec élevé" test_scenario_high_failure_rate
    run_test "Scénario - Fallback d'urgence complet" test_scenario_emergency_fallback
    run_test "Scénario - Validation avec module corrompu" test_scenario_corrupted_module
    
    echo "================================================="
    echo "Résultats des tests de scénarios d'échec:"
    echo "Total: $TESTS_TOTAL"
    echo -e "Réussis: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Échoués: ${RED}$TESTS_FAILED${NC}"
    echo "================================================="
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les scénarios d'échec sont gérés !${NC}"
        echo -e "${GREEN}Architecture fail-safe validée pour tous les cas d'échec${NC}"
        exit 0
    else
        echo -e "${RED}❌ Certains scénarios d'échec ne sont pas gérés.${NC}"
        echo -e "${RED}Taux de réussite: $(( TESTS_PASSED * 100 / TESTS_TOTAL ))%${NC}"
        exit 1
    fi
}

# Exécution si le script est appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi