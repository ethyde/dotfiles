#!/usr/bin/env bash

# Script de démonstration des commandes améliorées
# SSH, NVM/Node et Git avec de beaux affichages

# Charger les fonctions d'affichage et les fonctions améliorées
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.shell_display"
source "$SCRIPT_DIR/.shell_functions_enhanced"

print_header "🎯 Démonstration des commandes améliorées"

echo ""
print_info "Ce script va démontrer les nouvelles commandes avec affichage amélioré :"
print_step "• Commandes SSH (agent, clés, statut)"
print_step "• Commandes NVM/Node.js (versions, installation)"
print_step "• Commandes Git (commit, branches, rebase)"
print_step "• Commande reload du shell"

echo ""
read -p "Appuyez sur Entrée pour commencer la démonstration..."

# ==============================================================================
#                      Démonstration SSH
# ==============================================================================

print_header "🔐 DÉMONSTRATION SSH"

echo ""
print_info "1. Statut de l'agent SSH"
ssh_agent_status

echo ""
print_info "2. Rechargement de l'environnement SSH"
ssh_env_reload_enhanced

echo ""
read -p "Appuyez sur Entrée pour continuer vers NVM/Node.js..."

# ==============================================================================
#                      Démonstration NVM/Node.js
# ==============================================================================

print_header "🟢 DÉMONSTRATION NVM/NODE.JS"

echo ""
print_info "1. Version Node.js actuelle"
node_version_enhanced

echo ""
print_info "2. Liste des versions NVM"
if command -v nvm &> /dev/null; then
    nvm_list_enhanced
else
    print_warning "NVM n'est pas disponible pour cette démonstration"
fi

echo ""
print_info "3. Simulation d'un changement de répertoire avec .nvmrc"
print_step "Création d'un répertoire de test temporaire..."

# Créer un répertoire temporaire avec un .nvmrc
temp_dir="/tmp/demo_nvmrc_$$"
mkdir -p "$temp_dir"
echo "lts/jod" > "$temp_dir/.nvmrc"

print_step "Changement vers le répertoire avec .nvmrc..."
cd_enhanced "$temp_dir"

print_step "Retour au répertoire original..."
cd_enhanced "$SCRIPT_DIR"

print_step "Nettoyage du répertoire temporaire..."
rm -rf "$temp_dir"

echo ""
read -p "Appuyez sur Entrée pour continuer vers Git..."

# ==============================================================================
#                      Démonstration Git
# ==============================================================================

print_header "📝 DÉMONSTRATION GIT"

# Vérifier qu'on est dans un repo git
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    print_warning "Pas dans un dépôt Git, démonstration Git limitée"
else
    echo ""
    print_info "1. Informations sur le dépôt actuel"
    local current_branch=$(git branch --show-current 2>/dev/null)
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    print_step "Dépôt: $repo_root"
    print_step "Branche actuelle: $current_branch"
    
    echo ""
    print_info "2. Statut Git avec style"
    print_step "Statut des fichiers:"
    
    # Afficher le statut git avec des couleurs
    if git diff --quiet && git diff --cached --quiet; then
        print_success "✅ Aucun changement en attente"
    else
        print_warning "⚠️  Changements détectés"
        git status --porcelain | while read -r line; do
            local status="${line:0:2}"
            local file="${line:3}"
            case "$status" in
                "M ") print_info "  📝 Modifié: $file" ;;
                "A ") print_success "  ➕ Ajouté: $file" ;;
                "D ") print_error "  ➖ Supprimé: $file" ;;
                "??") print_warning "  ❓ Non suivi: $file" ;;
                *) print_step "  $status $file" ;;
            esac
        done
    fi
    
    echo ""
    print_info "3. Exemple de format de branche recommandé"
    print_step "Format: type/JIRA-123/description"
    print_step "Exemples:"
    print_info "  • feat/PROJ-456/add-user-authentication"
    print_info "  • fix/BUG-789/resolve-login-issue"
    print_info "  • docs/DOC-123/update-readme"
    
    echo ""
    print_info "4. Simulation d'un commit automatique"
    print_step "Si vous étiez sur une branche comme 'feat/PROJ-123/awesome-feature',"
    print_step "le commit serait automatiquement formaté comme:"
    print_success "  ✨ feat(PROJ-123): awesome feature"
fi

echo ""
read -p "Appuyez sur Entrée pour la démonstration finale..."

# ==============================================================================
#                      Démonstration des aliases
# ==============================================================================

print_header "🎯 ALIASES DISPONIBLES"

echo ""
print_info "Nouvelles commandes SSH disponibles:"
print_step "• ssh-status    - Statut de l'agent SSH"
print_step "• ssh-start     - Démarrer l'agent SSH"
print_step "• ssh-load      - Charger toutes les clés SSH"
print_step "• ssh-reload    - Recharger l'environnement SSH"

echo ""
print_info "Nouvelles commandes NVM/Node disponibles:"
print_step "• node-version  - Afficher la version Node.js"
print_step "• nvm-list      - Lister les versions NVM"
print_step "• nvm-install   - Installer une version Node"
print_step "• nvm-use       - Utiliser une version Node"

echo ""
print_info "Nouvelles commandes Git disponibles:"
print_step "• gac           - Commit amélioré (git add + commit)"
print_step "• gbs           - Créer une branche (git branch start)"
print_step "• gbd           - Supprimer une branche (git branch delete)"
print_step "• gri           - Rebase interactif amélioré"

echo ""
print_info "Autres commandes améliorées:"
print_step "• reload        - Rechargement du shell amélioré"
print_step "• cd            - Navigation avec gestion NVM automatique"

echo ""
print_success "🎉 Démonstration terminée !"
print_info "Pour utiliser ces commandes, ajoutez ceci à votre .zshrc :"
echo ""
print_step "# Chargement des fonctions d'affichage améliorées"
print_step "source ~/.shell_display"
print_step "source ~/.shell_functions_enhanced"

echo ""
print_warning "💡 Conseil: Testez les commandes une par une pour vous familiariser !" 