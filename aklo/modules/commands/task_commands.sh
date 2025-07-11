#!/usr/bin/env bash
#==============================================================================
# AKLO TASK COMMANDS MODULE
# Commandes : plan
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: plan
# Décompose un PBI en tâches techniques de manière interactive.
#------------------------------------------------------------------------------
cmd_plan() {
    local pbi_id="$1"
    if [ -z "$pbi_id" ]; then
        echo "Erreur: L'ID du PBI est manquant." >&2
        echo "Usage: aklo plan <PBI_ID>" >&2
        return 1
    fi

    # Vérifier que le PBI existe
    local pbi_dir="${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi"
    if ! find "$pbi_dir" -name "PBI-${pbi_id}-*.xml" 2>/dev/null | grep -q .; then
        echo "Erreur: PBI #$pbi_id introuvable." >&2
        return 1
    fi

    echo "📋 Planification des tâches pour le PBI #$pbi_id."
    echo "   Entrez les titres des tâches. Laissez vide pour terminer."

    local task_dir="${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks"
    mkdir -p "$task_dir"
    
    local task_num=1
    while true; do
        # Calcul du prochain ID de tâche pour ce PBI
        local last_task_sub_id
        last_task_sub_id=$(find "$task_dir" -name "TASK-${pbi_id}-*.xml" 2>/dev/null | \
                           grep -oE "TASK-${pbi_id}-[0-9]+" | \
                           sed "s/TASK-${pbi_id}-//" | \
                           sort -nr | \
                           head -1)
        task_num=$(( ${last_task_sub_id:-0} + 1 ))

        echo -n "Titre de la tâche ${pbi_id}-${task_num}: "
        read -r title

        if [ -z "$title" ]; then
            echo "Fin de la planification."
            break
        fi

        local sanitized_title=$(echo "$title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
        local filename="TASK-${pbi_id}-${task_num}-${sanitized_title}-TODO.xml"
        local output_file="${task_dir}/${filename}"
        
        # Le contexte pour le template XML
        local context_vars="pbi_id=${pbi_id},task_id=${task_num},title=${title}"

        if [ "$AKLO_DRY_RUN" = true ]; then
            echo "[DRY-RUN] Créerait la tâche : '$output_file'"
        else
            if parse_and_generate_artefact "01-PLANIFICATION" "task" "$output_file" "$context_vars"; then
                echo "✅ Tâche créée : ${filename}"
            else
                echo "❌ La création de la tâche a échoué."
            fi
        fi
    done
} 