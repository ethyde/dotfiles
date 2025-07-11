#!/usr/bin/env bash
#==============================================================================
# AKLO HOTFIX COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: hotfix
# Gère le cycle de vie des corrections urgentes en production.
#------------------------------------------------------------------------------
cmd_hotfix() {
    local action="$1"
    local main_branch
    main_branch=$(get_config "MAIN_BRANCH_NAME" "master")
    
    case "$action" in
        "start")
            local description="$2"
            if [ -z "$description" ]; then
                echo "Erreur: une description est requise pour démarrer un hotfix." >&2
                echo "Usage: aklo hotfix start \"<description du bug>\"" >&2
                return 1
            fi
            
            local hotfix_branch="hotfix/$(echo "$description" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)"
            echo "🔥 Démarrage du hotfix : '$description'"

            if [ "$AKLO_DRY_RUN" = true ]; then
                echo "[DRY-RUN] Créerait la branche '$hotfix_branch' depuis la branche principale ('$main_branch')."
            else
                git -C "${AKLO_PROJECT_ROOT}" checkout -b "$hotfix_branch" "$main_branch"
                echo "🌿 Branche de hotfix '$hotfix_branch' créée. Appliquez vos corrections maintenant."
            fi
            ;;
        "publish")
            local current_branch
            current_branch=$(git -C "${AKLO_PROJECT_ROOT}" symbolic-ref --short HEAD 2>/dev/null)

            if [[ ! "$current_branch" =~ ^hotfix/ ]]; then
                echo "Erreur: La commande 'hotfix publish' doit être exécutée depuis une branche de hotfix." >&2
                return 1
            fi
            
            echo "🚀 Publication du hotfix depuis la branche '$current_branch'..."

            # La logique de versioning et de tag serait ici
            local new_tag="v_next_patch"

            if [ "$AKLO_DRY_RUN" = true ]; then
                echo "[DRY-RUN] Fusionnerait '$current_branch' dans '$main_branch'."
                echo "[DRY-RUN] Créerait le tag '$new_tag'."
                echo "[DRY-RUN] Pousserait '$main_branch' et le nouveau tag."
                echo "[DRY-RUN] Supprimerait la branche locale '$current_branch'."
            else
                git -C "${AKLO_PROJECT_ROOT}" checkout "$main_branch"
                git -C "${AKLO_PROJECT_ROOT}" merge --no-ff "$current_branch" -m "fix(hotfix): Merge hotfix branch '$current_branch'"
                # git -C "${AKLO_PROJECT_ROOT}" tag ...
                git -C "${AKLO_PROJECT_ROOT}" push origin "$main_branch" --tags
                git -C "${AKLO_PROJECT_ROOT}" branch -d "$current_branch"
                echo "✅ Hotfix publié et fusionné avec succès."
            fi
            ;;
        *)
            echo "Erreur: Action pour hotfix inconnue. Utilisez 'start' ou 'publish'." >&2
            return 1
            ;;
    esac
    return 0
}