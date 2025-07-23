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
    local has_config=false
    local has_artefacts=false
    
    # Vérifier la configuration
    if [ -f "$config_file" ]; then
        echo "✅ Projet configuré via .aklo.conf."
        has_config=true
    else
        echo "⚠️  Aucune configuration Aklo locale trouvée. Pensez à lancer 'aklo init'."
    fi
    
    # Vérifier les artefacts avec détection robuste
    local pbi_count=0
    local task_count=0
    
    # Compter les PBI
    if [ -d "${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi" ]; then
        pbi_count=$(find "${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi" -name "PBI-*.xml" 2>/dev/null | wc -l | tr -d ' ')
    fi
    
    # Compter les tâches
    if [ -d "${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks" ]; then
        task_count=$(find "${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks" -name "TASK-*.xml" 2>/dev/null | wc -l | tr -d ' ')
    fi
    
    # Détecter si le projet a des artefacts
    if [ "$pbi_count" -gt 0 ] || [ "$task_count" -gt 0 ]; then
        has_artefacts=true
    fi
    
    echo "📊 Artefacts :"
    echo "   - PBI: ${pbi_count}"
    echo "   - Tâches: ${task_count}"
    
    # Statut du projet
    if [ "$has_config" = true ] && [ "$has_artefacts" = true ]; then
        echo "🎯 Statut: Projet Aklo actif avec artefacts"
    elif [ "$has_config" = true ]; then
        echo "🎯 Statut: Projet Aklo initialisé (aucun artefact)"
    elif [ "$has_artefacts" = true ]; then
        echo "🎯 Statut: Projet avec artefacts (non initialisé)"
    else
        echo "🎯 Statut: Projet non initialisé"
    fi

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