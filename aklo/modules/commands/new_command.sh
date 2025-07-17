#!/usr/bin/env bash
#==============================================================================
# AKLO NEW COMMAND MODULE (Dispatcher Complet et Robuste)
# Gère la création de tous les types d'artefacts.
#==============================================================================

# --- Fonction principale de la commande "new" ---
cmd_new() {
    local artefact_type="$1"
    local title="$2"

    if [ -z "$artefact_type" ]; then
        echo "Erreur: Le type d'artefact est manquant." >&2
        echo "Usage: aklo new <type> \"<titre>\"" >&2
        echo "Types disponibles: pbi, task, debug, refactor, optimize, security, docs, experiment, scratchpad, meta, journal, review, arch, analysis, onboarding, deprecation, tracking, fast, kb"
        return 1
    fi

    if [ -z "$title" ]; then
        echo "Erreur: Le titre est manquant." >&2
        return 1
    fi

    # --- AIGUILLAGE DYNAMIQUE ---
    # Construit le nom de la fonction de création spécifique.
    # Ex: si artefact_type="pbi", create_function="create_artefact_pbi"
    local create_function="create_artefact_$artefact_type"

    # Vérifie si cette fonction existe avant de l'appeler.
    if declare -f "$create_function" >/dev/null; then
        # Appelle la fonction de création (ex: create_artefact_pbi "My Test PBI")
        "$create_function" "$title"
    else
        # Si la fonction n'existe pas, c'est que le type d'artefact est inconnu.
        case "$artefact_type" in
            "release" | "hotfix")
                echo "💡 Pour démarrer une release ou un hotfix, utilisez directement :" >&2
                echo "   aklo release <type>  /  aklo hotfix start \"<desc>\"" >&2
                ;;
            *)
                echo "Erreur: Le type d'artefact '$artefact_type' est inconnu." >&2
                echo "Types disponibles: pbi, task, debug, refactor, optimize, security, docs, experiment, scratchpad, meta, journal, review, arch, analysis, onboarding, deprecation, tracking, fast, kb" >&2
                ;;
        esac
        return 1
    fi
} 