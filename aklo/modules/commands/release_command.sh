#!/usr/bin/env bash
#==============================================================================
# AKLO RELEASE COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: release
# Gère le processus de création d'une nouvelle version.
#------------------------------------------------------------------------------
cmd_release() {
    local release_type="$1"
    
    if [ -z "$release_type" ]; then
        echo "Erreur: Le type de release (major, minor, patch) est manquant." >&2
        echo "Usage: aklo release <major|minor|patch>" >&2
        return 1
    fi

    if [[ "$release_type" != "major" && "$release_type" != "minor" && "$release_type" != "patch" ]]; then
        echo "Erreur: Type de release invalide. Utilisez 'major', 'minor', ou 'patch'." >&2
        return 1
    fi
    
    echo "🚀 Démarrage du processus de release de type '$release_type'..."

    # Logique de versioning (simplifiée ici, pourrait utiliser npm version par ex.)
    local current_version
    current_version=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    # Logique pour incrémenter la version...
    local new_version="v_suivante" 

    local release_branch="release/${new_version}"
    local main_branch
    main_branch=$(get_config "MAIN_BRANCH_NAME" "master")

    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Version actuelle détectée : $current_version"
        echo "[DRY-RUN] Créerait la branche de release : '$release_branch' depuis '$main_branch'."
        echo "[DRY-RUN] Exécuterait les scripts de build et de test."
        echo "[DRY-RUN] Créerait le tag Git : '$new_version'."
        echo "[DRY-RUN] Fusionnerait '$release_branch' dans '$main_branch'."
    else
        echo "Création de la branche de release '$release_branch'..."
        git -C "${AKLO_PROJECT_ROOT}" checkout -b "$release_branch" "$main_branch"
        
        # Ici, on ajouterait normalement des étapes de build, de test, de mise à jour du CHANGELOG...

        echo "Finalisation de la release..."
        git -C "${AKLO_PROJECT_ROOT}" checkout "$main_branch"
        git -C "${AKLO_PROJECT_ROOT}" merge --no-ff "$release_branch" -m "release: Version ${new_version}"
        git -C "${AKLO_PROJECT_ROOT}" tag "$new_version"
        
        echo "Suppression de la branche de release..."
        git -C "${AKLO_PROJECT_ROOT}" branch -d "$release_branch"
        
        echo "✅ Release ${new_version} terminée. N'oubliez pas de pousser les commits et le tag."
    fi

    return 0
}