#!/usr/bin/env bash
#==============================================================================
# AKLO META-IMPROVEMENT COMMAND MODULE
#==============================================================================

create_artefact_meta() {
    local title="$1"
    local dir="${AKLO_PROJECT_ROOT}/docs/backlog/18-improvements"
    mkdir -p "$dir"
    local id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)
    local file="${dir}/IMPROVE-${id}-PROPOSED.xml"
    local context="id=${id},title=${title}"
    parse_and_generate_artefact "21-META-IMPROVEMENT" "improvement_proposal" "$file" "$context" && echo "✅ Proposition créée: $file" || return 1
} 