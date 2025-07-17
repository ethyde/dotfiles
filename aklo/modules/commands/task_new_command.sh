#!/usr/bin/env bash
#==============================================================================
# AKLO TASK NEW COMMAND MODULE
#==============================================================================

create_artefact_task() {
    local title="$1"
    local task_dir="${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks"
    mkdir -p "$task_dir"

    # Générer un ID unique pour la tâche
    local next_id
    next_id=$(get_next_id "$task_dir" "TASK-")
    
    # Nettoyage du titre pour le nom de fichier
    local sanitized_title
    sanitized_title=$(echo "$title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)
    
    local filename="TASK-${next_id}-${sanitized_title}-TODO.xml"
    local output_file="${task_dir}/${filename}"
    local context_vars="task_id=${next_id},title=${title},status=TODO"

    if parse_and_generate_artefact "01-PLANIFICATION" "task" "$output_file" "$context_vars"; then
        echo "✅ Tâche créée : ${output_file}"
    else
        echo "❌ La création de la tâche a échoué." >&2
        return 1
    fi
} 