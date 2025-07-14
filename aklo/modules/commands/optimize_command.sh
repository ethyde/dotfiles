#!/usr/bin/env bash
#==============================================================================
# AKLO OPTIMIZE COMMAND MODULE
#==============================================================================

create_artefact_optimize() {
    local title="$1"
    local optim_dir="${AKLO_PROJECT_ROOT}/docs/backlog/06-optim"
    mkdir -p "$optim_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="OPTIM-${next_id}-BENCHMARKING.xml"
    local output_file="${optim_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    if parse_and_generate_artefact "06-OPTIMISATION" "optimization_report" "$output_file" "$context_vars"; then
        echo "✅ Plan d'optimisation créé : ${output_file}"
    else
        echo "❌ La création du plan a échoué." >&2; return 1;
    fi
} 