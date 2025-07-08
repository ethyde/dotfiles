test_cache_green_simple() {
    test_suite "Phase GREEN - Infrastructure Cache simple (TASK-6-1)"

    # Source des fonctions
    local script_dir
    script_dir="$(dirname "$0")"
    source "${script_dir}/../modules/cache/cache_functions.sh"

    # Setup
    local test_dir
    local cache_dir
    test_dir=$(mktemp -d)
    cache_dir=$(mktemp -d)
    export CACHE_DIR="$cache_dir"

    # Test 1: cache_is_valid avec cache valide
    local cache_file="$test_dir/test.parsed"
    local mtime_file="${cache_file}.mtime"
    echo "content" > "$cache_file"
    echo "1234567890" > "$mtime_file"
    cache_is_valid "$cache_file" "1234567890"
    assert_command_success "cache_is_valid fonctionne avec un cache valide"

    # Test 2: cache_is_valid avec mtime invalide
    echo "1111111111" > "$mtime_file"
    ! cache_is_valid "$cache_file" "1234567890"
    assert_command_success "cache_is_valid échoue correctement avec un mtime invalide"

    # Test 3: use_cached_structure
    local expected="test_content"
    echo "$expected" > "$cache_file"
    local result
    result=$(use_cached_structure "$cache_file")
    assert_equals "$expected" "$result" "use_cached_structure retourne le bon contenu"

    # Test 4: cleanup_cache
    cleanup_cache
    assert_command_success "cleanup_cache s'exécute sans erreur"

    # Cleanup
    rm -rf "$test_dir" "$cache_dir"
    unset CACHE_DIR
} 