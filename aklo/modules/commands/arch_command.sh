#!/usr/bin/env bash
#==============================================================================
# AKLO ARCHITECTURE COMMAND MODULE
#==============================================================================

create_artefact_arch() {
    local title="$1"
    local arch_dir="${AKLO_PROJECT_ROOT}/docs/backlog/02-architecture"
    mkdir -p "$arch_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="ARCH-${next_id}-DRAFT.xml"
    local output_file="${arch_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    if parse_and_generate_artefact "02-ARCHITECTURE" "architecture_document" "$output_file" "$context_vars"; then
        echo "✅ Architecture créée : ${output_file}"
    else
        echo "❌ La création de l'architecture a échoué." >&2
        return 1
    fi
} 