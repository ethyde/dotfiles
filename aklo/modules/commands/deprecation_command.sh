#!/usr/bin/env bash
#==============================================================================
# AKLO DEPRECATION COMMAND MODULE
#==============================================================================

create_artefact_deprecation() {
    local title="$1"
    local deprecation_dir="${AKLO_PROJECT_ROOT}/docs/backlog/15-deprecation"
    mkdir -p "$deprecation_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="DEPRECATION-${next_id}-PLANNED.xml"
    local output_file="${deprecation_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    if parse_and_generate_artefact "15-DEPRECATION" "deprecation_plan" "$output_file" "$context_vars"; then
        echo "✅ Plan de dépréciation créé : ${output_file}"
    else
        echo "❌ La création du plan de dépréciation a échoué." >&2
        return 1
    fi
} 