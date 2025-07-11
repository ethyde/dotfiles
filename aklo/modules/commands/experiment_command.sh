#!/usr/bin/env bash
#==============================================================================
# AKLO EXPERIMENT COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: new experiment
#------------------------------------------------------------------------------
create_artefact_experiment() {
    local title="$1"
    local experiment_dir="${AKLO_PROJECT_ROOT}/docs/backlog/09-experiments"
    mkdir -p "$experiment_dir"

    local next_id
    next_id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)

    local filename="EXPERIMENT-${next_id}-PLANNING.xml"
    local output_file="${experiment_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    echo "🔬 Création du plan d'expérimentation : \"$title\""

    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Créerait le fichier d'expérimentation : '$output_file'"
    else
        if parse_and_generate_artefact "11-EXPERIMENTATION" "experiment_report" "$output_file" "$context_vars"; then
            echo "✅ Plan d'expérimentation créé : ${output_file}"
        else
            echo "❌ La création du plan a échoué."
            return 1
        fi
    fi
    return 0
} 