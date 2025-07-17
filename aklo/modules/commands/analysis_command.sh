#!/usr/bin/env bash
#==============================================================================
# AKLO ANALYSIS COMMAND MODULE
#==============================================================================

create_artefact_analysis() {
    local title="$1"
    local analysis_dir="${AKLO_PROJECT_ROOT}/docs/backlog/10-competition"
    mkdir -p "$analysis_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="COMPETITION-${next_id}-ANALYSIS.xml"
    local output_file="${analysis_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    if parse_and_generate_artefact "12-ANALYSE-CONCURRENCE" "competition_analysis_report" "$output_file" "$context_vars"; then
        echo "✅ Analyse créée : ${output_file}"
    else
        echo "❌ La création de l'analyse a échoué." >&2
        return 1
    fi
} 