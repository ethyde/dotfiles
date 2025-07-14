#!/usr/bin/env bash
#==============================================================================
# AKLO SCRATCHPAD COMMAND MODULE
#==============================================================================

create_artefact_scratchpad() {
    local title="$1"
    local dir="${AKLO_PROJECT_ROOT}/docs/backlog/19-scratchpad"
    mkdir -p "$dir"
    local id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)
    local file="${dir}/SCRATCHPAD-${id}-ACTIVE.xml"
    local context="id=${id},title=${title}"
    parse_and_generate_artefact "19-SCRATCHPAD" "scratchpad" "$file" "$context" && echo "✅ Scratchpad créé: $file" || return 1
} 