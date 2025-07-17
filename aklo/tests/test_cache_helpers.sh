#!/usr/bin/env bash

# Tests unitaires pour les helpers de cache centralisés (TDD strict)
# Ce fichier regroupe les tests des fonctions utilitaires de cache_functions.sh

# Importer le framework de test Aklo (pour test_suite, assert_equals, etc.)
source "$(dirname "$0")/framework/test_framework.sh"

# Importer les helpers à tester
source "$(dirname "$0")/../modules/cache/cache_functions.sh"

# Test : generate_cache_filename

test_generate_cache_filename() {
    test_suite "Helper: generate_cache_filename"
    export AKLO_PROJECT_ROOT="/tmp/aklo-test-root"
    local result
    result=$(generate_cache_filename "PROTO-TEST" "pbi")
    local expected="/tmp/aklo-test-root/.aklo_cache/PROTO-TEST_pbi.parsed"
    assert_equals "$expected" "$result" "Le nom de fichier cache généré est correct"
}

# Test : cache_is_valid

test_cache_is_valid() {
    test_suite "Helper: cache_is_valid"
    export AKLO_PROJECT_ROOT="/tmp/aklo-test-root"
    local temp_dir
    temp_dir=$(mktemp -d)
    local cache_file="$temp_dir/test_cache.parsed"
    local mtime_file="${cache_file}.mtime"
    local protocol_mtime="1234567890"

    # Cas 1 : fichiers absents
    assert_false "cache_is_valid doit échouer si fichiers absents" "cache_is_valid \"$cache_file\" \"$protocol_mtime\""

    # Cas 2 : cache présent mais pas .mtime
    echo "dummy" > "$cache_file"
    assert_false "cache_is_valid doit échouer si .mtime absent" "cache_is_valid \"$cache_file\" \"$protocol_mtime\""

    # Cas 3 : cache et .mtime présents mais mtime incorrect
    echo "9999999999" > "$mtime_file"
    assert_false "cache_is_valid doit échouer si mtime incorrect" "cache_is_valid \"$cache_file\" \"$protocol_mtime\""

    # Cas 4 : cache et .mtime corrects
    echo "ok" > "$cache_file"
    echo "$protocol_mtime" > "$mtime_file"
    echo "[DEBUG TEST] cache_file: $(cat "$cache_file" 2>/dev/null)" >&2
    echo "[DEBUG TEST] mtime_file: $(cat "$mtime_file" 2>/dev/null)" >&2
    assert_true "cache_is_valid \"$cache_file\" \"$protocol_mtime\"" "cache_is_valid doit réussir si cache et mtime corrects"

    rm -rf "$temp_dir"
}

# Test : init_cache_dir

test_init_cache_dir() {
    (
        test_suite "Helper: init_cache_dir"
        export AKLO_PROJECT_ROOT="/tmp/aklo-test-root"
        local temp_dir
        temp_dir=$(mktemp -d)
        local test_cache_dir="$temp_dir/.aklo_cache"
        
        # Cas 1 : répertoire n'existe pas, doit être créé
        assert_false "Le répertoire cache ne doit pas exister initialement" "[ -d \"$test_cache_dir\" ]"
        
        # Simuler get_config pour retourner le chemin de test
        get_config() {
            echo "$test_cache_dir"
        }
        export -f get_config
        source "$(dirname "$0")/../modules/cache/cache_functions.sh"
        
        init_cache_dir
        assert_true "Le répertoire cache doit être créé" "[ -d \"$test_cache_dir\" ]"
        
        # Cas 2 : répertoire existe déjà, ne doit pas échouer
        init_cache_dir
        assert_true "Le répertoire cache doit toujours exister" "[ -d \"$test_cache_dir\" ]"
        
        # Cas 3 : mode DRY_RUN, ne doit pas créer le répertoire
        export AKLO_DRY_RUN=true
        local dry_run_dir="$temp_dir/.aklo_cache_dry_run"
        get_config() {
            echo "$dry_run_dir"
        }
        export -f get_config
        source "$(dirname "$0")/../modules/cache/cache_functions.sh"
        
        init_cache_dir
        assert_false "Le répertoire ne doit pas être créé en mode DRY_RUN" "[ -d \"$dry_run_dir\" ]"
        
        rm -rf "$temp_dir"
    )
}

# Test : use_cached_structure

test_use_cached_structure() {
    test_suite "Helper: use_cached_structure"
    local temp_dir
    temp_dir=$(mktemp -d)
    local cache_file="$temp_dir/test_structure.parsed"
    local test_content="<test>content</test>"
    
    # Cas 1 : fichier cache existe, doit retourner son contenu
    echo "$test_content" > "$cache_file"
    local result
    result=$(use_cached_structure "$cache_file")
    assert_equals "$test_content" "$result" "use_cached_structure doit retourner le contenu du fichier cache"
    
    # Cas 2 : fichier cache n'existe pas, doit échouer silencieusement
    result=$(use_cached_structure "$temp_dir/nonexistent.parsed" 2>/dev/null || echo "error")
    assert_equals "error" "$result" "use_cached_structure doit échouer si le fichier n'existe pas"
    
    rm -rf "$temp_dir"
}

# Test : get_file_mtime

test_get_file_mtime() {
    test_suite "Helper: get_file_mtime"
    local temp_dir
    temp_dir=$(mktemp -d)
    local test_file="$temp_dir/test_file.txt"
    
    # Cas 1 : fichier existe, doit retourner le mtime
    echo "test content" > "$test_file"
    local mtime
    mtime=$(get_file_mtime "$test_file")
    assert_not_empty "$mtime" "get_file_mtime doit retourner un mtime pour un fichier existant"
    
    # Cas 2 : fichier n'existe pas, doit échouer
    if get_file_mtime "$temp_dir/nonexistent.txt" 2>/dev/null; then
        fail "get_file_mtime doit échouer pour un fichier inexistant"
    else
        echo "✓ get_file_mtime échoue correctement pour un fichier inexistant"
    fi
    
    rm -rf "$temp_dir"
}

main() {
    test_generate_cache_filename
    test_cache_is_valid
    test_init_cache_dir
    test_use_cached_structure
    test_get_file_mtime
    test_summary
}

main 