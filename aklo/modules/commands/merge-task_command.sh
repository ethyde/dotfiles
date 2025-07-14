#!/usr/bin/env bash
#==============================================================================
# AKLO MERGE-TASK COMMAND MODULE
#==============================================================================

cmd_merge-task() {
    local task_id_full="$1"
    if [ -z "$task_id_full" ]; then
        echo "Erreur: L'ID de la tâche est manquant." >&2
        return 1
    fi

    local main_branch
    main_branch=$(get_config "MAIN_BRANCH_NAME" "master")
    local branch_to_merge="feature/task-${task_id_full}"

    echo "🌿 Préparation de la fusion de '$branch_to_merge' dans '$main_branch'..."
    
    git -C "${AKLO_PROJECT_ROOT}" checkout "$main_branch"
    git -C "${AKLO_PROJECT_ROOT}" pull origin "$main_branch" --rebase
    git -C "${AKLO_PROJECT_ROOT}" merge --no-ff "$branch_to_merge"

    echo "✅ Branche fusionnée avec succès."
    
    git -C "${AKLO_PROJECT_ROOT}" push origin "$main_branch"
    git -C "${AKLO_PROJECT_ROOT}" branch -d "$branch_to_merge"
    git -C "${AKLO_PROJECT_ROOT}" push origin --delete "$branch_to_merge" 2>/dev/null || true
    
    echo "🗑️  Branche '$branch_to_merge' nettoyée."
    
    # Mettre à jour le statut de l'artefact (logique à ajouter si nécessaire)
    echo "🎉 Tâche #$task_id_full terminée et intégrée !"
    return 0
} 