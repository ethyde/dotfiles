#!/usr/bin/env bash
#==============================================================================
# AKLO SYSTEM COMMANDS MODULE - FINAL
# Commandes : status, init
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: status
# Affiche un tableau de bord complet de l'état du projet.
#------------------------------------------------------------------------------
cmd_status() {
    echo "🤖 Aklo Project Status Dashboard"
    echo "========================================"
    
    local config_file="${AKLO_PROJECT_ROOT}/.aklo.conf"
    if [ -f "$config_file" ]; then
        echo "✅ Projet configuré via .aklo.conf."
    else
        echo "⚠️  Aucune configuration Aklo locale trouvée. Pensez à lancer 'aklo init'."
    fi
    
    local pbi_count
    pbi_count=$(find "${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi" -name "PBI-*.xml" 2>/dev/null | wc -l | tr -d ' ')
    local task_count
    task_count=$(find "${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks" -name "TASK-*.xml" 2>/dev/null | wc -l | tr -d ' ')
    
    echo "📊 Artefacts :"
    echo "   - PBI: ${pbi_count}"
    echo "   - Tâches: ${task_count}"

    if git -C "${AKLO_PROJECT_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch
        branch=$(git -C "${AKLO_PROJECT_ROOT}" branch --show-current)
        echo "🌿 Git Branch: ${branch}"
    fi
}

#------------------------------------------------------------------------------
# COMMANDE: init
#------------------------------------------------------------------------------
cmd_init() {
    echo "🔧 Initialisation du projet Aklo..."
    mkdir -p "${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi"
    mkdir -p "${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks"
    echo "✅ Structure de répertoires créée dans 'docs/backlog/'."

    local config_file="${AKLO_PROJECT_ROOT}/.aklo.conf"
    if [ ! -f "$config_file" ]; then
        cp "${AKLO_TOOL_DIR}/config/.aklo.conf" "$config_file"
        echo "✅ Fichier de configuration '.aklo.conf' créé à partir du défaut."
    else
        echo "ℹ️  Le fichier '.aklo.conf' existe déjà."
    fi
    echo "🎉 Projet initialisé avec succès !"
} 