test_command_classification_debug() {
    test_suite "Diagnostic Tests Classification"

    local script_dir
    script_dir="$(dirname "$0")"
    local modules_dir="${script_dir}/../modules"

    # Test 1: Apprentissage automatique
    test_suite "Apprentissage automatique"
    source "${modules_dir}/core/learning_engine.sh"
    assert_command_success "Chargement de learning_engine.sh"

    local predicted_profile
    predicted_profile=$(predict_command_profile "completely_unknown_command_xyz")
    if [[ "$predicted_profile" == "AUTO" || "$predicted_profile" == "MINIMAL" || "$predicted_profile" == "NORMAL" ]]; then
        assert_equals 0 0 "Prédiction pour commande inconnue est valide (AUTO, MINIMAL, ou NORMAL)"
    else
        fail "Profil de prédiction inattendu pour commande inconnue: '$predicted_profile'"
    fi

    # Test 2: Performance classification
    test_suite "Performance classification"
    source "${modules_dir}/core/command_classifier.sh"
    assert_command_success "Chargement de command_classifier.sh"
    
    if command -v bc >/dev/null 2>&1; then
        local start_time
        start_time=$(date +%s.%N 2>/dev/null || date +%s)
        for i in {1..10}; do
            classify_command "get_config" >/dev/null
        done
        local end_time
        end_time=$(date +%s.%N 2>/dev/null || date +%s)
        local duration
        duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "1")
        
        if (( $(echo "$duration < 0.1" | bc -l) )); then
            assert_equals 0 0 "Performance de classification OK (${duration}s)"
        else
            fail "Performance de classification trop lente: ${duration}s (limite: 0.1s)"
        fi
    else
        assert_equals 0 0 "Test de performance ignoré (bc non disponible)"
    fi

    # Test 3: Vérification des fonctions critiques
    test_suite "Vérification des fonctions critiques"
    assert_function_exists "predict_command_profile" "La fonction predict_command_profile existe"
    assert_function_exists "classify_command" "La fonction classify_command existe"

    # Test 4: Test des valeurs de retour
    test_suite "Test des valeurs de retour"
    local result_known
    result_known=$(classify_command "get_config")
    assert_not_empty "$result_known" "La classification d'une commande connue retourne une valeur"
    
    local result_unknown
    result_unknown=$(predict_command_profile "unknown_test_command")
    assert_not_empty "$result_unknown" "La prédiction pour une commande inconnue retourne une valeur"
} 