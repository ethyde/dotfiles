test_extract_green() {
    test_suite "Phase GREEN - Extract and Cache Functions (TASK-6-2)"

    # Source des fonctions
    local script_dir
    script_dir="$(dirname "$0")"
    source "${script_dir}/../modules/io/extract_functions.sh"
    source "${script_dir}/../modules/cache/cache_functions.sh"

    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    local protocol_file="$test_dir/test_protocol.md"
    cat > "$protocol_file" << 'EOF'
# PROTOCOLE DE TEST
## SECTION 1 - Introduction
### 2.3. Structure Obligatoire Du Fichier PBI
```markdown
# PBI-{{ID}} : {{TITLE}}
```
### 2.3. Structure Obligatoire Du Fichier Task
```markdown
# TASK-{{PBI_ID}}-{{TASK_ID}} : {{TITLE}}
```
EOF

    # Test 1: extract_artefact_structure avec PBI
    local result_pbi
    result_pbi=$(extract_artefact_structure "$protocol_file" "PBI")
    assert_contains "$result_pbi" "PBI-{{ID}} : {{TITLE}}" "extract_artefact_structure extrait la structure PBI"

    # Test 2: extract_artefact_structure avec TASK
    local result_task
    result_task=$(extract_artefact_structure "$protocol_file" "TASK")
    assert_contains "$result_task" "TASK-{{PBI_ID}}-{{TASK_ID}} : {{TITLE}}" "extract_artefact_structure extrait la structure TASK"

    # Test 3: extract_artefact_structure avec type inexistant
    ! extract_artefact_structure "$protocol_file" "NONEXISTENT" >/dev/null 2>&1
    assert_command_success "extract_artefact_structure retourne une erreur pour un type inexistant"

    # Test 4: extract_and_cache_structure complet
    local cache_dir
    cache_dir=$(mktemp -d)
    export CACHE_DIR="$cache_dir"
    local cache_file="$cache_dir/test_cache.parsed"
    extract_and_cache_structure "$protocol_file" "PBI" "$cache_file"
    assert_command_success "extract_and_cache_structure s'exécute sans erreur"
    assert_file_exists "$cache_file" "extract_and_cache_structure crée le fichier cache"
    assert_file_exists "${cache_file}.mtime" "extract_and_cache_structure crée le fichier mtime"
    assert_file_contains "$cache_file" "PBI-{{ID}} : {{TITLE}}" "Le contenu du cache est correct"
    
    # Test 5: Gestion d'erreur fichier inexistant
    local nonexistent_file="$test_dir/nonexistent.md"
    ! extract_and_cache_structure "$nonexistent_file" "PBI" "$cache_file" >/dev/null 2>&1
    assert_command_success "extract_and_cache_structure gère les fichiers inexistants"

    # Cleanup
    rm -rf "$test_dir" "$cache_dir"
    unset CACHE_DIR
} 