test_id_performance() {
    test_suite "Tests de performance pour le cache des IDs (TASK-7-3)"

    # Source des fonctions
    local script_dir
    script_dir="$(dirname "$0")"
    source "${script_dir}/../modules/cache/cache_functions.sh"
    source "${script_dir}/../modules/cache/id_cache.sh"

    # Setup
    local test_dir
    test_dir=$(mktemp -d)
    local num_artefacts=100
    for i in $(seq 1 $num_artefacts); do
        touch "$test_dir/PBI-$i-DONE.md"
        touch "$test_dir/TASK-$i-TODO.md"
        touch "$test_dir/DEBUG-$i-INVESTIGATING.md"
    done

    # Fonction get_next_id originale pour comparaison
    get_next_id_original() {
        local search_path="$1"
        local prefix="$2"
        local last_id
        last_id=$(ls "${search_path}/${prefix}"*-*.md 2>/dev/null | sed -n "s/.*${prefix}-\([0-9]*\)-.*/\1/p" | sort -n | tail -1)
        if [ -z "$last_id" ]; then
            last_id=0
        fi
        local next_id=$((last_id + 1))
        echo "$next_id"
    }

    # Test de performance: get_next_id original vs cached
    test_suite "Performance: get_next_id original vs cached"
    local prefixes=("PBI" "TASK" "DEBUG")
    local num_calls=5
    
    for prefix in "${prefixes[@]}"; do
        local start_time_orig
        start_time_orig=$(date +%s%N)
        for i in $(seq 1 $num_calls); do get_next_id_original "$test_dir" "$prefix" >/dev/null; done
        local end_time_orig
        end_time_orig=$(date +%s%N)
        local duration_orig
        duration_orig=$(( (end_time_orig - start_time_orig) ))

        reset_id_cache_metrics
        local start_time_cached
        start_time_cached=$(date +%s%N)
        for i in $(seq 1 $num_calls); do get_next_id_cached "$test_dir" "$prefix" >/dev/null; done
        local end_time_cached
        end_time_cached=$(date +%s%N)
        local duration_cached
        duration_cached=$(( (end_time_cached - start_time_cached) ))

        if [ "$duration_cached" -le "$duration_orig" ]; then
            assert_equals 0 0 "Le cache améliore (ou maintient) les performances pour $prefix"
        else
            fail "Le cache a ralenti l'exécution pour $prefix (sans cache: ${duration_orig}ns, avec cache: ${duration_cached}ns)"
        fi
    done

    # Test de scalabilité
    test_suite "Scalabilité"
    local sizes=(10 50)
    for size in "${sizes[@]}"; do
        local scale_test_dir
        scale_test_dir=$(mktemp -d)
        for i in $(seq 1 $size); do touch "$scale_test_dir/PBI-$i-DONE.md"; done
        
        local start_time_orig_scale
        start_time_orig_scale=$(date +%s%N)
        get_next_id_original "$scale_test_dir" "PBI" >/dev/null
        local end_time_orig_scale
        end_time_orig_scale=$(date +%s%N)
        local duration_orig_scale
        duration_orig_scale=$(( (end_time_orig_scale - start_time_orig_scale) ))

        local start_time_cached_scale
        start_time_cached_scale=$(date +%s%N)
        get_next_id_cached "$scale_test_dir" "PBI" >/dev/null
        local end_time_cached_scale
        end_time_cached_scale=$(date +%s%N)
        local duration_cached_scale
        duration_cached_scale=$(( (end_time_cached_scale - start_time_cached_scale) ))

        if [ "$duration_cached_scale" -le "$duration_orig_scale" ]; then
            assert_equals 0 0 "Le cache est scalable pour une taille de $size"
        else
            fail "Le cache n'est pas scalable pour une taille de $size (sans cache: ${duration_orig_scale}ns, avec cache: ${duration_cached_scale}ns)"
        fi
        rm -rf "$scale_test_dir"
    done

    # Cleanup
    rm -rf "$test_dir"
} 