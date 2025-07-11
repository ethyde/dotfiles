#!/usr/bin/env bash
#==============================================================================
# AKLO META-IMPROVEMENT COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: new meta
#------------------------------------------------------------------------------
create_artefact_meta() {
    local title="$1"
    local improvements_dir="${AKLO_PROJECT_ROOT}/docs/backlog/18-improvements"
    mkdir -p "$improvements_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="IMPROVE-${next_id}-PROPOSED.xml"
    local output_file="${improvements_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    echo "🚀 Création de la proposition d'amélioration : \"$title\""

    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Créerait le fichier d'amélioration : '$output_file'"
    else
        if parse_and_generate_artefact "21-META-IMPROVEMENT" "improvement_proposal" "$output_file" "$context_vars"; then
            echo "✅ Proposition d'amélioration créée : ${output_file}"
        else
            echo "❌ La création de la proposition a échoué."
            return 1
        fi
    fi
    return 0
} 