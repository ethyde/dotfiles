test_extract_green() {
    test_suite "Phase GREEN - Extraction et Cache XML natif (TASK-6-2)"

    # Source des fonctions
    local script_dir
    script_dir="$(dirname "$0")"
    source "${script_dir}/../modules/io/extract_functions.sh"
    source "${script_dir}/../modules/cache/cache_functions.sh"

    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    local protocol_file="$test_dir/test_protocol.xml"
    cat > "$protocol_file" << 'EOF'
<protocol name="test_proto">
  <artefact_template>
    <pbi>
      <id>1</id>
      <title>PBI Test</title>
      <description>Exemple PBI XML</description>
    </pbi>
    <task>
      <id>2</id>
      <pbi_id>1</pbi_id>
      <title>Task Test</title>
      <description>Exemple Task XML</description>
    </task>
  </artefact_template>
</protocol>
EOF

    # Test 1: extract_artefact_xml avec pbi
    local result_pbi
    result_pbi=$(extract_artefact_xml "$protocol_file" "pbi")
    assert_contains "$result_pbi" "<pbi>" "extract_artefact_xml extrait la balise <pbi>"
    assert_contains "$result_pbi" "<title>PBI Test</title>" "Le titre du PBI doit être présent"
    assert_not_contains "$result_pbi" "{{" "Ne doit plus contenir de marqueur de variable"

    # Test 2: extract_artefact_xml avec task
    local result_task
    result_task=$(extract_artefact_xml "$protocol_file" "task")
    assert_contains "$result_task" "<task>" "extract_artefact_xml extrait la balise <task>"
    assert_contains "$result_task" "<title>Task Test</title>" "Le titre du Task doit être présent"
    assert_not_contains "$result_task" "{{" "Ne doit plus contenir de marqueur de variable"

    # Test 3: extract_artefact_xml avec type inexistant
    ! extract_artefact_xml "$protocol_file" "nonexistent" >/dev/null 2>&1
    assert_command_success "extract_artefact_xml retourne une erreur pour un type inexistant"

    # Test 4: extract_and_cache_structure complet (adapté pour XML)
    local cache_dir
    cache_dir=$(mktemp -d)
    export CACHE_DIR="$cache_dir"
    local cache_file="$cache_dir/test_cache.parsed"
    extract_and_cache_structure "$protocol_file" "pbi" "$cache_file"
    assert_command_success "extract_and_cache_structure s'exécute sans erreur"
    assert_file_exists "$cache_file" "extract_and_cache_structure crée le fichier cache"
    assert_file_exists "${cache_file}.mtime" "extract_and_cache_structure crée le fichier mtime"
    assert_file_contains "$cache_file" "<pbi>" "Le contenu du cache est correct"
    
    # Test 5: Gestion d'erreur fichier inexistant
    local nonexistent_file="$test_dir/nonexistent.xml"
    ! extract_and_cache_structure "$nonexistent_file" "pbi" "$cache_file" >/dev/null 2>&1
    assert_command_success "extract_and_cache_structure gère les fichiers inexistants"

    # Cleanup
    rm -rf "$test_dir" "$cache_dir"
    unset CACHE_DIR
} 