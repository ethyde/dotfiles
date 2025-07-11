#!/usr/bin/env bash
#==============================================================================
# AKLO DOCS COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: new docs
#------------------------------------------------------------------------------
create_artefact_docs() {
    local title="$1"
    local docs_dir="${AKLO_PROJECT_ROOT}/docs/backlog/14-user-docs"
    mkdir -p "$docs_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="USER-DOCS-${next_id}-DRAFT.xml"
    local output_file="${docs_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    echo "📚 Création du plan de documentation : \"$title\""

    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Créerait le fichier de documentation : '$output_file'"
    else
        if parse_and_generate_artefact "17-USER-DOCS" "user_docs_plan" "$output_file" "$context_vars"; then
            echo "✅ Plan de documentation créé : ${output_file}"
        else
            echo "❌ La création du plan a échoué."
            return 1
        fi
    fi
    return 0
} 