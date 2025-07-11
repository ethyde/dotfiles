#!/bin/bash

# Source le framework de test commun
source "$(dirname "$0")/test_framework.sh"

(
    # --- Setup ---
    setup_test_env
    trap teardown_test_env EXIT
    AKLO_EXEC="${TEST_PROJECT_DIR}/aklo/bin/aklo"
    export AKLO_DEBUG=true # Activer le mode debug pour voir les logs de profil

    # --- Tests ---
    echo "Suite: test_intelligent_architecture"

    # Test 1: Classification des commandes
    output=$($AKLO_EXEC status 2>&1) # 'status' affiche les infos de debug
    assert_contains "$output" "Profil: MINIMAL" "La commande 'status' doit avoir le profil MINIMAL"
    
    output=$($AKLO_EXEC propose-pbi "test" 2>&1)
    assert_contains "$output" "Profil: NORMAL" "La commande 'propose-pbi' doit avoir le profil NORMAL"
    
    output=$($AKLO_EXEC optimize 2>&1)
    assert_contains "$output" "Profil: FULL" "La commande 'optimize' doit avoir le profil FULL"

    # Test 2: Chargement conditionnel des modules
    output=$($AKLO_EXEC status 2>&1)
    assert_contains "$output" "Chargement du module: commands" "'status' doit charger le module 'commands'"
    # Vérifier qu'un module NON nécessaire n'est PAS chargé
    if [[ "$output" != *"parser"* ]]; then
        echo "✓ 'status' ne charge pas le module 'parser' inutilement"
    else
        echo "✗ 'status' ne devrait pas charger le module 'parser'"
        exit 1
    fi
)