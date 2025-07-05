test_parser_cache_integration() {
    test_suite "TDD Phase RED - Intégration Cache Parser (TASK-6-3)"

    # Source des fonctions
    local script_dir
    script_dir="$(dirname "$0")"
    source "${script_dir}/../modules/cache/cache_functions.sh"
    source "${script_dir}/../modules/io/extract_functions.sh"
    # La fonction parse_and_generate_artefact est dans le script principal
    source "${script_dir}/../bin/aklo"

    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    local charte_dir="$test_dir/aklo/charte/PROTOCOLES"
    mkdir -p "$charte_dir"
    local protocol_file="$charte_dir/03-DEVELOPPEMENT.xml"
    cat > "$protocol_file" << 'EOF'
# PROTOCOLE DÉVELOPPEMENT
## Structure PBI
```markdown
# PBI-{{ID}} : {{TITLE}}
```
EOF

    # Test 1: Vérifier que la fonction parse_and_generate_artefact existe
    assert_function_exists "parse_and_generate_artefact" "La fonction parse_and_generate_artefact existe"

    # Test 2: Vérifier que le cache n'est PAS encore intégré (phase RED)
    local output_file="$test_dir/test_output.xml"
    local cache_dir
    cache_dir=$(mktemp -d)
    export CACHE_DIR="$cache_dir"
    
    # Redéfinir temporairement la fonction pour utiliser le protocole de test
    # (une meilleure solution serait d'avoir un moyen d'injecter le chemin)
    local old_charte_path="$AKLO_CHARTE_PATH"
    export AKLO_CHARTE_PATH="$test_dir/aklo/charte"

    parse_and_generate_artefact "03-DEVELOPPEMENT" "PBI" "full" "$output_file" ""
    assert_command_success "parse_and_generate_artefact fonctionne sans cache"

    local cache_file="$cache_dir/protocol_03-DEVELOPPEMENT_PBI.parsed"
    assert_file_not_exists "$cache_file" "Le cache n'est pas encore intégré (attendu en phase RED)"

    # Cleanup
    export AKLO_CHARTE_PATH="$old_charte_path"
    rm -rf "$test_dir" "$cache_dir"
    unset CACHE_DIR
} 