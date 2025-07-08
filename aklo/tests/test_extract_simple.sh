test_extract_simple() {
    test_suite "Tests simples - Extraction et Cache XML natif"

    # Source des fonctions (à adapter si besoin)
    source "${AKLO_PROJECT_ROOT}/modules/io/extract_functions.sh"
    source "${AKLO_PROJECT_ROOT}/modules/cache/cache_functions.sh"

    # Setup avec nettoyage automatique via trap
    local test_dir
    test_dir=$(mktemp -d)
    local cache_dir
    cache_dir=$(mktemp -d)
    trap 'rm -rf "$test_dir" "$cache_dir"; unset CACHE_DIR; trap - EXIT' EXIT

    export CACHE_DIR="$cache_dir"
    local protocol_file="$test_dir/test_protocol.xml"
    cat > "$protocol_file" << 'EOF'
<protocol name="test_proto">
  <artefact_template>
    <pbi>
      <id>42</id>
      <title>Test PBI</title>
      <description>Exemple de PBI en XML natif</description>
    </pbi>
  </artefact_template>
</protocol>
EOF

    # Test 1: extract_artefact_xml (nouvelle fonction à implémenter)
    local result_pbi
    result_pbi=$(extract_artefact_xml "$protocol_file" "pbi")
    assert_contains "$result_pbi" "<pbi>" "extract_artefact_xml extrait la balise <pbi>"
    assert_contains "$result_pbi" "<title>Test PBI</title>" "Le titre doit être présent"
    assert_not_contains "$result_pbi" "{{" "Ne doit plus contenir de marqueur de variable"

    # Test 2: extract_and_cache_structure (adapté pour XML)
    local cache_file="$cache_dir/test.parsed"
    extract_and_cache_structure "$protocol_file" "pbi" "$cache_file"
    assert_command_success "extract_and_cache_structure s'exécute sans erreur"
    assert_file_exists "$cache_file" "extract_and_cache_structure crée le fichier cache"

    # Test 3: Validation cache
    local protocol_mtime
    protocol_mtime=$(get_file_mtime "$protocol_file")
    cache_is_valid "$cache_file" "$protocol_mtime"
    assert_command_success "Le cache est considéré comme valide"

    # Le nettoyage est maintenant géré par trap
} 