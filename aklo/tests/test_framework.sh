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

# Fonction: assert_directory_exists
# Vérifie qu'un répertoire existe
assert_directory_exists() {
    local dir_path="$1"
    local test_name="${2:-Directory exists: $dir_path}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -d "$dir_path" ]; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        echo "  Répertoire introuvable: '$dir_path'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: assert_file_not_exists
# Vérifie qu'un fichier n'existe pas
assert_file_not_exists() {
    local file_path="$1"
    local test_name="${2:-File should not exist: $file_path}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ ! -f "$file_path" ]; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        echo "  Fichier existe alors qu'il ne devrait pas: '$file_path'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: assert_file_contains
# Vérifie qu'un fichier contient une chaîne
assert_file_contains() {
    local file_path="$1"
    local needle="$2"
    local test_name="${3:-File contains: $needle}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ ! -f "$file_path" ]; then
        echo "${RED}✗${NC} $test_name"
        echo "  Fichier introuvable: '$file_path'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
    
    if grep -q "$needle" "$file_path" 2>/dev/null; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        echo "  '$file_path' ne contient pas '$needle'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: assert_file_not_contains
# Vérifie qu'un fichier ne contient pas une chaîne
assert_file_not_contains() {
    local file_path="$1"
    local needle="$2"
    local test_name="${3:-File does not contain: $needle}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ ! -f "$file_path" ]; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    fi
    
    if ! grep -q "$needle" "$file_path" 2>/dev/null; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        echo "  '$file_path' contient '$needle' alors qu'il ne devrait pas"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: assert_command_success
# Vérifie qu'une commande s'exécute avec succès
assert_command_success() {
    local test_name="$1"
    local last_exit_code=$?
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ "$last_exit_code" -eq 0 ]; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        echo "  Commande échouée avec le code: $last_exit_code"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: assert_function_exists
# Vérifie qu'une fonction existe
assert_function_exists() {
    local function_name="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if command -v "$function_name" >/dev/null 2>&1 || declare -f "$function_name" >/dev/null 2>&1; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        echo "  Fonction '$function_name' n'existe pas"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: assert_not_empty
# Vérifie qu'une valeur n'est pas vide
assert_not_empty() {
    local value="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if [ -n "$value" ]; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        echo "  Valeur vide ou non définie"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: fail
# Force un échec de test avec un message
fail() {
    local message="$1"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    
    echo "${RED}✗${NC} $message"
    return 1
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