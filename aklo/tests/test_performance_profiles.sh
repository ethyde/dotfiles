#!/bin/bash

# Test pour le module performance_profiles.sh
# TASK-13-3: Création des profils adaptatifs de performance

# Configuration des chemins
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AKLO_ROOT="$(dirname "$SCRIPT_DIR")"
MODULE_PATH="$AKLO_ROOT/modules/core/performance_profiles.sh"

# Chargement du framework de test
source "$SCRIPT_DIR/test_framework.sh"

# Variables de test
TEST_NAME="performance_profiles"
TOTAL_TESTS=0
PASSED_TESTS=0

# Fonction de setup
setup_test() {
    # Nettoyer les variables d'environnement
    unset AKLO_PROFILE
    unset AKLO_MODULES
    unset AKLO_TARGET_TIME
}

# Fonction de teardown
teardown_test() {
    setup_test
}

# Test 1: Vérifier que le module peut être chargé
test_module_loading() {
    echo "Test 1: Chargement du module performance_profiles.sh"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ -f "$MODULE_PATH" ]]; then
        if source "$MODULE_PATH" 2>/dev/null; then
            echo "✓ Module chargé avec succès"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "✗ Erreur lors du chargement du module"
        fi
    else
        echo "✗ Module non trouvé: $MODULE_PATH"
    fi
}

# Test 2: Vérifier la fonction get_profile_config
test_get_profile_config() {
    echo "Test 2: Fonction get_profile_config"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if source "$MODULE_PATH" 2>/dev/null; then
        if declare -f get_profile_config > /dev/null; then
            # Test avec profil MINIMAL
            local config=$(get_profile_config "MINIMAL")
            if [[ -n "$config" ]]; then
                echo "✓ get_profile_config retourne une configuration pour MINIMAL"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                echo "✗ get_profile_config ne retourne pas de configuration pour MINIMAL"
            fi
        else
            echo "✗ Fonction get_profile_config non trouvée"
        fi
    else
        echo "✗ Impossible de charger le module pour le test"
    fi
}

# Test 3: Vérifier la fonction detect_optimal_profile
test_detect_optimal_profile() {
    echo "Test 3: Fonction detect_optimal_profile"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if source "$MODULE_PATH" 2>/dev/null; then
        if declare -f detect_optimal_profile > /dev/null; then
            # Test avec une commande simple
            local profile=$(detect_optimal_profile "status")
            if [[ "$profile" == "MINIMAL" ]]; then
                echo "✓ detect_optimal_profile retourne MINIMAL pour 'status'"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                echo "✗ detect_optimal_profile ne retourne pas MINIMAL pour 'status' (retourné: $profile)"
            fi
        else
            echo "✗ Fonction detect_optimal_profile non trouvée"
        fi
    else
        echo "✗ Impossible de charger le module pour le test"
    fi
}

# Test 4: Vérifier la fonction apply_profile
test_apply_profile() {
    echo "Test 4: Fonction apply_profile"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if source "$MODULE_PATH" 2>/dev/null; then
        if declare -f apply_profile > /dev/null; then
            # Test d'application du profil MINIMAL
            apply_profile "MINIMAL"
            if [[ -n "$AKLO_MODULES" ]]; then
                echo "✓ apply_profile configure les variables d'environnement"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                echo "✗ apply_profile ne configure pas les variables d'environnement"
            fi
        else
            echo "✗ Fonction apply_profile non trouvée"
        fi
    else
        echo "✗ Impossible de charger le module pour le test"
    fi
}

# Test 5: Vérifier l'override via AKLO_PROFILE
test_profile_override() {
    echo "Test 5: Override via AKLO_PROFILE"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if source "$MODULE_PATH" 2>/dev/null; then
        if declare -f detect_optimal_profile > /dev/null; then
            # Test avec override
            export AKLO_PROFILE="FULL"
            local profile=$(detect_optimal_profile "status")
            if [[ "$profile" == "FULL" ]]; then
                echo "✓ Override AKLO_PROFILE fonctionne"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                echo "✗ Override AKLO_PROFILE ne fonctionne pas (retourné: $profile)"
            fi
        else
            echo "✗ Fonction detect_optimal_profile non trouvée"
        fi
    else
        echo "✗ Impossible de charger le module pour le test"
    fi
}

# Test 6: Vérifier la fonction validate_profile
test_validate_profile() {
    echo "Test 6: Fonction validate_profile"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if source "$MODULE_PATH" 2>/dev/null; then
        if declare -f validate_profile > /dev/null; then
            # Test avec profil valide
            if validate_profile "MINIMAL"; then
                echo "✓ validate_profile valide le profil MINIMAL"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                echo "✗ validate_profile ne valide pas le profil MINIMAL"
            fi
        else
            echo "✗ Fonction validate_profile non trouvée"
        fi
    else
        echo "✗ Impossible de charger le module pour le test"
    fi
}

# Test 7: Vérifier la fonction get_profile_metrics
test_get_profile_metrics() {
    echo "Test 7: Fonction get_profile_metrics"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if source "$MODULE_PATH" 2>/dev/null; then
        if declare -f get_profile_metrics > /dev/null; then
            # Test de récupération des métriques
            local metrics=$(get_profile_metrics "MINIMAL")
            if [[ -n "$metrics" ]]; then
                echo "✓ get_profile_metrics retourne des métriques"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                echo "✗ get_profile_metrics ne retourne pas de métriques"
            fi
        else
            echo "✗ Fonction get_profile_metrics non trouvée"
        fi
    else
        echo "✗ Impossible de charger le module pour le test"
    fi
}

# Fonction principale de test
run_tests() {
    echo "=== Tests du module performance_profiles.sh ==="
    echo "Module testé: $MODULE_PATH"
    echo ""
    
    setup_test
    
    test_module_loading
    test_get_profile_config
    test_detect_optimal_profile
    test_apply_profile
    test_profile_override
    test_validate_profile
    test_get_profile_metrics
    
    teardown_test
    
    echo ""
    echo "=== Résultats des tests ==="
    echo "Tests passés: $PASSED_TESTS/$TOTAL_TESTS"
    
    if [[ $PASSED_TESTS -eq $TOTAL_TESTS ]]; then
        echo "✅ Tous les tests sont passés!"
        return 0
    else
        echo "❌ Certains tests ont échoué"
        return 1
    fi
}

# Exécuter les tests si le script est appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi