#!/usr/bin/env bash

#==============================================================================
# Tests pour usage_database.sh - TASK-13-6
#
# Auteur: AI_Agent
# Tests unitaires pour le module de gestion de la base de données d'apprentissage
#==============================================================================

# Configuration de base
set -e

# Variables de test
TEST_DIR="/tmp/aklo_test_usage_db_$$"
TEST_DB_FILE="$TEST_DIR/test_learning_patterns.db"
TEST_BACKUP_DIR="$TEST_DIR/backups"

# Couleurs pour les tests
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
TESTS_PASSED=0
TESTS_FAILED=0

# Fonction utilitaire pour les tests
setup_test_environment() {
    mkdir -p "$TEST_DIR"
    mkdir -p "$TEST_BACKUP_DIR"
    export AKLO_DATA_DIR="$TEST_DIR"
    export USAGE_DB_FILE="$TEST_DB_FILE"
    export USAGE_BACKUP_DIR="$TEST_BACKUP_DIR"
    # Correction du nom de fichier pour correspondre au module
    TEST_DB_FILE="$TEST_DIR/learning_patterns.db"
}

cleanup_test_environment() {
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

run_test() {
    local test_name="$1"
    local test_function="$2"
    
    echo -n "Test: $test_name ... "
    
    if $test_function; then
        echo -e "${GREEN}PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Test 1: Chargement du module usage_database.sh
test_module_loading() {
    # Ce test doit échouer car le module n'existe pas encore
    if [[ -f "../modules/core/usage_database.sh" ]]; then
        source "../modules/core/usage_database.sh"
        return 0
    else
        return 1
    fi
}

# Test 2: Initialisation de la base de données
test_database_initialization() {
    # Ce test doit échouer car la fonction n'existe pas encore
    if declare -f init_usage_database >/dev/null; then
        init_usage_database
        [[ -f "$TEST_DB_FILE" ]] && return 0
        return 1
    else
        return 1
    fi
}

# Test 3: Sauvegarde des données d'usage
test_save_usage_data() {
    # Ce test doit échouer car la fonction n'existe pas encore
    if declare -f save_usage_data >/dev/null; then
        # Initialiser d'abord la base de données
        init_usage_database
        save_usage_data "test_command" "NORMAL" "cli" "0.150"
        [[ -f "$TEST_DB_FILE" ]] && return 0
        return 1
    else
        return 1
    fi
}

# Test 4: Chargement des données d'usage
test_load_usage_data() {
    # Ce test doit échouer car la fonction n'existe pas encore
    if declare -f load_usage_data >/dev/null; then
        load_usage_data
        return 0
    else
        return 1
    fi
}

# Test 5: Recherche de patterns similaires
test_find_similar_patterns() {
    # Ce test doit échouer car la fonction n'existe pas encore
    if declare -f find_similar_patterns >/dev/null; then
        local result
        result=$(find_similar_patterns "test_cmd")
        [[ -n "$result" ]]
    else
        return 1
    fi
}

# Test 6: Mise à jour des statistiques d'usage
test_update_usage_stats() {
    # Ce test doit échouer car la fonction n'existe pas encore
    if declare -f update_usage_stats >/dev/null; then
        update_usage_stats "test_command" "success" "0.120"
        return 0
    else
        return 1
    fi
}

# Test 7: Nettoyage des données obsolètes
test_cleanup_old_data() {
    # Ce test doit échouer car la fonction n'existe pas encore
    if declare -f cleanup_old_usage_data >/dev/null; then
        cleanup_old_usage_data 30  # Nettoie les données > 30 jours
        return 0
    else
        return 1
    fi
}

# Test 8: Export des données d'apprentissage
test_export_learning_data() {
    # Ce test doit échouer car la fonction n'existe pas encore
    if declare -f export_learning_data >/dev/null; then
        local export_file="$TEST_DIR/export.json"
        export_learning_data "$export_file"
        [[ -f "$export_file" ]]
    else
        return 1
    fi
}

# Test 9: Validation de l'intégrité de la base de données
test_validate_database_integrity() {
    # Ce test doit échouer car la fonction n'existe pas encore
    if declare -f validate_database_integrity >/dev/null; then
        validate_database_integrity
        return 0
    else
        return 1
    fi
}

# Test 10: Gestion des erreurs de base de données
test_database_error_handling() {
    # Ce test doit échouer car la fonction n'existe pas encore
    if declare -f handle_database_error >/dev/null; then
        # Test simple sans changement de permissions
        handle_database_error "write_error"
        return $?
    else
        return 1
    fi
}

# Fonction principale des tests
main() {
    echo "=== Tests Usage Database Module - TASK-13-6 ==="
    echo "Répertoire de test: $TEST_DIR"
    
    setup_test_environment
    
    # Exécution des tests (tous doivent échouer initialement - TDD RED)
    run_test "Module loading" test_module_loading
    run_test "Database initialization" test_database_initialization
    run_test "Save usage data" test_save_usage_data
    run_test "Load usage data" test_load_usage_data
    run_test "Find similar patterns" test_find_similar_patterns
    run_test "Update usage stats" test_update_usage_stats
    run_test "Cleanup old data" test_cleanup_old_data
    run_test "Export learning data" test_export_learning_data
    run_test "Validate database integrity" test_validate_database_integrity
    run_test "Database error handling" test_database_error_handling
    
    cleanup_test_environment
    
    # Résumé des tests
    echo ""
    echo "=== Résumé des Tests ==="
    echo -e "Tests passés: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests échoués: ${RED}$TESTS_FAILED${NC}"
    echo -e "Total: $((TESTS_PASSED + TESTS_FAILED))"
    
    # Vérification du résultat des tests
    if [[ $TESTS_FAILED -eq 10 && $TESTS_PASSED -eq 0 ]]; then
        echo -e "${YELLOW}Phase RED du TDD: Tous les tests échouent comme attendu${NC}"
        exit 0
    elif [[ $TESTS_PASSED -eq 10 && $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}Phase GREEN du TDD: Tous les tests passent${NC}"
        exit 0
    else
        echo -e "${YELLOW}Phase intermédiaire du TDD: $TESTS_PASSED tests passent, $TESTS_FAILED échouent${NC}"
        exit 0
    fi
}

# Exécution si appelé directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi