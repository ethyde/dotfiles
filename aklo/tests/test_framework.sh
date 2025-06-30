#!/bin/sh
#==============================================================================
# Framework de Tests Unitaires Shell Natif
# 
# Un framework de test minimal utilisant uniquement des outils shell natifs
# Compatible macOS, Linux, Windows WSL - Aucune dépendance externe
#==============================================================================

# Couleurs pour l'affichage (compatible avec la plupart des terminaux)
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# Variables globales pour le comptage des tests
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
CURRENT_SUITE=""

# Fonction: test_suite
# Démarre une nouvelle suite de tests
test_suite() {
    CURRENT_SUITE="$1"
    echo "${BLUE}=== Suite de tests: $CURRENT_SUITE ===${NC}"
}

# Fonction: assert_equals
# Vérifie que deux valeurs sont égales
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$expected" = "$actual" ]; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        echo "  Attendu: '$expected'"
        echo "  Obtenu:  '$actual'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: assert_file_exists
# Vérifie qu'un fichier existe
assert_file_exists() {
    local file_path="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -f "$file_path" ]; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        echo "  Fichier introuvable: '$file_path'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: assert_contains
# Vérifie qu'une chaîne contient une sous-chaîne
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    case "$haystack" in
        *"$needle"*)
            echo "${GREEN}✓${NC} $test_name"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
            ;;
        *)
            echo "${RED}✗${NC} $test_name"
            echo "  '$haystack' ne contient pas '$needle'"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
            ;;
    esac
}

# Fonction: assert_exit_code
# Vérifie le code de sortie d'une commande
assert_exit_code() {
    local expected_code="$1"
    local command="$2"
    local test_name="$3"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    # Exécuter la commande et capturer le code de sortie
    eval "$command" >/dev/null 2>&1
    local actual_code=$?
    
    if [ "$expected_code" -eq "$actual_code" ]; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        echo "  Code attendu: $expected_code"
        echo "  Code obtenu:  $actual_code"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: setup_test_env
# Prépare un environnement de test temporaire
setup_test_env() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR" || exit 1
    echo "Environnement de test: $TEST_DIR"
}

# Fonction: cleanup_test_env
# Nettoie l'environnement de test
cleanup_test_env() {
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
    fi
}

# Fonction: test_summary
# Affiche le résumé des tests
test_summary() {
    echo ""
    echo "${BLUE}=== Résumé des tests ===${NC}"
    echo "Tests exécutés: $TESTS_RUN"
    echo "${GREEN}Tests réussis: $TESTS_PASSED${NC}"
    
    if [ "$TESTS_FAILED" -gt 0 ]; then
        echo "${RED}Tests échoués: $TESTS_FAILED${NC}"
        echo ""
        echo "${RED}❌ Des tests ont échoué${NC}"
        exit 1
    else
        echo ""
        echo "${GREEN}✅ Tous les tests sont passés${NC}"
        exit 0
    fi
}

# Fonction: run_tests
# Point d'entrée principal pour exécuter tous les tests
run_tests() {
    echo "${YELLOW}🧪 Démarrage des tests Aklo${NC}"
    echo ""
    
    # Exécuter les tests
    "$@"
    
    # Afficher le résumé
    test_summary
}