test_integration_task_13_1_and_13_8() {
    test_suite "Test d'intégration TASK-13-1 et TASK-13-8"

    # Chargement des modules
    local script_dir
    script_dir="$(dirname "$0")"
    local modules_dir="${script_dir}/../modules"
    source "${modules_dir}/core/validation_engine.sh"
    source "${modules_dir}/core/fail_safe_loader.sh"
    source "${modules_dir}/core/progressive_loading.sh"
    source "${modules_dir}/core/command_classifier.sh"
    source "${modules_dir}/core/learning_engine.sh"
    
    # Test 1: Classification avec chargement progressif
    test_suite "Classification avec chargement progressif"
    local test_commands=("get_config" "plan" "optimize")
    for cmd in "${test_commands[@]}"; do
        local profile
        profile=$(classify_command "$cmd")
        assert_not_empty "$profile" "La classification pour '$cmd' retourne un profil"
        
        local modules
        modules=$(get_required_modules "$profile")
        assert_not_empty "$modules" "Les modules requis pour le profil '$profile' sont définis"
    done

    # Test 2: Apprentissage avec fail-safe
    test_suite "Apprentissage avec fail-safe"
    local new_command="integration_test_command_2"
    local target_profile="NORMAL"
    learn_command_pattern "$new_command" "$target_profile" "integration_test"
    local learned_profile
    learned_profile=$(predict_command_profile "$new_command")
    assert_equals "$target_profile" "$learned_profile" "L'apprentissage avec fail-safe fonctionne"

    # Test 3: Gestion des erreurs et fallback
    test_suite "Gestion des erreurs et fallback"
    local problematic_command="@#\$%invalid_command_2"
    local fallback_profile
    fallback_profile=$(classify_command "$problematic_command" 2>/dev/null || echo "AUTO")
    assert_equals "AUTO" "$fallback_profile" "La classification d'une commande invalide retourne 'AUTO'"
    
    # Test 4: Cohérence globale
    test_suite "Cohérence globale"
    local functions_to_check=(
        "classify_command" "get_required_modules" "learn_command_pattern"
        "predict_command_profile" "validate_module_integrity" "load_modules_progressive"
    )
    for func in "${functions_to_check[@]}"; do
        assert_function_exists "$func" "La fonction critique '$func' est disponible"
    done
} 