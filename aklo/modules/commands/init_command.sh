#!/usr/bin/env bash
#==============================================================================
# AKLO INIT COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: init
# Initialise un nouveau projet Aklo en créant la structure de base.
#------------------------------------------------------------------------------
cmd_init() {
    echo "🔧 Initialisation du projet Aklo..."

    local pbi_dir="${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi"
    local tasks_dir="${AKLO_PROJECT_ROOT}/docs/backlog/01-tasks"
    local config_file="${AKLO_PROJECT_ROOT}/.aklo.conf"
    local default_config_file="${AKLO_PROJECT_ROOT}/aklo/config/.aklo.conf"

    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Créerait les répertoires dans 'docs/backlog/'."
        if [ ! -f "$config_file" ]; then
            echo "[DRY-RUN] Copierait '$default_config_file' vers '$config_file'."
        else
            echo "[DRY-RUN] Le fichier '.aklo.conf' existe déjà, aucune action."
        fi
    else
        mkdir -p "$pbi_dir"
        mkdir -p "$tasks_dir"
        echo "✅ Structure de répertoires créée dans 'docs/backlog/'."

        if [ ! -f "$config_file" ]; then
            cp "$default_config_file" "$config_file"
            echo "✅ Fichier de configuration '.aklo.conf' créé à partir du défaut."
        else
            echo "ℹ️  Le fichier '.aklo.conf' existe déjà."
        fi
    fi
    echo "🎉 Projet initialisé avec succès !"
} 