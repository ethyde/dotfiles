#!/usr/bin/env bash
#==============================================================================
# AKLO TASK COMMANDS MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: plan
# Décompose un PBI en tâches techniques.
# Pour le moment, crée une seule tâche par PBI pour valider le workflow.
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
        echo "Erreur: PBI #${pbi_id} introuvable." >&2
        return 1
    fi

    echo "📋 Planification des tâches pour le PBI #${pbi_id}."

    local task_dir="${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks"
    mkdir -p "$task_dir"
    
    # Logique simplifiée : créer une seule tâche pour le test
    local task_num=1
    local title="Première tâche pour le PBI ${pbi_id}"
    
    local sanitized_title
    sanitized_title=$(echo "$title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
    local filename="TASK-${pbi_id}-${task_num}-${sanitized_title}-TODO.xml"
    local output_file="${task_dir}/${filename}"
    
    # Contexte pour le parser
    local context_vars="pbi_id=${pbi_id},task_id=${task_num},title=${title},status=TODO"

    # Appel du parser pour générer l'artefact de tâche
    # Note: Nous utilisons le protocole "01-PLANIFICATION" qui définit le template de la tâche.
    if parse_and_generate_artefact "01-PLANIFICATION" "task" "full" "$output_file" "$context_vars"; then
        echo "✅ Tâche créée : ${filename}"
    else
        echo "❌ La création de la tâche a échoué."
        return 1
    fi
} 