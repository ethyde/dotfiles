#!/bin/bash

# Tests pour les fonctions d'optimisation I/O par batch
# TASK-7-2: Test-Driven Development pour optimisations I/O

test_batch_io() {
    test_suite "Optimisations I/O par batch (TASK-7-2)"

    # Source des fonctions à tester
    local script_dir
    script_dir="$(dirname "$0")"
    source "${script_dir}/../modules/cache/cache_functions.sh"
    source "${script_dir}/../modules/cache/batch_io.sh"

    # Existence des fonctions
    assert_function_exists "batch_read_files" "La fonction batch_read_files existe"
    assert_function_exists "batch_check_existence" "La fonction batch_check_existence existe"
    assert_function_exists "batch_file_operations" "La fonction batch_file_operations existe"

    # Setup des fichiers de test temporaires
    local test_dir
    test_dir=$(mktemp -d)
    echo "content1" > "$test_dir/file1.txt"
    echo "content2" > "$test_dir/file2.txt"
    echo "content3" > "$test_dir/file3.txt"


    # Test de batch_read_files
    if command -v batch_read_files >/dev/null 2>&1; then
        local result
        result=$(batch_read_files "$test_dir/file1.txt" "$test_dir/file2.txt" "$test_dir/file3.txt" 2>/dev/null)
        assert_contains "$result" "content1" "batch_read_files lit le contenu du fichier 1"
        assert_contains "$result" "content2" "batch_read_files lit le contenu du fichier 2"
        assert_contains "$result" "content3" "batch_read_files lit le contenu du fichier 3"
    else
        fail "Fonction batch_read_files non implémentée"
    fi

    # Test de batch_check_existence
    if command -v batch_check_existence >/dev/null 2>&1; then
        local result_check
        result_check=$(batch_check_existence "$test_dir/file1.txt" "$test_dir/nonexistent.txt" "$test_dir/file2.txt" 2>/dev/null)
        assert_contains "$result_check" "file1.txt" "batch_check_existence trouve file1.txt"
        assert_contains "$result_check" "file2.txt" "batch_check_existence trouve file2.txt"
    else
        fail "Fonction batch_check_existence non implémentée"
    fi

    # Test des métriques
    if command -v get_io_metrics >/dev/null 2>&1; then
        metrics_result=$(get_io_metrics 2>/dev/null)
        echo "$metrics_result" | grep -E "syscalls|operations|performance" > /dev/null
        assert_command_success "Les métriques de performance contiennent les mots-clés attendus (Reçu: '$metrics_result')"
    else
        fail "Fonction get_io_metrics non implémentée"
    fi

    # Cleanup
    rm -rf "$test_dir"
}