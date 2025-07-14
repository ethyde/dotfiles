#!/usr/bin/env bash
#==============================================================================
# AKLO EXPERIMENT COMMAND MODULE
#==============================================================================

create_artefact_experiment() {
    local title="$1"
    local dir="${AKLO_PROJECT_ROOT}/docs/backlog/11-experimentation"
    mkdir -p "$dir"
    local id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)
    local file="${dir}/EXPERIMENT-${id}-PROPOSED.xml"
    local context="id=${id},title=${title}"
    parse_and_generate_artefact "11-EXPERIMENTATION" "experiment" "$file" "$context" && echo "✅ Expérimentation créée: $file" || return 1
} 