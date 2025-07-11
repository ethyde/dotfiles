#!/usr/bin/env bash
#==============================================================================
# AKLO NEW COMMAND MODULE
# Gère la création de tous les types d'artefacts.
#==============================================================================

# --- Fonction principale de la commande "new" ---
cmd_new() {
    local artefact_type="$1"
    local title="$2"

    if [ -z "$artefact_type" ]; then
        echo "Erreur: Le type d'artefact est manquant." >&2
        echo "Usage: aklo new <type> \"<titre>\"" >&2
        echo "Types disponibles: pbi, debug, refactor, optimize, etc."
        return 1
    fi

    if [ -z "$title" ]; then
        echo "Erreur: Le titre est manquant." >&2
        return 1
    fi

    # Aiguillage vers la fonction de création spécifique
    local create_function="create_artefact_$artefact_type"
    if declare -f "$create_function" >/dev/null; then
        "$create_function" "$title"
    else
        echo "Erreur: Le type d'artefact '$artefact_type' est inconnu." >&2
        return 1
    fi
} 