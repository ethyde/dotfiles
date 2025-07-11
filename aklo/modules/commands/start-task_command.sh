#!/usr/bin/env bash
#==============================================================================
# AKLO START-TASK COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: start-task
# Marque une tâche comme "IN_PROGRESS" et crée la branche git associée.
#------------------------------------------------------------------------------
cmd_start-task() {
    local task_id_full="$1"
    if [ -z "$task_id_full" ]; then
        echo "Erreur: L'ID de la tâche est manquant." >&2
        echo "Usage: aklo start-task <PBI_ID-TASK_ID>" >&2
        return 1
    fi

    local tasks_dir="${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks"
    local task_file
    task_file=$(find "$tasks_dir" -name "TASK-${task_id_full}-*.xml" 2>/dev/null | head -1)

    if [ -z "$task_file" ]; then
        echo "Erreur: Tâche #$task_id_full introuvable." >&2
        return 1
    fi
    
    local current_filename=$(basename "$task_file")
    local base_name=$(echo "$current_filename" | sed -E 's/-(TODO|IN_PROGRESS|DONE|MERGED)\.xml$//')
    local new_filename="${base_name}-IN_PROGRESS.xml"
    local new_filepath="${tasks_dir}/${new_filename}"

    # --- Logique conditionnelle pour --dry-run ---
    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Renommerait le fichier de tâche en '$new_filename'."
    else
        if [ "$task_file" != "$new_filepath" ]; then
            mv "$task_file" "$new_filepath"
            echo "✅ Statut de la tâche #$task_id_full mis à jour à IN_PROGRESS."
        else
            echo "ℹ️  La tâche #$task_id_full est déjà en cours."
        fi
    fi

    # Création de la branche Git (Conditionnel)
    local branch_name="feature/task-${task_id_full}"
    if git -C "${AKLO_PROJECT_ROOT}" rev-parse --verify "$branch_name" >/dev/null 2>&1; then
        if [ "$AKLO_DRY_RUN" = true ]; then
             echo "[DRY-RUN] Exécuterait : git checkout '$branch_name'"
        else
            echo "ℹ️  La branche '$branch_name' existe déjà. Basculement dessus."
            git -C "${AKLO_PROJECT_ROOT}" checkout "$branch_name"
        fi
    else
        if [ "$AKLO_DRY_RUN" = true ]; then
            echo "[DRY-RUN] Exécuterait : git checkout -b '$branch_name'"
        else
            git -C "${AKLO_PROJECT_ROOT}" checkout -b "$branch_name"
            echo "🌿 Branche '$branch_name' créée et activée."
        fi
    fi
    
    return 0
} 