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
        # --- AMÉLIORATION : Aide contextuelle ---
        case "$artefact_type" in
            "release")
                echo "💡 Pour démarrer une release, la bonne commande est :" >&2
                echo "   aklo release <major|minor|patch>" >&2
                ;;
            "hotfix")
                echo "💡 Pour démarrer un hotfix, la bonne commande est :" >&2
                echo "   aklo hotfix start \"<description>\"" >&2
                ;;
            *)
                echo "Erreur: Le type d'artefact '$artefact_type' est inconnu." >&2
                ;;
        esac
        return 1
    fi
} 