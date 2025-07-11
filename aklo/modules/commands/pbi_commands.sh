#!/usr/bin/env bash
#==============================================================================
# AKLO PBI COMMANDS MODULE - FINAL
#==============================================================================

cmd_propose-pbi() {
    local title="$1"
    [ -z "$title" ] && echo "Erreur: Titre manquant." >&2 && return 1
    
    echo "🎯 Création du PBI: \"$title\""

    local pbi_dir="${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi"
    mkdir -p "$pbi_dir"

    local next_id
    next_id=$(get_next_id "$pbi_dir" "PBI-")
    
    local sanitized_title=$(echo "$title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
    local filename="PBI-${next_id}-${sanitized_title}-PROPOSED.xml"
    local output_file="${pbi_dir}/${filename}"
    
    local context_vars="id=${next_id},title=${title}"

    if parse_and_generate_artefact "00-PRODUCT-OWNER" "pbi" "$output_file" "$context_vars"; then
        echo "✅ PBI créé : ${output_file}"
        echo "--- Contenu ---"
        cat "${output_file}"
        echo "---------------"
    else
        echo "❌ La création du fichier PBI a échoué."
        return 1
    fi
} 