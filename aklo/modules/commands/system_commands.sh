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
    
    # Définir les chemins pour les deux configurations possibles
    local local_config="${AKLO_PROJECT_ROOT}/.aklo.conf"
    local default_config="${AKLO_PROJECT_ROOT}/aklo/config/.aklo.conf"

    # CORRECTION : Vérifier d'abord la config locale, PUIS la config par défaut
    if [ -f "$local_config" ]; then
        echo "✅ Projet configuré via le fichier local .aklo.conf."
    elif [ -f "$default_config" ]; then
        echo "ℹ️  Projet utilise la configuration par défaut (depuis aklo/config/)."
    else
        # Ne retourne une erreur que si AUCUNE configuration n'est trouvée
        echo "❌ Aucune configuration Aklo trouvée. Lancez 'aklo init' pour créer une config locale."
        return 1
    fi
    
    # L'analyse des artefacts fonctionne toujours
    local pbi_count
    pbi_count=$(find "${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi" -name "PBI-*.xml" 2>/dev/null | wc -l | tr -d ' ')
    local task_count
    task_count=$(find "${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks" -name "TASK-*.xml" 2>/dev/null | wc -l | tr -d ' ')
    
    echo "📊 Artefacts :"
    echo "   - PBI: ${pbi_count}"
    echo "   - Tâches: ${task_count}"

    # L'état Git fonctionne toujours
    if git -C "${AKLO_PROJECT_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch
        branch=$(git -C "${AKLO_PROJECT_ROOT}" branch --show-current)
        echo "🌿 Git Branch: ${branch}"
    fi
}

#------------------------------------------------------------------------------
# COMMANDE: init
# (Le code de la fonction cmd_init reste inchangé)
#------------------------------------------------------------------------------
cmd_init() {
    echo "🔧 Initialisation du projet Aklo..."

    mkdir -p "${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi"
    mkdir -p "${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks"
    echo "✅ Structure de répertoires créée dans 'docs/backlog/'."

    local config_file="${AKLO_PROJECT_ROOT}/.aklo.conf"
    if [ ! -f "$config_file" ]; then
        # Copie la configuration par défaut au lieu de la créer de zéro
        cp "${AKLO_PROJECT_ROOT}/aklo/config/.aklo.conf" "$config_file"
        echo "✅ Fichier de configuration '.aklo.conf' créé à partir du défaut."
    else
        echo "ℹ️  Le fichier '.aklo.conf' existe déjà."
    fi

    echo "🎉 Projet initialisé avec succès !"
} 