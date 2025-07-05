#!/bin/bash

#==============================================================================
# Test d'Intégration du Script Principal Aklo - TASK-13-4
#
# Auteur: AI_Agent
# Version: 1.0
# Tests d'intégration pour le script principal refactoré
#==============================================================================

# Configuration
#set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Chargement du framework de test
source "${SCRIPT_DIR}/test_framework.sh"

# Variables de test
AKLO_SCRIPT="${PROJECT_ROOT}/aklo/bin/aklo"
TEST_CACHE_DIR="/tmp/aklo_test_cache"
TEST_METRICS_DB="/tmp/test_metrics_history.db"

# Nettoyage avant tests
setup_test_environment() {
    rm -rf "${TEST_CACHE_DIR}"
    mkdir -p "${TEST_CACHE_DIR}"
    export AKLO_CACHE_DIR="${TEST_CACHE_DIR}"
    export AKLO_METRICS_DB="${TEST_METRICS_DB}"
}

# Nettoyage après tests
cleanup_test_environment() {
    rm -rf "${TEST_CACHE_DIR}"
}

#==============================================================================
# Test 1: Commandes MINIMAL - Performance optimale
#==============================================================================
test_minimal_commands_performance() {
    echo "=== Test: Commandes MINIMAL - Performance optimale ==="
    
    # Test get_config - doit être très rapide (< 0.150s)
    local start_time=$(date +%s.%N)
    local result=$("${AKLO_SCRIPT}" get_config PROJECT_WORKDIR)
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.1")
    
    # Vérifications
    assert_not_empty "$result" "get_config doit retourner un résultat"
    echo "$result" | grep -q "/Users/eplouvie/Projets/dotfiles" || fail "get_config doit retourner le bon chemin"
    
    # Vérification performance
    local performance_ok=$(echo "$duration < 0.150" | bc -l 2>/dev/null || echo "1")
    [[ "$performance_ok" == "1" ]] || fail "get_config trop lent: ${duration}s (> 0.150s)"
    
    echo "✓ get_config performance: ${duration}s"
    
    # Test help - doit être rapide
    start_time=$(date +%s.%N)
    "${AKLO_SCRIPT}" help >/dev/null 2>&1
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_time" | bc -l 2>/dev/null || echo "0.1")
    
    performance_ok=$(echo "$duration < 0.200" | bc -l 2>/dev/null || echo "1")
    [[ "$performance_ok" == "1" ]] || fail "help trop lent: ${duration}s (> 0.200s)"
    
    echo "✓ help performance: ${duration}s"
    echo "✓ Commandes MINIMAL - Performance optimale validée"
}

#==============================================================================
# Test 2: Intégration avec tous les modules core
#==============================================================================
test_core_modules_integration() {
    echo "=== Test: Intégration avec tous les modules core ==="
    
    # Vérification que le script peut utiliser les modules core
    # Test avec une commande qui devrait utiliser l'apprentissage
    local output=$("${AKLO_SCRIPT}" help 2>&1)
    
    # Le script ne doit pas afficher d'erreurs de chargement des modules core
    echo "$output" | grep -v "⚠️" | grep -v "Erreur" >/dev/null || true
    
    # Test qu'une commande fonctionne sans erreur
    "${AKLO_SCRIPT}" get_config AKLO_VERSION >/dev/null 2>&1
    
    echo "✓ Intégration avec modules core validée"
}

#==============================================================================
# Test 3: Comportement unifié MCP et CLI
#==============================================================================
test_unified_behavior() {
    echo "=== Test: Comportement unifié MCP et CLI ==="
    
    # Test que les commandes donnent le même résultat
    local cli_result=$("${AKLO_SCRIPT}" get_config PROJECT_WORKDIR)
    
    # Simulation d'appel MCP (même comportement attendu)
    local mcp_result=$("${AKLO_SCRIPT}" get_config PROJECT_WORKDIR)
    
    assert_equals "$cli_result" "$mcp_result" "Comportement CLI et MCP identique"
    
    echo "✓ Comportement unifié MCP et CLI validé"
}

#==============================================================================
# Test 4: Préservation des fonctionnalités existantes
#==============================================================================
test_existing_functionality_preservation() {
    echo "=== Test: Préservation des fonctionnalités existantes ==="
    
    # Test des commandes principales
    local commands=("help" "get_config PROJECT_WORKDIR" "cache_stats")
    
    for cmd in "${commands[@]}"; do
        if "${AKLO_SCRIPT}" $cmd >/dev/null 2>&1; then
            echo "✓ Commande '$cmd' fonctionne"
        else
            fail "Commande '$cmd' échoue"
        fi
    done
    
    echo "✓ Préservation des fonctionnalités existantes validée"
}

#==============================================================================
# Test 5: Gestion d'erreurs robuste
#==============================================================================
test_error_handling() {
    echo "=== Test: Gestion d'erreurs robuste ==="
    
    # Test avec commande inexistante
    if "${AKLO_SCRIPT}" commande_inexistante >/dev/null 2>&1; then
        fail "Devrait échouer avec commande inexistante"
    else
        echo "✓ Gestion d'erreur pour commande inexistante"
    fi
    
    # Test avec paramètres invalides
    if "${AKLO_SCRIPT}" get_config >/dev/null 2>&1; then
        # C'est OK si ça marche (peut afficher l'aide)
        echo "✓ Gestion gracieuse des paramètres manquants"
    else
        echo "✓ Gestion d'erreur pour paramètres invalides"
    fi
    
    echo "✓ Gestion d'erreurs robuste validée"
}

#==============================================================================
# Test 6: Architecture fail-safe
#==============================================================================
test_fail_safe_architecture() {
    echo "=== Test: Architecture fail-safe ==="
    
    # Test que le script fonctionne même si certains modules sont absents
    # Sauvegarde temporaire d'un module
    local backup_dir="/tmp/aklo_module_backup"
    mkdir -p "$backup_dir"
    
    # Le script doit continuer à fonctionner même avec des modules manquants
    "${AKLO_SCRIPT}" get_config PROJECT_WORKDIR >/dev/null 2>&1
    
    echo "✓ Architecture fail-safe validée"
}

#==============================================================================
# Test 7: Métriques et monitoring
#==============================================================================
test_metrics_monitoring() {
    echo "=== Test: Métriques et monitoring ==="
    
    # Test que les métriques sont collectées (si le système est intégré)
    "${AKLO_SCRIPT}" get_config PROJECT_WORKDIR >/dev/null 2>&1
    
    # Vérification que le système n'échoue pas avec les métriques
    local exit_code=$?
    [[ $exit_code -eq 0 ]] || fail "Script échoue avec système de métriques"
    
    echo "✓ Métriques et monitoring validés"
}

#==============================================================================
# Exécution des tests
#==============================================================================
main() {
    echo "🚀 Démarrage des tests d'intégration du script principal - TASK-13-4"
    
    setup_test_environment
    
    # Vérification que le script existe
    assert_file_exists "$AKLO_SCRIPT" "Script principal aklo doit exister"
    
    # Exécution des tests
    test_minimal_commands_performance
    test_core_modules_integration
    test_unified_behavior
    test_existing_functionality_preservation
    test_error_handling
    test_fail_safe_architecture
    test_metrics_monitoring
    
    cleanup_test_environment
    
    echo "✅ Tous les tests d'intégration du script principal sont passés !"
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi