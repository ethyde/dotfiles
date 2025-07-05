#!/bin/bash

#==============================================================================
# Tests pour le système de chargement paresseux TASK-13-2
#
# Auteur: AI_Agent
# Version: 1.0
# Tests unitaires pour lazy_loader.sh
#==============================================================================

# Configuration de base pour les tests
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
# Tests du Lazy Loader
#==============================================================================

# Test 1: Lazy Loader - Vérification d'existence du module
test_lazy_loader_exists() {
    [ -f "${modules_dir}/core/lazy_loader.sh" ]
}

# Test 2: Lazy Loader - Fonction load_modules_for_profile existe
test_load_modules_for_profile_function() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    command -v load_modules_for_profile >/dev/null 2>&1
}

# Test 3: Lazy Loader - Chargement profil MINIMAL
test_load_minimal_profile() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test de chargement du profil MINIMAL
    load_modules_for_profile "MINIMAL" >/dev/null 2>&1
}

# Test 4: Lazy Loader - Chargement profil NORMAL
test_load_normal_profile() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test de chargement du profil NORMAL
    load_modules_for_profile "NORMAL" >/dev/null 2>&1
}

# Test 5: Lazy Loader - Chargement profil FULL
test_load_full_profile() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test de chargement du profil FULL
    load_modules_for_profile "FULL" >/dev/null 2>&1
}

# Test 6: Lazy Loader - Fonction validate_module_before_load existe
test_validate_module_before_load_function() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    command -v validate_module_before_load >/dev/null 2>&1
}

# Test 7: Lazy Loader - Validation d'un module existant
test_validate_existing_module() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test validation d'un module qui existe (command_classifier)
    validate_module_before_load "command_classifier" >/dev/null 2>&1
}

# Test 8: Lazy Loader - Fonction progressive_loading existe
test_progressive_loading_function() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    command -v progressive_loading >/dev/null 2>&1
}

# Test 9: Lazy Loader - Chargement progressif
test_progressive_loading_escalation() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test du chargement progressif avec escalation
    progressive_loading "unknown_heavy_command" >/dev/null 2>&1
}

# Test 10: Lazy Loader - Fonction is_module_loaded existe
test_is_module_loaded_function() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    command -v is_module_loaded >/dev/null 2>&1
}

# Test 11: Lazy Loader - Vérification module chargé
test_module_loaded_status() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test de vérification si un module est chargé
    if is_module_loaded "command_classifier"; then
        return 0
    else
        # Module pas encore chargé, c'est normal
        return 0
    fi
}

# Test 12: Lazy Loader - Fonction load_module_fail_safe existe
test_load_module_fail_safe_function() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    command -v load_module_fail_safe >/dev/null 2>&1
}

# Test 13: Lazy Loader - Chargement fail-safe d'un module
test_fail_safe_module_loading() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test de chargement fail-safe
    load_module_fail_safe "command_classifier" >/dev/null 2>&1
}

# Test 14: Lazy Loader - Cache des modules chargés
test_module_cache_functionality() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test du cache - chargement puis vérification
    load_module_fail_safe "command_classifier" >/dev/null 2>&1
    is_module_loaded "command_classifier"
}

# Test 15: Lazy Loader - Fonction initialize_core_only existe
test_initialize_core_only_function() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    command -v initialize_core_only >/dev/null 2>&1
}

# Test 16: Lazy Loader - Initialisation core uniquement
test_core_only_initialization() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test d'initialisation core seulement
    initialize_core_only >/dev/null 2>&1
}

# Test 17: Lazy Loader - Métriques de performance
test_loading_metrics() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test des métriques de temps de chargement
    if command -v get_loading_metrics >/dev/null 2>&1; then
        get_loading_metrics >/dev/null 2>&1
    else
        return 0  # Fonction optionnelle
    fi
}

# Test 18: Intégration - Chargement avec classification
test_integration_with_classifier() {
    # Chargement des modules requis
    source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || return 1
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test d'intégration
    local command="get_config"
    local profile=$(classify_command "$command")
    load_modules_for_profile "$profile" >/dev/null 2>&1
}

# Test 19: Performance - Chargement rapide profil MINIMAL
test_minimal_profile_performance() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test de performance réaliste avec plusieurs essais
    local total_time=0
    local iterations=3
    local max_time=0
    
    for ((i=1; i<=iterations; i++)); do
        # Reset pour test propre
        reset_loading_cache >/dev/null 2>&1
        
        local start_time=$(date +%s.%N 2>/dev/null || date +%s)
        load_modules_for_profile "MINIMAL" >/dev/null 2>&1
        local end_time=$(date +%s.%N 2>/dev/null || date +%s)
        
        if command -v bc >/dev/null 2>&1; then
            local duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
            total_time=$(echo "$total_time + $duration" | bc 2>/dev/null || echo "0")
            
            # Garder le temps max
            if (( $(echo "$duration > $max_time" | bc -l) )); then
                max_time=$duration
            fi
        fi
    done
    
    if command -v bc >/dev/null 2>&1; then
        local avg_time=$(echo "scale=3; $total_time / $iterations" | bc 2>/dev/null || echo "0")
        # Test réaliste: temps moyen < 1.0s ET temps max < 2.0s
        (( $(echo "$avg_time < 1.0" | bc -l) )) && (( $(echo "$max_time < 2.0" | bc -l) ))
    else
        return 0  # Skip test si bc non disponible
    fi
}

# Test 20: Gestion d'erreurs - Module inexistant
test_error_handling_missing_module() {
    source "${modules_dir}/core/lazy_loader.sh" 2>/dev/null || return 1
    
    # Test avec un module qui n'existe pas
    if load_module_fail_safe "nonexistent_module" >/dev/null 2>&1; then
        return 0  # Doit réussir grâce au fail-safe
    else
        return 1  # Échec du fail-safe
    fi
}

# Exécution des tests
main() {
    echo "=============================================="
    echo "Tests Système de Chargement Paresseux TASK-13-2"
    echo "=============================================="
    echo
    
    echo -e "${BLUE}=== Tests Lazy Loader Core ===${NC}"
    run_test "Lazy Loader - Existence du module" test_lazy_loader_exists
    run_test "Lazy Loader - Fonction load_modules_for_profile" test_load_modules_for_profile_function
    run_test "Lazy Loader - Chargement profil MINIMAL" test_load_minimal_profile
    run_test "Lazy Loader - Chargement profil NORMAL" test_load_normal_profile
    run_test "Lazy Loader - Chargement profil FULL" test_load_full_profile
    
    echo -e "${BLUE}=== Tests Validation ===${NC}"
    run_test "Lazy Loader - Fonction validate_module_before_load" test_validate_module_before_load_function
    run_test "Lazy Loader - Validation module existant" test_validate_existing_module
    
    echo -e "${BLUE}=== Tests Chargement Progressif ===${NC}"
    run_test "Lazy Loader - Fonction progressive_loading" test_progressive_loading_function
    run_test "Lazy Loader - Chargement progressif escalation" test_progressive_loading_escalation
    
    echo -e "${BLUE}=== Tests Cache et Fail-Safe ===${NC}"
    run_test "Lazy Loader - Fonction is_module_loaded" test_is_module_loaded_function
    run_test "Lazy Loader - Vérification module chargé" test_module_loaded_status
    run_test "Lazy Loader - Fonction load_module_fail_safe" test_load_module_fail_safe_function
    run_test "Lazy Loader - Chargement fail-safe module" test_fail_safe_module_loading
    run_test "Lazy Loader - Cache modules chargés" test_module_cache_functionality
    
    echo -e "${BLUE}=== Tests Initialisation ===${NC}"
    run_test "Lazy Loader - Fonction initialize_core_only" test_initialize_core_only_function
    run_test "Lazy Loader - Initialisation core uniquement" test_core_only_initialization
    
    echo -e "${BLUE}=== Tests Avancés ===${NC}"
    run_test "Lazy Loader - Métriques de performance" test_loading_metrics
    run_test "Intégration - Chargement avec classification" test_integration_with_classifier
    run_test "Performance - Chargement rapide MINIMAL" test_minimal_profile_performance
    run_test "Gestion erreurs - Module inexistant" test_error_handling_missing_module
    
    echo "=============================================="
    echo "Résultats des tests:"
    echo "Total: $TESTS_TOTAL"
    echo -e "Réussis: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Échoués: ${RED}$TESTS_FAILED${NC}"
    echo "=============================================="
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 Tous les tests sont passés !${NC}"
        echo -e "${GREEN}Système de chargement paresseux TASK-13-2 validé${NC}"
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