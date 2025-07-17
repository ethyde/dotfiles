#!/usr/bin/env bash
#==============================================================================
# AKLO REVIEW COMMAND MODULE
#==============================================================================

create_artefact_review() {
    local title="$1"
    local review_dir="${AKLO_PROJECT_ROOT}/docs/backlog/03-reviews"
    mkdir -p "$review_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="REVIEW-${next_id}-PENDING.xml"
    local output_file="${review_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    if parse_and_generate_artefact "07-REVUE-DE-CODE" "code_review_report" "$output_file" "$context_vars"; then
        echo "✅ Revue de code créée : ${output_file}"
    else
        echo "❌ La création de la revue a échoué." >&2
        return 1
    fi
} 