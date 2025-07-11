#!/usr/bin/env bash
#==============================================================================
# AKLO SCRATCHPAD COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: new scratchpad
#------------------------------------------------------------------------------
create_artefact_scratchpad() {
    local title="$1"
    local scratchpad_dir="${AKLO_PROJECT_ROOT}/docs/backlog/16-scratchpads"
    mkdir -p "$scratchpad_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="SCRATCHPAD-${next_id}-ACTIVE.xml"
    local output_file="${scratchpad_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    echo "✍️  Création du scratchpad : \"$title\""

    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Créerait le fichier scratchpad : '$output_file'"
    else
        if parse_and_generate_artefact "19-SCRATCHPAD" "scratchpad" "$output_file" "$context_vars"; then
            echo "✅ Scratchpad créé : ${output_file}"
        else
            echo "❌ La création du scratchpad a échoué."
            return 1
        fi
    fi
    return 0
} 