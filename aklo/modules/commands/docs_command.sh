#!/usr/bin/env bash
#==============================================================================
# AKLO USER DOCS COMMAND MODULE
#==============================================================================

create_artefact_docs() {
    local title="$1"
    local dir="${AKLO_PROJECT_ROOT}/docs/backlog/14-user-docs"
    mkdir -p "$dir"
    local id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)
    local file="${dir}/USERDOCS-${id}-PROPOSED.xml"
    local context="id=${id},title=${title}"
    parse_and_generate_artefact "17-USER-DOCS" "user_docs" "$file" "$context" && echo "✅ Documentation utilisateur créée: $file" || return 1
} 