#!/bin/bash
#==============================================================================
# Framework de Test Aklo - Fonctions et Environnement de Test
#==============================================================================

# --- Configuration de l'environnement de test ---
# Chaque suite de tests s'exécutera dans un répertoire temporaire unique.
export TEST_ENV="true"
export TEST_PROJECT_DIR=$(mktemp -d)
export AKLO_PROJECT_ROOT="$TEST_PROJECT_DIR"
export AKLO_CACHE_DIR="${TEST_PROJECT_DIR}/.aklo_cache"
export AKLO_CONFIG_DIR="${TEST_PROJECT_DIR}/aklo/config"
export AKLO_PBI_DIR="${TEST_PROJECT_DIR}/pbi"

# --- Setup et Teardown ---
setup_test_env() {
    # Crée l'arborescence de base pour les tests
    mkdir -p "$AKLO_CACHE_DIR"
    mkdir -p "${TEST_PROJECT_DIR}/aklo/bin"
    mkdir -p "${TEST_PROJECT_DIR}/aklo/modules/core"
    mkdir -p "${TEST_PROJECT_DIR}/aklo/charte/PROTOCOLES"

    # Détermine la racine du VRAI projet pour copier les fichiers sources
    local real_project_root
    real_project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

    # Copie le binaire 'aklo' et tous les modules
    cp "${real_project_root}/aklo/bin/aklo" "${TEST_PROJECT_DIR}/aklo/bin/aklo"
    cp "${real_project_root}/aklo/modules/commands.sh" "${TEST_PROJECT_DIR}/aklo/modules/commands.sh"
    cp "${real_project_root}/aklo/modules/core/command_classifier.sh" "${TEST_PROJECT_DIR}/aklo/modules/core/command_classifier.sh"
    cp "${real_project_root}/aklo/modules/core/lazy_loader.sh" "${TEST_PROJECT_DIR}/aklo/modules/core/lazy_loader.sh"
    # Copier un protocole pour les tests de parsing
    cp "${real_project_root}/aklo/charte/PROTOCOLES/03-DEVELOPPEMENT.xml" "${TEST_PROJECT_DIR}/aklo/charte/PROTOCOLES/03-DEVELOPPEMENT.xml"

    chmod +x "${TEST_PROJECT_DIR}/aklo/bin/aklo"
}

teardown_test_env() {
    rm -rf "$TEST_PROJECT_DIR"
}


# --- Fonctions d'assertion ---
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"
    
    if [ "$expected" == "$actual" ]; then
        echo "✓ $message"
    else
        echo "✗ $message"
        echo "  Attendu: '$expected'"
        echo "  Obtenu:  '$actual'"
        exit 1
    fi
}

assert_contains() {
    local content="$1"
    local substring="$2"
    local message="$3"

    if [[ "$content" == *"$substring"* ]]; then
        echo "✓ $message"
    else
        echo "✗ $message"
        echo "  '$content' ne contient pas '$substring'"
        exit 1
    fi
}

# ... (d'autres assertions pourraient être ajoutées ici : assert_file_exists, etc.)
