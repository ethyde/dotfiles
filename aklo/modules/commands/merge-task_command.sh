#!/usr/bin/env bash
#==============================================================================
# AKLO MERGE-TASK COMMAND MODULE - VERSION ROBUSTE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: merge-task
# Fusionne une branche de tâche terminée et nettoie l'environnement.
#------------------------------------------------------------------------------
cmd_merge-task() {
    local task_id_full="$1"
    if [ -z "$task_id_full" ]; then echo "Erreur: L'ID de la tâche est manquant." >&2; return 1; fi

    # 1. Lire la configuration
    local main_branch
    main_branch=$(get_config "MAIN_BRANCH_NAME" "master")
    
    # 2. Trouver le fichier de la tâche
    local tasks_dir="${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks"
    
    local task_file=$(find "$tasks_dir" -name "TASK-${task_id_full}-*.xml" 2>/dev/null | head -1)

    if [ -z "$task_file" ]; then
        echo "Erreur: Tâche #$task_id_full introuvable." >&2
        return 1
    fi

    # 3. Vérifier que la tâche est prête à être fusionnée
    if [[ ! "$task_file" =~ -(DONE|AWAITING_REVIEW)\.xml$ ]]; then
        echo "Erreur: La tâche #$task_id_full n'est pas prête à être fusionnée." >&2
        echo "Statut actuel déduit du nom de fichier : $(echo "$task_file" | sed -n 's/.*-\([A-Z_]*\)\.xml/\1/p')" >&2
        return 1
    fi

    # 4. Récupérer le nom de la branche et la branche principale
    local branch_to_merge="feature/task-${task_id_full}"
    echo "🌿 Préparation de la fusion de '$branch_to_merge' dans '$main_branch'..."

    # --- Logique conditionnelle pour --dry-run ---
    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Exécuterait : git checkout '$main_branch'"
        echo "[DRY-RUN] Exécuterait : git pull origin '$main_branch' --rebase"
        echo "[DRY-RUN] Exécuterait : git merge --no-ff '$branch_to_merge' -m \"Merge branch '$branch_to_merge'\n\nMerge task TASK-${task_id_full} into ${main_branch}.\""
        echo "[DRY-RUN] Exécuterait : git push origin '$main_branch'"
        echo "[DRY-RUN] Exécuterait : git branch -d '$branch_to_merge'"
        echo "[DRY-RUN] Exécuterait : git push origin --delete '$branch_to_merge'"
        echo "[DRY-RUN] Renommerait le fichier de tâche pour le statut MERGED."
    else
        git -C "${AKLO_PROJECT_ROOT}" checkout "$main_branch"
        git -C "${AKLO_PROJECT_ROOT}" pull origin "$main_branch" --rebase
        git -C "${AKLO_PROJECT_ROOT}" merge --no-ff "$branch_to_merge" -m "Merge branch '$branch_to_merge'\n\nMerge task TASK-${task_id_full} into ${main_branch}."
        echo "✅ Branche fusionnée avec succès."
        git -C "${AKLO_PROJECT_ROOT}" push origin "$main_branch"
        git -C "${AKLO_PROJECT_ROOT}" branch -d "$branch_to_merge"
        git -C "${AKLO_PROJECT_ROOT}" push origin --delete "$branch_to_merge" 2>/dev/null || true
        echo "🗑️  Branche '$branch_to_merge' nettoyée (localement et sur origin)."
        local current_filename=$(basename "$task_file")
        local base_name=$(echo "$current_filename" | sed -E 's/-(TODO|IN_PROGRESS|DONE|AWAITING_REVIEW|MERGED)\.xml$//')
        local new_filename="${base_name}-MERGED.xml"
        local new_filepath="${tasks_dir}/${new_filename}"
        if [ "$task_file" != "$new_filepath" ]; then mv "$task_file" "$new_filepath"; echo "✅ Statut mis à jour à MERGED."; fi
        echo "🎉 Tâche #$task_id_full terminée et intégrée !"
    fi
    return 0
} 