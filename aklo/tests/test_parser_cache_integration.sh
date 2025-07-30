test_parser_cache_integration() {
    test_suite "TDD Phase GREEN - Intégration Cache Parser XML natif (TASK-6-3)"

    # Sauvegarder le répertoire original
    local ORIGINAL_PWD
    ORIGINAL_PWD=$(pwd)

    # Source des fonctions
    local script_dir
    script_dir="$(dirname "$0")"
    source "${script_dir}/../modules/cache/cache_functions.sh"
    source "${script_dir}/../modules/io/extract_functions.sh"
    source "${script_dir}/../modules/parser/parser_cached.sh"

    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    cd "$test_dir" || exit 1
    export AKLO_CACHE_DIR="$test_dir/cache"
    export AKLO_CACHE_DEBUG=true
    mkdir -p "$AKLO_CACHE_DIR"
    local protocol_dir="$test_dir/protocols"
    mkdir -p "$protocol_dir"
    export AKLO_PROTOCOLS_PATH="$protocol_dir"
    local protocol_file="$protocol_dir/03-DEVELOPPEMENT.xml"
    cat > "$protocol_file" << 'EOF'
<protocol name="03-DEVELOPPEMENT">
  <artefact_template>
    <pbi>
      <id>321</id>
      <title>PBI XML Integration</title>
      <description>Test parser cache integration XML natif</description>
    </pbi>
  </artefact_template>
</protocol>
EOF

    # Test 1: Génération et cache miss
    local output_file="$test_dir/output.xml"
    local cache_file="$AKLO_CACHE_DIR/protocol_03-DEVELOPPEMENT_pbi.parsed"
    log=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "pbi" "full" "$output_file" "" 2>&1)
    assert_true "[ -f '$output_file' ]" "Le fichier de sortie XML doit être créé (miss)"
    assert_true "[ -f '$cache_file' ]" "Le fichier cache doit être créé (miss)"
    assert_contains "$log" "MISS" "Le log doit indiquer un cache MISS (miss)"
    assert_file_contains "$output_file" "<pbi>" "Le fichier XML doit contenir la balise <pbi> (miss)"

    # Test 2: Cache hit
    log2=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "pbi" "full" "$output_file" "" 2>&1)
    assert_contains "$log2" "HIT" "Le log doit indiquer un cache HIT (hit)"
    assert_file_contains "$output_file" "<title>PBI XML Integration</title>" "Le titre du PBI doit être présent (hit)"

    # Test 3: Cache désactivé
    export AKLO_CACHE_ENABLED=false
    log3=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "pbi" "full" "$output_file" "" 2>&1)
    assert_contains "$log3" "DISABLED" "Le log doit indiquer que le cache est désactivé (disabled)"
    assert_file_contains "$output_file" "<pbi>" "Le fichier XML doit contenir la balise <pbi> (disabled)"
    assert_file_not_exists "$cache_file" "Le fichier cache ne doit pas être créé si le cache est désactivé (disabled)"

    # Test 4: Injection dynamique de <status>
    local protocol_file_status="$protocol_dir/03-STATUS.xml"
    cat > "$protocol_file_status" << 'EOF'
<protocol name="03-STATUS">
  <artefact_template>
    <pbi>
      <id>322</id>
      <title>PBI Status Injection</title>
      <description>Test injection dynamique de la balise status</description>
      <!-- Pas de balise <status> dans le template -->
    </pbi>
  </artefact_template>
</protocol>
EOF
    local output_file_status="$test_dir/output_status.xml"
    log_status=$(parse_and_generate_artefact_cached "03-STATUS" "pbi" "full" "$output_file_status" "" 2>&1)
    assert_file_contains "$output_file_status" "<status>" "Le fichier XML doit contenir la balise <status> injectée dynamiquement (status)"

    # Cleanup
    cd "$ORIGINAL_PWD" || cd /tmp
    rm -rf "$test_dir"
    unset AKLO_CACHE_DIR
    unset AKLO_CACHE_DEBUG
    unset AKLO_PROTOCOLS_PATH
    unset AKLO_CACHE_ENABLED
} 