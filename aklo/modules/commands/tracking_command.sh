#!/usr/bin/env bash
#==============================================================================
# AKLO TRACKING COMMAND MODULE
#==============================================================================

create_artefact_tracking() {
    local title="$1"
    local tracking_dir="${AKLO_PROJECT_ROOT}/docs/backlog/16-tracking"
    mkdir -p "$tracking_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="TRACKING-${next_id}-ACTIVE.xml"
    local output_file="${tracking_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    if parse_and_generate_artefact "16-TRACKING-PLAN" "tracking_plan" "$output_file" "$context_vars"; then
        echo "✅ Plan de tracking créé : ${output_file}"
    else
        echo "❌ La création du plan de tracking a échoué." >&2
        return 1
    fi
} 