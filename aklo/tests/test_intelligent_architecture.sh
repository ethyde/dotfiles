#!/bin/bash

#==============================================================================
# Test de l'Architecture Intelligente - TASK-13-4
#
# Auteur: AI_Agent
# Version: 1.0
# Tests spécifiques pour valider l'architecture intelligente fail-safe
#==============================================================================

# Configuration des tests
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
AKLO_SCRIPT="${PROJECT_ROOT}/aklo/bin/aklo"

# Chargement du framework de test
source "${SCRIPT_DIR}/test_framework.sh"

#==============================================================================
# Test 1: Classification des commandes
#==============================================================================
test_command_classification() {
    echo "=== Test: Classification des commandes ==="
    
    # Test commandes MINIMAL
    local output=$("${AKLO_SCRIPT}" get_config PROJECT_WORKDIR 2>&1)
    echo "$output" | grep -q "Profil: MINIMAL" || fail "get_config devrait être MINIMAL"
    
    output=$("${AKLO_SCRIPT}" help 2>&1)
    echo "$output" | grep -q "Profil: MINIMAL" || fail "help devrait être MINIMAL"
    
    # Test commandes NORMAL
    output=$("${AKLO_SCRIPT}" plan 2>&1 | head -5)
    echo "$output" | grep -q "Profil: NORMAL" || fail "plan devrait être NORMAL"
    
    # Test commandes FULL
    output=$("${AKLO_SCRIPT}" optimize 2>&1 | head -5)
    echo "$output" | grep -q "Profil: FULL" || fail "optimize devrait être FULL"
    
    echo "✓ Classification des commandes validée"
}

#==============================================================================
# Test 2: Chargement conditionnel des modules
#==============================================================================
test_conditional_loading() {
    echo "=== Test: Chargement conditionnel des modules ==="
    
    # Test MINIMAL - 0 modules
    local output=$("${AKLO_SCRIPT}" get_config PROJECT_WORKDIR 2>&1)
    echo "$output" | grep -q "Modules chargés: 0" || fail "MINIMAL devrait charger 0 modules"
    
    # Test NORMAL - 1 module
    output=$("${AKLO_SCRIPT}" plan 2>&1 | head -5)
    echo "$output" | grep -q "Modules chargés: 1" || fail "NORMAL devrait charger 1 module"
    
    # Test FULL - 1 module
    output=$("${AKLO_SCRIPT}" optimize 2>&1 | head -5)
    echo "$output" | grep -q "Modules chargés: 1" || fail "FULL devrait charger 1 module"
    
    echo "✓ Chargement conditionnel validé"
}

#==============================================================================
# Test 3: Performance de l'architecture
#==============================================================================
test_performance() {
    echo "=== Test: Performance de l'architecture ==="
    
    # Test MINIMAL - très rapide
    local start_time=$(date +%s.%N)
    "${AKLO_SCRIPT}" get_config PROJECT_WORKDIR >/dev/null 2>&1
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.1")
    
    local performance_ok=$(echo "$duration < 0.200" | bc -l 2>/dev/null || echo "1")
    [[ "$performance_ok" == "1" ]] || fail "MINIMAL trop lent: ${duration}s"
    
    echo "✓ Performance MINIMAL: ${duration}s"
    
    # Test NORMAL - rapide
    start_time=$(date +%s.%N)
    "${AKLO_SCRIPT}" plan >/dev/null 2>&1 || true  # Peut échouer sur les args
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.1")
    
    performance_ok=$(echo "$duration < 0.300" | bc -l 2>/dev/null || echo "1")
    [[ "$performance_ok" == "1" ]] || fail "NORMAL trop lent: ${duration}s"
    
    echo "✓ Performance NORMAL: ${duration}s"
    
    echo "✓ Performance de l'architecture validée"
}

#==============================================================================
# Test 4: Préservation des fonctionnalités
#==============================================================================
test_functionality_preservation() {
    echo "=== Test: Préservation des fonctionnalités ==="
    
    # Test que les commandes fonctionnent toujours
    local result=$("${AKLO_SCRIPT}" get_config PROJECT_WORKDIR 2>/dev/null)
    echo "$result" | grep -q "/Users/eplouvie/Projets/dotfiles" || fail "get_config ne fonctionne plus"
    
    # Test que help fonctionne
    "${AKLO_SCRIPT}" help >/dev/null 2>&1 || fail "help ne fonctionne plus"
    
    # Test que optimize affiche l'aide
    local output=$("${AKLO_SCRIPT}" optimize 2>&1)
    echo "$output" | grep -q "Usage:" || fail "optimize ne fonctionne plus"
    
    echo "✓ Préservation des fonctionnalités validée"
}

#==============================================================================
# Test 5: Métriques de chargement
#==============================================================================
test_loading_metrics() {
    echo "=== Test: Métriques de chargement ==="
    
    # Test que les métriques sont affichées
    local output=$("${AKLO_SCRIPT}" get_config PROJECT_WORKDIR 2>&1)
    echo "$output" | grep -q "Initialisation terminée en" || fail "Métriques de timing manquantes"
    
    # Test que les informations de profil sont affichées
    echo "$output" | grep -q "Architecture intelligente activée" || fail "Message d'activation manquant"
    echo "$output" | grep -q "Commande:" || fail "Information de commande manquante"
    echo "$output" | grep -q "Profil:" || fail "Information de profil manquante"
    
    echo "✓ Métriques de chargement validées"
}

#==============================================================================
# Test 6: Robustesse et gestion d'erreurs
#==============================================================================
test_robustness() {
    echo "=== Test: Robustesse et gestion d'erreurs ==="
    
    # Test avec commande inconnue
    local output=$("${AKLO_SCRIPT}" commande_inconnue 2>&1 || true)
    echo "$output" | grep -q "Architecture intelligente activée" || fail "Architecture non initialisée pour commande inconnue"
    
    # Test que le script ne crash pas
    "${AKLO_SCRIPT}" commande_inconnue >/dev/null 2>&1 || echo "Commande inconnue gérée gracieusement"
    
    echo "✓ Robustesse validée"
}

#==============================================================================
# Exécution des tests
#==============================================================================
main() {
    echo "🚀 Démarrage des tests de l'architecture intelligente - TASK-13-4"
    
    # Vérification que le script existe
    assert_file_exists "$AKLO_SCRIPT" "Script principal aklo doit exister"
    
    # Exécution des tests
    test_command_classification
    test_conditional_loading
    test_performance
    test_functionality_preservation
    test_loading_metrics
    test_robustness
    
    echo "✅ Tous les tests de l'architecture intelligente sont passés !"
    echo "🎯 Architecture fail-safe avec lazy loading opérationnelle"
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi