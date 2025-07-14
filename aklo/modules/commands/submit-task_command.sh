#!/usr/bin/env bash
#==============================================================================
# AKLO SUBMIT-TASK COMMAND MODULE
#==============================================================================

cmd_submit-task() {
    local main_branch
    main_branch=$(get_config "MAIN_BRANCH_NAME" "master")

    local current_branch
    current_branch=$(git -C "${AKLO_PROJECT_ROOT}" symbolic-ref --short HEAD 2>/dev/null)

    if [[ ! "$current_branch" =~ ^feature/task-([0-9]+-[0-9]+) ]]; then
        echo "Erreur: Vous n'êtes pas sur une branche de tâche valide (ex: feature/task-X-Y)." >&2
        return 1
    fi

    local task_id_full="${BASH_REMATCH[1]}"
    echo "ℹ️  Tâche détectée depuis la branche : #$task_id_full"

    local task_file
    task_file=$(find "${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks" -name "TASK-${task_id_full}-*.xml" | head -n 1)
    
    local task_title
    task_title=$(basename "$task_file" | sed -E "s/TASK-${task_id_full}-(.*)-(TODO|IN_PROGRESS|DONE|MERGED).xml/\1/" | tr '-' ' ')
    local commit_message="feat(task-${task_id_full}): ${task_title}"

    echo "📝 Préparation du commit..."
    git -C "${AKLO_PROJECT_ROOT}" add .
    git -C "${AKLO_PROJECT_ROOT}" commit -m "$commit_message" -m "Closes TASK-${task_id_full}"
    
    echo "🚀 Poussée de la branche vers l'origine..."
    git -C "${AKLO_PROJECT_ROOT}" push --set-upstream origin "$current_branch"
    
    echo "✅ Tâche soumise et prête pour la revue !"
    return 0
} 