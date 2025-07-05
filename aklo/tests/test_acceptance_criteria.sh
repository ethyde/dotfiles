test_acceptance_criteria() {
    test_suite "Critères d'Acceptation TASK-13-1"

    local script_dir
    script_dir="$(dirname "$0")"
    local modules_dir="${script_dir}/../modules"

    # Critère 1: Classification automatique des commandes
    test_suite "Critère 1: Classification automatique"
    source "${modules_dir}/core/command_classifier.sh"
    assert_command_success "Chargement de command_classifier.sh"
    
    local commands_minimal=("get_config" "status" "version" "help")
    for cmd in "${commands_minimal[@]}"; do
        result=$(classify_command "$cmd")
        assert_equals "MINIMAL" "$result" "Commande '$cmd' classifiée MINIMAL"
    done

    local commands_normal=("plan" "dev" "debug" "review")
    for cmd in "${commands_normal[@]}"; do
        result=$(classify_command "$cmd")
        assert_equals "NORMAL" "$result" "Commande '$cmd' classifiée NORMAL"
    done

    local commands_full=("optimize" "benchmark" "cache" "monitor")
    for cmd in "${commands_full[@]}"; do
        result=$(classify_command "$cmd")
        assert_equals "FULL" "$result" "Commande '$cmd' classifiée FULL"
    done

    # Critère 2: Apprentissage automatique
    test_suite "Critère 2: Apprentissage automatique"
    source "${modules_dir}/core/learning_engine.sh"
    assert_command_success "Chargement de learning_engine.sh"
    learn_command_pattern "test_new_command" "NORMAL" "test_acceptance"
    result=$(predict_command_profile "test_new_command")
    assert_equals "NORMAL" "$result" "Apprentissage de 'test_new_command' en NORMAL"

    # Critère 3: Prédiction pour commandes inconnues
    test_suite "Critère 3: Prédiction pour commandes inconnues"
    local unknown_commands=("unknown_get_info" "unknown_build_project" "unknown_optimize_cache")

    for cmd in "${unknown_commands[@]}"; do
        result=$(predict_command_profile "$cmd")
        assert_not_empty "$result" "Prédiction pour commande inconnue '$cmd' non vide"
    done

    # Critère 4: Détection depuis arguments CLI
    test_suite "Critère 4: Détection depuis arguments CLI"
    assert_equals "get_config" "$(detect_command_from_args "get_config --verbose")" "Détection depuis 'get_config --verbose'"
    assert_equals "plan" "$(detect_command_from_args "plan new-feature")" "Détection depuis 'plan new-feature'"
    assert_equals "debug" "$(detect_command_from_args "debug --trace")" "Détection depuis 'debug --trace'"

    # Critère 5: Gestion des modules requis
    test_suite "Critère 5: Modules requis par profil"
    local profiles=("MINIMAL" "NORMAL" "FULL" "AUTO")

    for profile in "${profiles[@]}"; do
        modules=$(get_required_modules "$profile")
        assert_not_empty "$modules" "Modules requis pour le profil '$profile' non vide"
    done

    # Critère 6: Performance et cache (vérification conceptuelle)
    test_suite "Critère 6: Performance et cache"
    # Premier appel (mise en cache)
    classify_command "performance_test_accept" >/dev/null
    # Appels suivants (depuis cache)
    classify_command "performance_test_accept" >/dev/null
    assert_command_success "Exécution des tests de performance du cache"

    # Critère 7: Statistiques et monitoring
    test_suite "Critère 7: Statistiques"
    stats=$(get_command_profile_stats)
    assert_not_empty "$stats" "Les statistiques de classification ne sont pas vides"
    stats_learning=$(get_learning_stats)
    assert_not_empty "$stats_learning" "Les statistiques d'apprentissage ne sont pas vides"

    # Critère 8: Validation et cohérence
    test_suite "Critère 8: Validation et cohérence"
    validate_classification_consistency >/dev/null 2>&1
    assert_command_success "Validation de la cohérence des classifications"
}