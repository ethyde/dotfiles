#!/bin/bash
#==============================================================================
# Framework de Tests Unitaires Shell Natif
# 
# Un framework de test minimal utilisant uniquement des outils shell natifs
# Compatible macOS, Linux, Windows WSL - Aucune dépendance externe
#==============================================================================

# Couleurs pour l'affichage (compatible avec la plupart des terminaux)
# Détection de terminal désactivée pour une sortie propre dans tous les environnements.
RED=''
GREEN=''
YELLOW=''
BLUE=''
NC=''

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

# Fonction: assert_true
# Vérifie qu'une commande réussit (code de sortie 0)
assert_true() {
    local command_to_run="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "$command_to_run"; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: assert_false
# Vérifie qu'une commande échoue (code de sortie non-0)
assert_false() {
    local command_to_run="$1"
    local test_name="$2"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if ! eval "$command_to_run"; then
        echo "${GREEN}✓${NC} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "${RED}✗${NC} $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Fonction: assert_function_exists
# Vérifie qu'une fonction est déclarée
assert_function_exists() {
    local function_name="$1"
    local test_name="${2:-Fonction '$function_name' doit exister}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if command -v "$function_name" >/dev/null 2>&1; then
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

# Charge l'environnement Aklo complet pour les tests.
# CETTE VERSION CORRIGE LES PROBLEMES DE CHEMINS.
setup_aklo_test_env() {
    # Si la variable n'est pas déjà définie, on la calcule de manière robuste.
    if [ -z "$AKLO_PROJECT_ROOT" ]; then
        # 1. Trouve le chemin réel du présent script (test_framework.sh)
        local framework_real_path
        framework_real_path=$(realpath "${BASH_SOURCE[0]}")
        # 2. Le répertoire du framework est le répertoire parent de ce script
        local test_framework_dir
        test_framework_dir=$(dirname "$framework_real_path")
        # 3. La racine du projet Aklo est le répertoire parent du répertoire des tests
        AKLO_PROJECT_ROOT=$(dirname "$test_framework_dir")
        # 4. On l'exporte pour qu'elle soit disponible dans tous les sous-scripts
        export AKLO_PROJECT_ROOT
    fi

    # Le reste de la fonction charge tous les modules en utilisant ce chemin fiable
    source "${AKLO_PROJECT_ROOT}/aklo/modules/core/config.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/core/parser.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/cache/cache_functions.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/cache/cache_monitoring.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/cache/regex_cache.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/cache/id_cache.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/cache/batch_io.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/io/io_monitoring.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/performance/performance_tuning.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/system_commands.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/new_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/pbi_commands.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/task_commands.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/start-task_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/submit-task_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/merge-task_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/release_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/hotfix_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/debug_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/refactor_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/optimize_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/security_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/experiment_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/docs_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/scratchpad_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/kb_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/meta_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/cache_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/config_command.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/monitor_command.sh"
}

#==============================================================================
# Fonctions de gestion d'environnement de test pour les artefacts
#==============================================================================

# Variables globales pour l'environnement de test d'artefacts
TEST_PROJECT_DIR=""
ORIGINAL_PWD=""

# Prépare un environnement de test isolé pour les commandes créant des artefacts
setup_artefact_test_env() {
    TEST_PROJECT_DIR=$(mktemp -d "/tmp/aklo_artefact_test.XXXXXX")
    ORIGINAL_PWD=$(pwd)

    # AKLO_PROJECT_ROOT est la racine de notre projet dotfiles
    if [ -z "$AKLO_PROJECT_ROOT" ]; then
        export AKLO_PROJECT_ROOT
        AKLO_PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
    fi
    
    # Pour les tests, on veut pointer vers le répertoire aklo spécifiquement
    export AKLO_TEST_ROOT="${AKLO_PROJECT_ROOT}/aklo"

    # 1. Copier l'intégralité de l'outil aklo dans l'environnement de test
    mkdir -p "${TEST_PROJECT_DIR}/aklo"
    cp -r "${AKLO_TEST_ROOT}/bin" "${TEST_PROJECT_DIR}/aklo/"
    cp -r "${AKLO_TEST_ROOT}/modules" "${TEST_PROJECT_DIR}/aklo/"
    cp -r "${AKLO_TEST_ROOT}/charte" "${TEST_PROJECT_DIR}/aklo/"
    
    # 2. Se placer dans le répertoire du projet simulé
    cd "$TEST_PROJECT_DIR" || exit 1
    
    # --- CORRECTION FINALE ---
    # 3. Créer la structure de répertoires attendue par les commandes Aklo
    mkdir -p "docs/backlog/00-pbi"
    mkdir -p "docs/backlog/01-tasks"
    mkdir -p "${TEST_PROJECT_DIR}/.aklo_cache"
    
    # 4. Créer un fichier .aklo.conf local au projet de test
    #    Il n'est plus nécessaire de définir AKLO_PROJECT_ROOT ici, car le script `aklo`
    #    le déterminera dynamiquement avec `pwd`.
    cat > .aklo.conf << EOF
PBI_DIR=docs/backlog/00-pbi
TASKS_DIR=docs/backlog/01-tasks
CACHE_ENABLED=true
CACHE_DEBUG=false
EOF
}

# La fonction de nettoyage doit annuler l'export
teardown_artefact_test_env() {
    if [ -n "$ORIGINAL_PWD" ]; then
        cd "$ORIGINAL_PWD"
    fi
    if [ -n "$TEST_PROJECT_DIR" ] && [ -d "$TEST_PROJECT_DIR" ]; then
        rm -rf "$TEST_PROJECT_DIR"
    fi
    # Nettoie la variable d'environnement
    unset AKLO_PROJECT_ROOT
}
