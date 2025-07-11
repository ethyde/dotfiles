#!/usr/bin/env bash
#==============================================================================
# AKLO DEBUG COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: new debug
# Est appelée par le dispatcher `cmd_new`
#------------------------------------------------------------------------------
create_artefact_debug() {
    local title="$1"
    local debug_dir="${AKLO_PROJECT_ROOT}/docs/backlog/04-debug"
    mkdir -p "$debug_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)
    
    local filename="DEBUG-${next_id}-INVESTIGATING.xml"
    local output_file="${debug_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    echo "🐛 Création du rapport de débogage : \"$title\""

    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Créerait le fichier de débogage : '$output_file'"
    else
        if parse_and_generate_artefact "04-DEBOGAGE" "debug_report" "$output_file" "$context_vars"; then
            echo "✅ Rapport de débogage créé : ${output_file}"
        else
            echo "❌ La création du rapport a échoué."
            return 1
        fi
    fi
    return 0
} 