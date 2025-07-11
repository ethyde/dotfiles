#!/usr/bin/env bash
#==============================================================================
# AKLO SYSTEM COMMANDS MODULE
#==============================================================================

# Définit la fonction cmd_status qui sera appelée par aklo
cmd_status() {
    echo "📊 État du Projet Aklo..."
    
    local pbi_count
    local task_count

    # Utilise la variable globale AKLO_PROJECT_ROOT qui est fiable
    pbi_count=$(find "${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi" -name "PBI-*.xml" 2>/dev/null | wc -l | tr -d ' ')
    task_count=$(find "${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks" -name "TASK-*.xml" 2>/dev/null | wc -l | tr -d ' ')

    echo "  - PBI: ${pbi_count} "
    echo "  - Tâches: ${task_count} "
} 