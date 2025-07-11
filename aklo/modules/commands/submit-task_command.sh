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

    local tasks_dir="${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks"
    local task_file
    task_file=$(find "$tasks_dir" -name "TASK-${task_id_full}-*.xml" 2>/dev/null | head -1)
    if [ -z "$task_file" ]; then echo "Erreur: Fichier pour la tâche #$task_id_full introuvable." >&2; return 1; fi
    local current_filename=$(basename "$task_file")
    local base_name=$(echo "$current_filename" | sed -E 's/-(TODO|IN_PROGRESS|DONE|MERGED)\.xml$//')
    local new_filename="${base_name}-AWAITING_REVIEW.xml"
    local new_filepath="${tasks_dir}/${new_filename}"

    # --- Logique conditionnelle pour --dry-run ---
    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Renommerait le fichier de tâche en '$new_filename'."
    else
        if [ "$task_file" != "$new_filepath" ]; then mv "$task_file" "$new_filepath"; echo "✅ Statut mis à jour à AWAITING_REVIEW."; fi
    fi
    echo "📝 Préparation du commit..."
    local task_title=$(echo "$base_name" | sed "s/TASK-${task_id_full}-//" | tr '-' ' ')
    local commit_message="feat(task-${task_id_full}): ${task_title}"
    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Exécuterait : git add ."
        echo "[DRY-RUN] Exécuterait : git commit -m \"$commit_message\" -m \"Closes TASK-${task_id_full}\""
    else
        git -C "${AKLO_PROJECT_ROOT}" add .
        git -C "${AKLO_PROJECT_ROOT}" commit -m "$commit_message" -m "Closes TASK-${task_id_full}"
        echo "✅ Commit créé."
    fi
    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Exécuterait : git push --set-upstream origin \"$current_branch\""
    else
        if git -C "${AKLO_PROJECT_ROOT}" remote | grep -q "origin"; then
            git -C "${AKLO_PROJECT_ROOT}" push --set-upstream origin "$current_branch"
            echo "🚀 Tâche soumise et prête pour la revue !"
        else
            echo "⚠️  Aucun remote 'origin' configuré. La branche n'a pas été poussée."
        fi
    fi
    return 0
} 