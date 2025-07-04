#!/bin/bash

# Test d'intégration pour le module performance_profiles.sh
# TASK-13-3: Validation du comportement complet des profils adaptatifs

# Configuration des chemins
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AKLO_ROOT="$(dirname "$SCRIPT_DIR")"
MODULE_PATH="$AKLO_ROOT/modules/core/performance_profiles.sh"

# Chargement du framework de test
source "$SCRIPT_DIR/test_framework.sh"

# Variables de test
TEST_NAME="performance_profiles_integration"
TOTAL_TESTS=0
PASSED_TESTS=0

# Fonction de setup
setup_test() {
    unset AKLO_PROFILE AKLO_MODULES AKLO_TARGET_TIME AKLO_PROFILE_DESCRIPTION AKLO_CURRENT_PROFILE
    # Forcer le rechargement du module pour nettoyer l'état
    if [[ -f "$MODULE_PATH" ]]; then
        source "$MODULE_PATH" 2>/dev/null
    fi
}

# Fonction de teardown
teardown_test() {
    setup_test
}

# Test d'intégration complet
test_full_integration() {
    echo "Test d'intégration: Cycle complet de détection et application"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if source "$MODULE_PATH" 2>/dev/null; then
        # 1. Détection automatique pour commande 'status'
        local detected_profile=$(detect_optimal_profile "status")
        if [[ "$detected_profile" == "MINIMAL" ]]; then
            echo "  ✓ Détection automatique: status -> MINIMAL"
        else
            echo "  ✗ Détection automatique échouée pour 'status'"
            return 1
        fi
        
        # 2. Application du profil détecté
        apply_profile "$detected_profile"
        if [[ "$AKLO_CURRENT_PROFILE" == "MINIMAL" ]] && [[ -n "$AKLO_MODULES" ]]; then
            echo "  ✓ Application du profil MINIMAL réussie"
        else
            echo "  ✗ Application du profil MINIMAL échouée"
            return 1
        fi
        
        # 3. Test avec override
        export AKLO_PROFILE="FULL"
        local override_profile=$(detect_optimal_profile "status")
        if [[ "$override_profile" == "FULL" ]]; then
            echo "  ✓ Override AKLO_PROFILE fonctionne"
        else
            echo "  ✗ Override AKLO_PROFILE échoué"
            return 1
        fi
        
        # Nettoyer l'override pour les tests suivants
        unset AKLO_PROFILE
        
        # 4. Validation des métriques
        local metrics=$(get_profile_metrics "FULL")
        if echo "$metrics" | grep -q "PROFILE=FULL" && echo "$metrics" | grep -q "TARGET_TIME=1.000s"; then
            echo "  ✓ Métriques du profil FULL correctes"
        else
            echo "  ✗ Métriques du profil FULL incorrectes ($metrics)"
            return 1
        fi
        
        echo "✓ Test d'intégration complet réussi"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo "✗ Impossible de charger le module pour le test d'intégration"
    fi
}

# Test des temps cibles
test_target_times() {
    echo "Test des temps cibles des profils"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if source "$MODULE_PATH" 2>/dev/null; then
        local passed=true
        
        # Vérifier MINIMAL < 0.050s
        local minimal_config=$(get_profile_config "MINIMAL")
        if echo "$minimal_config" | grep -q "TARGET_TIME=\"0.050\""; then
            echo "  ✓ MINIMAL: temps cible 0.050s"
        else
            echo "  ✗ MINIMAL: temps cible incorrect ($minimal_config)"
            passed=false
        fi
        
        # Vérifier NORMAL < 0.200s
        local normal_config=$(get_profile_config "NORMAL")
        if echo "$normal_config" | grep -q "TARGET_TIME=\"0.200\""; then
            echo "  ✓ NORMAL: temps cible 0.200s"
        else
            echo "  ✗ NORMAL: temps cible incorrect ($normal_config)"
            passed=false
        fi
        
        # Vérifier FULL < 1.000s
        local full_config=$(get_profile_config "FULL")
        if echo "$full_config" | grep -q "TARGET_TIME=\"1.000\""; then
            echo "  ✓ FULL: temps cible 1.000s"
        else
            echo "  ✗ FULL: temps cible incorrect ($full_config)"
            passed=false
        fi
        
        if [[ "$passed" == true ]]; then
            echo "✓ Tous les temps cibles sont respectés"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "✗ Certains temps cibles ne sont pas respectés"
        fi
    else
        echo "✗ Impossible de charger le module pour le test des temps cibles"
    fi
}

# Test de la classification des commandes
test_command_classification() {
    echo "Test de la classification des commandes"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if source "$MODULE_PATH" 2>/dev/null; then
        local passed=true
        
        # S'assurer qu'aucun override n'est actif
        unset AKLO_PROFILE
        
        # Commandes MINIMAL
        for cmd in "status" "help" "version" "config"; do
            local profile=$(detect_optimal_profile "$cmd")
            if [[ "$profile" == "MINIMAL" ]]; then
                echo "  ✓ $cmd -> MINIMAL"
            else
                echo "  ✗ $cmd -> $profile (attendu: MINIMAL)"
                passed=false
            fi
        done
        
        # Commandes NORMAL
        for cmd in "init" "propose-pbi" "plan" "start-task"; do
            local profile=$(detect_optimal_profile "$cmd")
            if [[ "$profile" == "NORMAL" ]]; then
                echo "  ✓ $cmd -> NORMAL"
            else
                echo "  ✗ $cmd -> $profile (attendu: NORMAL)"
                passed=false
            fi
        done
        
        # Commandes FULL
        for cmd in "analyze" "optimize" "monitor" "benchmark"; do
            local profile=$(detect_optimal_profile "$cmd")
            if [[ "$profile" == "FULL" ]]; then
                echo "  ✓ $cmd -> FULL"
            else
                echo "  ✗ $cmd -> $profile (attendu: FULL)"
                passed=false
            fi
        done
        
        if [[ "$passed" == true ]]; then
            echo "✓ Classification des commandes correcte"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo "✗ Erreurs dans la classification des commandes"
        fi
    else
        echo "✗ Impossible de charger le module pour le test de classification"
    fi
}

# Fonction principale de test
run_tests() {
    echo "=== Tests d'intégration du module performance_profiles.sh ==="
    echo "Module testé: $MODULE_PATH"
    echo ""
    
    setup_test
    
    test_full_integration
    test_target_times
    test_command_classification
    
    teardown_test
    
    echo ""
    echo "=== Résultats des tests d'intégration ==="
    echo "Tests passés: $PASSED_TESTS/$TOTAL_TESTS"
    
    if [[ $PASSED_TESTS -eq $TOTAL_TESTS ]]; then
        echo "✅ Tous les tests d'intégration sont passés!"
        return 0
    else
        echo "❌ Certains tests d'intégration ont échoué"
        return 1
    fi
}

# Exécuter les tests si le script est appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi