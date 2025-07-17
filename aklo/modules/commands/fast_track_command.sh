#!/usr/bin/env bash
#==============================================================================
# AKLO FAST-TRACK COMMAND MODULE
#==============================================================================

create_artefact_fast() {
    local title="$1"
    local fast_track_dir="${AKLO_PROJECT_ROOT}/docs/backlog/17-fast-track"
    mkdir -p "$fast_track_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="FAST-${next_id}-TODO.xml"
    local output_file="${fast_track_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    if parse_and_generate_artefact "20-FAST-TRACK" "fast_track_report" "$output_file" "$context_vars"; then
        echo "✅ Fast-track créé : ${output_file}"
        echo "   💡 Rappel: Utilisez fast-track uniquement pour des modifications mineures et à faible risque."
    else
        echo "❌ La création du fast-track a échoué." >&2
        return 1
    fi
} 