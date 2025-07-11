#!/usr/bin/env bash
#==============================================================================
# AKLO REFACTOR COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: new refactor
#------------------------------------------------------------------------------
create_artefact_refactor() {
    local title="$1"
    local refactor_dir="${AKLO_PROJECT_ROOT}/docs/backlog/05-refactor"
    mkdir -p "$refactor_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="REFACTOR-${next_id}-ANALYSIS.xml"
    local output_file="${refactor_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    echo "🔨 Création du plan de refactoring : \"$title\""

    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Créerait le fichier de refactoring : '$output_file'"
    else
        if parse_and_generate_artefact "05-REFACTORING" "refactor_report" "$output_file" "$context_vars"; then
            echo "✅ Plan de refactoring créé : ${output_file}"
        else
            echo "❌ La création du plan a échoué."
            return 1
        fi
    fi
    return 0
} 