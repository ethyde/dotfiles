#!/usr/bin/env bash
#==============================================================================
# Tests d'Intégration pour l'outil safe_shell
#==============================================================================

# Source du framework de test
source "$(dirname "$0")/test_framework.sh"

# Chemin vers le script aklo-terminal.sh
AKLO_TERMINAL_SCRIPT="$(dirname "$0")/../modules/mcp/shell-native/aklo-terminal.sh"

#==============================================================================
# SUITE DE TESTS : SAFE_SHELL
#==============================================================================

test_suite "safe_shell: Exécution de commandes autorisées"

setup() {
  # Ajoute 'sleep' à la whitelist si absent
  grep -q '^sleep$' ./aklo/config/commands.whitelist || echo 'sleep' >> ./aklo/config/commands.whitelist
}
teardown() {
  # Retire 'sleep' de la whitelist après le test
  sed -i '' '/^sleep$/d' ./aklo/config/commands.whitelist
}

setup

# Test 1: Vérifier que 'ls -l' (commande autorisée) s'exécute correctement
test_safe_shell_ls() {
    local cmd_input='{"command": "ls -l", "timeout": 1000}'
    
    # Exécuter la commande via un pipe
    local output
    output=$(echo "$cmd_input" | "$AKLO_TERMINAL_SCRIPT" "safe_shell")
    local exit_code=$?
    
    assert_equals "0" "$exit_code" "Le script doit se terminer avec un code 0"
    
    # Valider le JSON de sortie (nécessite jq)
    if ! command -v jq > /dev/null; then
        echo "SKIPPING JSON validation: jq is not installed."
        return
    fi
    
    local status
    status=$(echo "$output" | jq -r '.status')
    local stdout
    stdout=$(echo "$output" | jq -r '.stdout')
    local stderr
    stderr=$(echo "$output" | jq -r '.stderr')
    
    assert_equals "success" "$status" "Le statut de la commande doit être 'success'"
    assert_contains "$stdout" "total" "La sortie standard doit contenir 'total' (typique de ls -l)"
    assert_equals "" "$stderr" "La sortie d'erreur doit être vide"
}

# Test 2: Vérifier qu'une commande interdite est rejetée
test_forbidden_command() {
    test_suite "safe_shell: Rejet des commandes interdites"
    local cmd_input='{"command": "rm -rf /", "timeout": 1000}'
    
    # Exécuter et s'attendre à un code de sortie non-nul
    local output
    output=$(echo "$cmd_input" | "$AKLO_TERMINAL_SCRIPT" "safe_shell" 2>&1)
    local exit_code=$?
    
    assert_equals "1" "$exit_code" "Le script doit se terminer avec un code 1 (erreur)"
    
    # Valider le message d'erreur JSON
    local status
    status=$(echo "$output" | jq -r '.status')
    local message
    message=$(echo "$output" | jq -r '.message')
    
    assert_equals "error" "$status" "Le statut doit être 'error'"
    assert_contains "$message" "not in the allowed list" "Le message d'erreur doit mentionner l'interdiction"
}

# Test 3: Vérifier que le timeout fonctionne
test_timeout() {
    test_suite "safe_shell: Gestion du timeout"
    local cmd_input='{"command": "sleep 5", "timeout": 100}' # Timeout de 100ms
    
    local output
    output=$(echo "$cmd_input" | "$AKLO_TERMINAL_SCRIPT" "safe_shell")
    local exit_code=$?
    
    assert_equals "0" "$exit_code" "Le script doit se terminer avec un code 0"
    
    # Valider la sortie JSON pour le timeout
    local cmd_exit_code
    cmd_exit_code=$(echo "$output" | jq -r '.exit_code')
    
    assert_equals "124" "$cmd_exit_code" "Le code de sortie de la commande doit être 124 (timeout)"
}

# Lancer les tests
test_safe_shell_ls
test_forbidden_command
test_timeout
test_summary 
teardown 