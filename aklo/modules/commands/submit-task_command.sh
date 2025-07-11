#!/usr/bin/env bash
#==============================================================================
# AKLO SUBMIT-TASK COMMAND MODULE - VERSION ROBUSTE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: submit-task
# Crée un commit standardisé, met à jour le statut de la tâche et pousse la branche.
#------------------------------------------------------------------------------
cmd_submit-task() {
    # 1. Lire la configuration
    local main_branch
    main_branch=$(get_config "MAIN_BRANCH_NAME" "master")

    # 2. Détecter la branche Git actuelle et appliquer le garde-fou
    local current_branch
    current_branch=$(git -C "${AKLO_PROJECT_ROOT}" symbolic-ref --short HEAD 2>/dev/null)

    if [ "$current_branch" == "$main_branch" ]; then
        echo "❌ Erreur: 'submit-task' ne peut pas être exécuté sur la branche principale ('$main_branch')." >&2
        echo "   Cette commande est réservée aux branches de fonctionnalités (ex: feature/task-...). " >&2
        return 1
    fi

    if [[ ! "$current_branch" =~ ^feature/task-([0-9]+-[0-9]+) ]]; then
        echo "Erreur: Vous n'êtes pas sur une branche de tâche valide (ex: feature/task-PBI_ID-TASK_ID)." >&2
        echo "Branche actuelle : $current_branch" >&2
        return 1
    fi

    local task_id_full="${BASH_REMATCH[1]}"
    echo "ℹ️  Tâche détectée depuis la branche : #$task_id_full"

    # 2. Trouver le fichier de la tâche
    local tasks_dir="${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks"
    local task_file
    task_file=$(find "$tasks_dir" -name "TASK-${task_id_full}-*.xml" 2>/dev/null | head -1)

    if [ -z "$task_file" ]; then
        echo "Erreur: Fichier pour la tâche #$task_id_full introuvable." >&2
        return 1
    fi
    
    # 3. Mettre à jour le statut de la tâche
    local current_filename
    current_filename=$(basename "$task_file")
    local base_name
    base_name=$(echo "$current_filename" | sed -E 's/-(TODO|IN_PROGRESS|DONE|MERGED)\.xml$//')
    
    local new_filename="${base_name}-AWAITING_REVIEW.xml"
    local new_filepath="${tasks_dir}/${new_filename}"

    if [ "$task_file" != "$new_filepath" ]; then
        mv "$task_file" "$new_filepath"
        echo "✅ Statut de la tâche #$task_id_full mis à jour à AWAITING_REVIEW."
    fi

    # 4. Créer le commit
    echo "📝 Préparation du commit..."
    git -C "${AKLO_PROJECT_ROOT}" add .
    
    local task_title
    task_title=$(echo "$base_name" | sed "s/TASK-${task_id_full}-//g" | tr '-' ' ')
    local commit_message="feat(task-${task_id_full}): ${task_title}"
    
    git -C "${AKLO_PROJECT_ROOT}" commit -m "$commit_message" -m "Closes TASK-${task_id_full}"
    echo "✅ Commit créé avec succès."

    # 5. Pousser la branche
    if git -C "${AKLO_PROJECT_ROOT}" remote | grep -q "origin"; then
        echo "🚀 Poussée de la branche '$current_branch' vers origin..."
        git -C "${AKLO_PROJECT_ROOT}" push --set-upstream origin "$current_branch"
        echo "🎉 Tâche soumise et prête pour la revue !"
    else
        echo "⚠️  Aucun remote 'origin' configuré. La branche n'a pas été poussée."
    fi

    return 0
} 