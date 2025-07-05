test_extract_simple() {
    test_suite "Tests simples - Extract and Cache (TASK-6-2)"

    # Source des fonctions en utilisant le chemin absolu du projet
    source "${AKLO_PROJECT_ROOT}/modules/io/extract_functions.sh"
    source "${AKLO_PROJECT_ROOT}/modules/cache/cache_functions.sh"

    # Setup avec nettoyage automatique via trap
    local test_dir
    test_dir=$(mktemp -d)
    local cache_dir
    cache_dir=$(mktemp -d)
    trap 'rm -rf "$test_dir" "$cache_dir"; unset CACHE_DIR; trap - EXIT' EXIT

    export CACHE_DIR="$cache_dir"
    local protocol_file="$test_dir/test_protocol.md"
    cat > "$protocol_file" << 'EOF'
# PROTOCOLE DE TEST
### 2.3. Structure Obligatoire Du Fichier PBI
```markdown
# PBI-{{ID}} : {{TITLE}}
## 1. Description
{{DESCRIPTION}}
```
EOF

    # Test 1: extract_artefact_structure
    local result_pbi
    result_pbi=$(extract_artefact_structure "$protocol_file" "PBI")
    assert_contains "$result_pbi" "PBI-{{ID}} : {{TITLE}}" "extract_artefact_structure extrait la structure PBI"

    # Test 2: extract_and_cache_structure
    local cache_file="$cache_dir/test.parsed"
    extract_and_cache_structure "$protocol_file" "PBI" "$cache_file"
    assert_command_success "extract_and_cache_structure s'exécute sans erreur"
    assert_file_exists "$cache_file" "extract_and_cache_structure crée le fichier cache"

    # Test 3: Validation cache
    local protocol_mtime
    protocol_mtime=$(get_file_mtime "$protocol_file")
    cache_is_valid "$cache_file" "$protocol_mtime"
    assert_command_success "Le cache est considéré comme valide"

    # Le nettoyage est maintenant géré par trap
} 