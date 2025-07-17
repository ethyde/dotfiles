#!/usr/bin/env bash

# Script de diagnostic pour reproduire le contexte exact du test original
# Reproduction fidèle du test_cache_helpers.sh

# Importer le framework de test Aklo
source "$(dirname "$0")/../framework/test_framework.sh"

# Importer les helpers à tester
source "$(dirname "$0")/../../modules/cache/cache_functions.sh"

echo "=== REPRODUCTION CONTEXTE ORIGINAL ==="
echo ""

# Test : generate_cache_filename
echo "=== Test generate_cache_filename ==="
test_generate_cache_filename() {
    test_suite "Helper: generate_cache_filename"
    export AKLO_PROJECT_ROOT="/tmp/aklo-test-root"
    local result
    result=$(generate_cache_filename "PROTO-TEST" "pbi")
    local expected="/tmp/aklo-test-root/.aklo_cache/PROTO-TEST_pbi.parsed"
    assert_equals "$expected" "$result" "Le nom de fichier cache généré est correct"
}

# Test : cache_is_valid avec contexte exact
echo "=== Test cache_is_valid avec contexte exact ==="
test_cache_is_valid_original() {
    test_suite "Helper: cache_is_valid"
    export AKLO_PROJECT_ROOT="/tmp/aklo-test-root"
    local temp_dir
    temp_dir=$(mktemp -d)
    local cache_file="$temp_dir/test_cache.parsed"
    local mtime_file="${cache_file}.mtime"
    local protocol_mtime="1234567890"

    echo "Temp dir: $temp_dir"
    echo "Cache file: $cache_file"
    echo "Mtime file: $mtime_file"
    echo "Protocol mtime: $protocol_mtime"
    echo ""

    # Cas 1 : fichiers absents
    echo "Cas 1 : fichiers absents"
    assert_false "cache_is_valid doit échouer si fichiers absents" "cache_is_valid \"$cache_file\" \"$protocol_mtime\""

    # Cas 2 : cache présent mais pas .mtime
    echo "Cas 2 : cache présent mais pas .mtime"
    echo "dummy" > "$cache_file"
    assert_false "cache_is_valid doit échouer si .mtime absent" "cache_is_valid \"$cache_file\" \"$protocol_mtime\""

    # Cas 3 : cache et .mtime présents mais mtime incorrect
    echo "Cas 3 : cache et .mtime présents mais mtime incorrect"
    echo "9999999999" > "$mtime_file"
    assert_false "cache_is_valid doit échouer si mtime incorrect" "cache_is_valid \"$cache_file\" \"$protocol_mtime\""

    # Cas 4 : cache et .mtime corrects
    echo "Cas 4 : cache et .mtime corrects"
    echo "ok" > "$cache_file"
    echo "$protocol_mtime" > "$mtime_file"
    echo "[DEBUG TEST] cache_file: $(cat "$cache_file" 2>/dev/null)" >&2
    echo "[DEBUG TEST] mtime_file: $(cat "$mtime_file" 2>/dev/null)" >&2
    
    # Test direct avant assert_true
    echo "Test direct avant assert_true :"
    if cache_is_valid "$cache_file" "$protocol_mtime"; then
        echo "✅ cache_is_valid direct: SUCCÈS (code 0)"
    else
        echo "❌ cache_is_valid direct: ÉCHEC (code $?)"
    fi
    
    # Test avec assert_true
    echo "Test avec assert_true :"
    assert_true "cache_is_valid \"$cache_file\" \"$protocol_mtime\"" "cache_is_valid doit réussir si cache et mtime corrects"

    rm -rf "$temp_dir"
}

# Exécution des tests
echo "=== Exécution des tests ==="
test_generate_cache_filename
test_cache_is_valid_original
test_summary 