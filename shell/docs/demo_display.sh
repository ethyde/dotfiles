#!/usr/bin/env bash

# ==============================================================================
#                    DÉMONSTRATION DES FONCTIONS D'AFFICHAGE
# ==============================================================================

# Charger les fonctions d'affichage
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.shell_display"

print_header "🎨 Démonstration des fonctions d'affichage"

echo ""
print_info "Ce script montre tous les types d'affichage disponibles :"

echo ""
print_step "1. Messages de base"
print_success "Opération réussie avec succès !"
print_error "Erreur détectée dans le processus"
print_warning "Attention : vérifiez la configuration"
print_info "Information importante à retenir"

echo ""
print_step "2. Messages spécialisés"
print_git "Opération Git en cours..."
print_branch "feature/PROJ-123/awesome-feature"
print_command "git commit -m 'feat: add new feature'"

echo ""
print_step "3. Séparateurs et structure"
print_separator
print_header "📋 Section importante"
start_operation "Installation des dépendances"
print_step "Téléchargement des packages..."
print_step "Compilation en cours..."
end_operation "Installation"

echo ""
print_success "🎉 Démonstration terminée !"
print_info "💡 Ces fonctions sont utilisées dans toutes les commandes améliorées"

echo ""
print_step "Exemples d'utilisation dans vos scripts :"
echo ""
echo "  print_header \"Mon script\""
echo "  print_step \"Étape 1...\""
echo "  print_success \"Terminé !\"" 