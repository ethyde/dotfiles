#!/usr/bin/env bash

#==============================================================================
# Test Suite pour le Parser avec Cache (Green Path) - XML natif
#
# Auteur: AI_Agent
# Version: 3.0
# Ce test valide le comportement du parser en cache avec des protocoles XML natifs.
#==============================================================================

# Sourcing robuste : utilise AKLO_PROJECT_ROOT si défini, sinon chemins relatifs
if [ -n "$AKLO_PROJECT_ROOT" ]; then
  source "$AKLO_PROJECT_ROOT/aklo/tests/test_framework.sh"
  source "$AKLO_PROJECT_ROOT/aklo/modules/parser/parser_cached.sh"
  source "$AKLO_PROJECT_ROOT/aklo/modules/io/extract_functions.sh"
else
  source "$(dirname "$0")/test_framework.sh"
  source "$(dirname "$0")/../modules/parser/parser_cached.sh"
  source "$(dirname "$0")/../modules/io/extract_functions.sh"
fi

# Mock de la fonction de filtrage intelligent pour isoler le test
apply_intelligent_filtering() {
    local content="$1"
    echo "$content"
}

#==============================================================================
# Définition des Tests
#==============================================================================

setup_test() {
    TEST_TEMP_DIR=$(mktemp -d)
    export AKLO_CACHE_DIR="${TEST_TEMP_DIR}/cache"
    export AKLO_CACHE_DEBUG=true
    mkdir -p "${AKLO_CACHE_DIR}"

    local protocol_dir="${TEST_TEMP_DIR}/protocols"
    mkdir -p "$protocol_dir"
    export AKLO_PROTOCOLS_PATH="$protocol_dir"

    cat > "${protocol_dir}/03-DEVELOPPEMENT.xml" <<'EOF'
<protocol name="03-DEVELOPPEMENT">
  <artefact_template>
    <pbi>
      <id>123</id>
      <title>PBI XML Green</title>
      <description>Test parser green XML natif</description>
    </pbi>
  </artefact_template>
</protocol>
EOF
}

teardown_test() {
    rm -rf "$TEST_TEMP_DIR"
    unset AKLO_CACHE_DIR
    unset AKLO_CACHE_DEBUG
    unset AKLO_PROTOCOLS_PATH
    unset AKLO_CACHE_ENABLED
}

test_suite "Parser avec Cache (Green Path) XML natif v3.0"

# Test 1: Cache Miss
setup_test
echo "-> Test Case: Le parser doit créer les fichiers sur un cache miss"

    output_file="${TEST_TEMP_DIR}/output.xml"
    cache_file="${AKLO_CACHE_DIR}/protocol_03-DEVELOPPEMENT_pbi.parsed"
    
    log=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "pbi" "full" "$output_file" "" 2>&1)
    exit_code=$?
    
    assert_true "[ $exit_code -eq 0 ]" "  La génération doit réussir"
    assert_file_exists "$output_file" "  Le fichier de sortie doit être créé"
    assert_file_exists "$cache_file" "  Le fichier cache doit être créé"
    assert_file_contains "$output_file" "<pbi>" "  Le fichier de sortie doit contenir la balise <pbi>"
    assert_file_contains "$output_file" "<title>PBI XML Green</title>" "  Le titre du PBI doit être présent"

teardown_test

# Test 2: Cache Hit
setup_test
echo "-> Test Case: Le parser doit utiliser le cache (HIT)"

    output_file="${TEST_TEMP_DIR}/output.xml"
    
    # Premier passage pour créer le cache
    parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "pbi" "full" "$output_file" "" >/dev/null 2>&1
    
    # Deuxième passage qui doit utiliser le cache
    log=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "pbi" "full" "$output_file" "" 2>&1)

    assert_contains "$log" "HIT" "  Le log doit indiquer un CACHE HIT"

teardown_test

# Test 3: Cache désactivé
setup_test
echo "-> Test Case: Le parser ne doit pas utiliser le cache s'il est désactivé"

    export AKLO_CACHE_ENABLED=false
    output_file="${TEST_TEMP_DIR}/output.xml"
    cache_file="${AKLO_CACHE_DIR}/protocol_03-DEVELOPPEMENT_pbi.parsed"

    log=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "pbi" "full" "$output_file" "" 2>&1)
    
    assert_file_not_exists "$cache_file" "  Le fichier cache ne doit pas être créé"
    assert_contains "$log" "DISABLED" "  Le log doit indiquer que le cache est désactivé"

teardown_test

test_summary 