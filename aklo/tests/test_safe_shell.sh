#!/bin/bash

# Source le framework de test commun
source "$(dirname "$0")/test_framework.sh"

(
    # --- Setup ---
    setup_test_env
    # S'assure que le cleanup est appelé à la fin
    trap teardown_test_env EXIT

    AKLO_EXEC="${TEST_PROJECT_DIR}/aklo/bin/aklo"

    # --- Tests ---
    echo "Suite: test_internal_commands"
    
    # Test 1: Commande interne valide
    output=$($AKLO_EXEC help 2>&1)
    exit_code=$?
    assert_equals "0" "$exit_code" "Une commande interne valide (help) doit réussir"
    assert_contains "$output" "Usage: aklo" "La sortie doit être le message d'aide"

    # Test 2: Commande interne inconnue
    output=$($AKLO_EXEC commande_inconnue 2>&1)
    exit_code=$?
    assert_equals "1" "$exit_code" "Une commande interne inconnue doit échouer"
    assert_contains "$output" "Erreur: Commande 'commande_inconnue' inconnue" "Doit afficher un message d'erreur clair"

) 