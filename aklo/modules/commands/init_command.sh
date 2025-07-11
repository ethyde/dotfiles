#!/usr/bin/env bash
#==============================================================================
# AKLO INIT COMMAND MODULE (STABLE V2)
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: init
# Initialise un nouveau projet Aklo de manière robuste.
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
            echo "[DRY-RUN] Copierait '$default_config_file' et définirait PROJECT_WORKDIR."
        else
            echo "[DRY-RUN] Vérifierait et mettrait à jour PROJECT_WORKDIR dans '$config_file'."
        fi
    else
        mkdir -p "$pbi_dir"
        mkdir -p "$tasks_dir"
        echo "✅ Structure de répertoires créée."

        if [ ! -f "$config_file" ]; then
            cp "$default_config_file" "$config_file"
            echo "✅ Fichier de configuration '.aklo.conf' créé."
        fi

        # CORRECTION : S'assurer que PROJECT_WORKDIR est toujours présent et correct.
        if grep -q "^PROJECT_WORKDIR=" "$config_file"; then
            # Met à jour la ligne existante (compatible macOS & Linux)
            sed -i.bak "s|^PROJECT_WORKDIR=.*|PROJECT_WORKDIR=${AKLO_PROJECT_ROOT}|" "$config_file" && rm "${config_file}.bak"
        else
            # Ajoute la ligne si elle n'existe pas
            echo "PROJECT_WORKDIR=${AKLO_PROJECT_ROOT}" >> "$config_file"
        fi
        echo "✅ Configuration de PROJECT_WORKDIR assurée."
    fi
    echo "🎉 Projet initialisé avec succès !"
} 