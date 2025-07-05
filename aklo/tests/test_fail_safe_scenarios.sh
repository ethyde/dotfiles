test_fail_safe_scenarios() {
    test_suite "Scénarios d'échec - Architecture Fail-Safe (TASK-13-8)"

    local script_dir
    script_dir="$(dirname "$0")"
    local modules_dir="${script_dir}/../modules"

    # Chargement des modules
    source "${modules_dir}/core/validation_engine.sh"
    source "${modules_dir}/core/fail_safe_loader.sh"
    source "${modules_dir}/core/progressive_loading.sh"

    # Test 1: Scénario - Module complètement manquant
    test_suite "Scénario - Module complètement manquant"
    safe_load_module "/nonexistent/path/module.sh"
    assert_command_success "Le chargement sécurisé ne doit pas échouer pour un module manquant"
    is_fallback_triggered
    assert_command_success "Le fallback doit être déclenché pour un module manquant"

    # Test 2: Scénario - Module avec erreur de syntaxe
    test_suite "Scénario - Module avec erreur de syntaxe"
    local temp_module_syntax="/tmp/syntax_error_module.sh"
    echo 'function test_func() { if [ true; then echo "Never reached"; fi }' > "$temp_module_syntax"
    safe_load_module "$temp_module_syntax"
    assert_command_success "Le chargement sécurisé ne doit pas échouer pour un module avec une erreur de syntaxe"
    rm -f "$temp_module_syntax"

    # Test 3: Scénario - Module avec permissions insuffisantes
    test_suite "Scénario - Module avec permissions insuffisantes"
    local temp_module_perms="/tmp/permission_denied_module.sh"
    echo 'function test_func() { echo "Test"; }' > "$temp_module_perms"
    chmod 000 "$temp_module_perms"
    safe_load_module "$temp_module_perms"
    assert_command_success "Le chargement sécurisé ne doit pas échouer pour un module avec des permissions insuffisantes"
    chmod 644 "$temp_module_perms"
    rm -f "$temp_module_perms"

    # Test 4: Scénario - Escalation forcée avec module manquant
    test_suite "Scénario - Escalation forcée avec module manquant"
    escalate_profile "FULL" "Test escalation with missing modules"
    assert_command_success "L'escalation ne doit pas échouer grâce au fallback"
    
    # Test 5: Scénario - Chargement progressif avec échec d'escalation
    test_suite "Scénario - Chargement progressif avec échec d'escalation"
    local original_modules_dir="$modules_dir"
    modules_dir="/nonexistent/modules"
    progressive_load_with_escalation "FULL" "$modules_dir" "test_command"
    assert_command_success "Le chargement progressif ne doit pas échouer"
    modules_dir="$original_modules_dir"

    # Test 6: Scénario - Fallback d'urgence complet
    test_suite "Scénario - Fallback d'urgence complet"
    load_profile_emergency "$modules_dir"
    assert_command_success "Le chargement d'urgence ne doit pas échouer"
} 