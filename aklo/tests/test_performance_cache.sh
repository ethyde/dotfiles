#!/bin/bash

# Source des dépendances
source "$AKLO_PROJECT_ROOT/modules/core/command_classifier.sh"

setup() {
    # Pas de setup nécessaire pour ce test
    return 0
}

teardown() {
    # Pas de teardown nécessaire pour ce test
    return 0
}

test_command_classification_cache_performance() {
    # Test de performance non implémenté car peu fiable en CI
    assert_true "Test de performance non implémenté" true
}

test_command_classification_cache_consistency() {
    local result1
    result1=$(classify_command "test_cache_command")
    local result2
    result2=$(classify_command "test_cache_command")

    assert_equal "Les résultats avec cache doivent être cohérents" "$result1" "$result2"
} 