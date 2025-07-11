#!/usr/bin/env bash
#==============================================================================
# Installation des améliorations UX pour Aklo
# Script d'installation et de démonstration
#==============================================================================

# Configuration des couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Configuration
AKLO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
UX_DIR="$AKLO_DIR/modules/ux"
AKLO_SCRIPT="$AKLO_DIR/bin/aklo"

# Fonction de bannière
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════╗
    ║           🎨 AKLO UX IMPROVEMENTS                    ║
    ║        Installation des améliorations UX             ║
    ║                                                      ║
    ║  • Système d'aide avancé (--help)                   ║
    ║  • Auto-complétion Bash/Zsh                         ║
    ║  • Commande status intelligente                     ║
    ║  • Mode Quick Start pour débutants                  ║
    ║  • Templates pré-remplis                            ║
    ║  • Validation des inputs utilisateur                ║
    ╚══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Fonction de vérification des prérequis
check_prerequisites() {
    echo -e "${BLUE}🔍 Vérification des prérequis...${NC}"
    
    local errors=0
    
    # Vérifier Bash
    if ! command -v bash >/dev/null 2>&1; then
        echo -e "${RED}❌ Bash non trouvé${NC}"
        errors=$((errors + 1))
    else
        echo -e "${GREEN}✅ Bash: $(bash --version | head -1)${NC}"
    fi
    
    # Vérifier Git (optionnel mais recommandé)
    if ! command -v git >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Git non trouvé (recommandé pour le workflow complet)${NC}"
    else
        echo -e "${GREEN}✅ Git: $(git --version)${NC}"
    fi
    
    # Vérifier que le script Aklo existe
    if [ ! -f "$AKLO_SCRIPT" ]; then
        echo -e "${RED}❌ Script Aklo non trouvé: $AKLO_SCRIPT${NC}"
        errors=$((errors + 1))
    else
        echo -e "${GREEN}✅ Script Aklo trouvé${NC}"
    fi
    
    # Vérifier les fichiers UX
    local ux_files=(
        "help-system.sh"
        "status-command.sh"
        "aklo-completion.bash"
        "aklo-completion.zsh"
        "quickstart.sh"
        "templates.sh"
        "validation.sh"
    )
    
    for file in "${ux_files[@]}"; do
        if [ ! -f "$UX_DIR/$file" ]; then
            echo -e "${RED}❌ Fichier UX manquant: $file${NC}"
            errors=$((errors + 1))
        fi
    done
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}✅ Tous les prérequis sont satisfaits${NC}"
        return 0
    else
        echo -e "${RED}❌ $errors erreur(s) trouvée(s)${NC}"
        return 1
    fi
}

# Fonction d'intégration des améliorations dans le script principal
integrate_ux_features() {
    echo -e "\n${BLUE}🔧 Intégration des améliorations UX...${NC}"
    
    # Créer une sauvegarde du script original
    if [ ! -f "$AKLO_SCRIPT.backup" ]; then
        cp "$AKLO_SCRIPT" "$AKLO_SCRIPT.backup"
        echo -e "${GREEN}✅ Sauvegarde créée: $AKLO_SCRIPT.backup${NC}"
    fi
    
    # Ajouter les sources des améliorations UX au début du script
    local temp_script=$(mktemp)
    
    # En-tête original
    head -20 "$AKLO_SCRIPT" > "$temp_script"
    
    # Ajouter les sources UX
    cat >> "$temp_script" << EOF

#==============================================================================
# AMÉLIORATIONS UX - Intégration automatique
#==============================================================================

# Source des améliorations UX
UX_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")/../ux-improvements" && pwd)"

# Charger les fonctions d'aide
if [ -f "\$UX_DIR/help-system.sh" ]; then
    source "\$UX_DIR/help-system.sh"
fi

# Charger les fonctions de validation
if [ -f "\$UX_DIR/validation.sh" ]; then
    source "\$UX_DIR/validation.sh"
fi

# Charger les templates
if [ -f "\$UX_DIR/templates.sh" ]; then
    source "\$UX_DIR/templates.sh"
fi

# Charger la commande status
if [ -f "\$UX_DIR/status-command.sh" ]; then
    source "\$UX_DIR/status-command.sh"
fi

# Charger le quickstart
if [ -f "\$UX_DIR/quickstart.sh" ]; then
    source "\$UX_DIR/quickstart.sh"
fi

EOF
    
    # Reste du script original (en sautant l'en-tête)
    tail -n +21 "$AKLO_SCRIPT" >> "$temp_script"
    
    # Remplacer le script original
    mv "$temp_script" "$AKLO_SCRIPT"
    chmod +x "$AKLO_SCRIPT"
    
    echo -e "${GREEN}✅ Améliorations UX intégrées au script principal${NC}"
}

# Fonction d'installation de l'auto-complétion
install_autocompletion() {
    echo -e "\n${BLUE}🔧 Installation de l'auto-complétion...${NC}"
    
    local shell_type=""
    
    # Détecter le shell
    if [ -n "$ZSH_VERSION" ]; then
        shell_type="zsh"
    elif [ -n "$BASH_VERSION" ]; then
        shell_type="bash"
    else
        echo -e "${YELLOW}⚠️  Shell non détecté, installation manuelle requise${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🐚 Shell détecté: $shell_type${NC}"
    
    # Installation selon le shell
    case "$shell_type" in
        "bash")
            install_bash_completion
            ;;
        "zsh")
            install_zsh_completion
            ;;
    esac
}

# Installation auto-complétion Bash
install_bash_completion() {
    local completion_file="$UX_DIR/aklo-completion.bash"
    local bashrc="$HOME/.bashrc"
    
    if [ -f "$bashrc" ]; then
        # Vérifier si déjà installé
        if grep -q "aklo-completion.bash" "$bashrc" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Auto-complétion Bash déjà installée${NC}"
            return 0
        fi
        
        # Ajouter la source
        echo "" >> "$bashrc"
        echo "# Aklo auto-completion" >> "$bashrc"
        echo "source \"$completion_file\"" >> "$bashrc"
        
        echo -e "${GREEN}✅ Auto-complétion Bash installée${NC}"
        echo -e "${BLUE}💡 Redémarrez votre terminal ou exécutez: source ~/.bashrc${NC}"
    else
        echo -e "${YELLOW}⚠️  ~/.bashrc non trouvé${NC}"
        echo -e "${BLUE}💡 Ajoutez manuellement: source \"$completion_file\"${NC}"
    fi
}

# Installation auto-complétion Zsh
install_zsh_completion() {
    local completion_file="$UX_DIR/aklo-completion.zsh"
    local zshrc="$HOME/.zshrc"
    
    if [ -f "$zshrc" ]; then
        # Vérifier si déjà installé
        if grep -q "aklo-completion.zsh" "$zshrc" 2>/dev/null; then
            echo -e "${YELLOW}⚠️  Auto-complétion Zsh déjà installée${NC}"
            return 0
        fi
        
        # Ajouter la source
        echo "" >> "$zshrc"
        echo "# Aklo auto-completion" >> "$zshrc"
        echo "source \"$completion_file\"" >> "$zshrc"
        
        echo -e "${GREEN}✅ Auto-complétion Zsh installée${NC}"
        echo -e "${BLUE}💡 Redémarrez votre terminal ou exécutez: source ~/.zshrc${NC}"
    else
        echo -e "${YELLOW}⚠️  ~/.zshrc non trouvé${NC}"
        echo -e "${BLUE}💡 Ajoutez manuellement: source \"$completion_file\"${NC}"
    fi
}

# Fonction de test des améliorations
test_ux_improvements() {
    echo -e "\n${BLUE}🧪 Test des améliorations UX...${NC}"
    
    # Test de la commande help
    echo -e "\n${CYAN}📚 Test du système d'aide:${NC}"
    if "$AKLO_SCRIPT" --help >/dev/null 2>&1; then
        echo -e "${GREEN}✅ aklo --help fonctionne${NC}"
    else
        echo -e "${RED}❌ aklo --help ne fonctionne pas${NC}"
    fi
    
    # Test de la commande status
    echo -e "\n${CYAN}📊 Test de la commande status:${NC}"
    if "$AKLO_SCRIPT" status >/dev/null 2>&1; then
        echo -e "${GREEN}✅ aklo status fonctionne${NC}"
    else
        echo -e "${RED}❌ aklo status ne fonctionne pas${NC}"
    fi
    
    # Test de quickstart
    echo -e "\n${CYAN}🚀 Test du quickstart:${NC}"
    if "$AKLO_SCRIPT" quickstart --help >/dev/null 2>&1; then
        echo -e "${GREEN}✅ aklo quickstart --help fonctionne${NC}"
    else
        echo -e "${RED}❌ aklo quickstart --help ne fonctionne pas${NC}"
    fi
    
    # Test de validation
    echo -e "\n${CYAN}✅ Test de validation:${NC}"
    if source "$UX_DIR/validation.sh" && validate_input "Test" "pbi_title" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Validation fonctionne${NC}"
    else
        echo -e "${RED}❌ Validation ne fonctionne pas${NC}"
    fi
}

# Fonction de démonstration
demo_ux_features() {
    echo -e "\n${MAGENTA}🎭 Démonstration des améliorations UX${NC}"
    echo "$(printf '%.0s═' {1..50})"
    
    echo -e "\n${CYAN}1. 📚 Système d'aide avancé:${NC}"
    echo "   aklo --help                    # Aide générale"
    echo "   aklo propose-pbi --help        # Aide spécifique"
    echo "   aklo <command> --help          # Aide pour toute commande"
    
    echo -e "\n${CYAN}2. 📊 Commande status intelligente:${NC}"
    echo "   aklo status                    # Vue d'ensemble du projet"
    echo "   aklo status --brief            # Vue condensée"
    echo "   aklo status --detailed         # Vue détaillée avec métriques"
    echo "   aklo status --json             # Format JSON pour scripts"
    
    echo -e "\n${CYAN}3. 🚀 Mode Quick Start:${NC}"
    echo "   aklo quickstart                # Guide interactif complet"
    echo "   aklo quickstart --skip-tutorial # Mode rapide"
    echo "   aklo quickstart --template webapp # Avec template"
    
    echo -e "\n${CYAN}4. 📋 Templates intelligents:${NC}"
    echo "   aklo propose-pbi --template feature \"API REST\""
    echo "   aklo propose-pbi --template bug \"Login cassé\""
    echo "   aklo propose-pbi --interactive  # Mode guidé"
    
    echo -e "\n${CYAN}5. ✅ Validation automatique:${NC}"
    echo "   • Validation des titres PBI"
    echo "   • Vérification des IDs"
    echo "   • Validation des noms de branches"
    echo "   • Messages d'erreur explicites"
    
    echo -e "\n${CYAN}6. 🔧 Auto-complétion:${NC}"
    echo "   aklo <TAB><TAB>                # Liste des commandes"
    echo "   aklo propose-pbi --<TAB>       # Options disponibles"
    echo "   aklo plan <TAB>                # IDs de PBI existants"
    
    echo -e "\n${GREEN}💡 Essayez ces commandes pour découvrir les améliorations !${NC}"
}

# Fonction de désinstallation
uninstall_ux_improvements() {
    echo -e "\n${YELLOW}🗑️  Désinstallation des améliorations UX...${NC}"
    
    # Restaurer le script original
    if [ -f "$AKLO_SCRIPT.backup" ]; then
        mv "$AKLO_SCRIPT.backup" "$AKLO_SCRIPT"
        echo -e "${GREEN}✅ Script Aklo restauré${NC}"
    else
        echo -e "${RED}❌ Sauvegarde non trouvée${NC}"
    fi
    
    # Supprimer les références dans les fichiers de configuration shell
    local bashrc="$HOME/.bashrc"
    local zshrc="$HOME/.zshrc"
    
    if [ -f "$bashrc" ]; then
        sed -i.bak '/aklo-completion\.bash/d' "$bashrc" 2>/dev/null && \
        echo -e "${GREEN}✅ Auto-complétion Bash supprimée${NC}"
    fi
    
    if [ -f "$zshrc" ]; then
        sed -i.bak '/aklo-completion\.zsh/d' "$zshrc" 2>/dev/null && \
        echo -e "${GREEN}✅ Auto-complétion Zsh supprimée${NC}"
    fi
    
    echo -e "${GREEN}✅ Désinstallation terminée${NC}"
}

# Fonction principale
main() {
    local action="${1:-install}"
    
    case "$action" in
        "install")
            show_banner
            check_prerequisites || exit 1
            integrate_ux_features
            install_autocompletion
            test_ux_improvements
            demo_ux_features
            
            echo -e "\n${GREEN}🎉 Installation des améliorations UX terminée !${NC}"
            echo -e "${BLUE}💡 Redémarrez votre terminal pour activer l'auto-complétion${NC}"
            ;;
        "test")
            test_ux_improvements
            ;;
        "demo")
            demo_ux_features
            ;;
        "uninstall")
            uninstall_ux_improvements
            ;;
        "help"|"--help")
            cat << 'EOF'
🎨 Installation des améliorations UX Aklo

USAGE:
    ./install-ux.sh [action]

ACTIONS:
    install     Installe toutes les améliorations UX (défaut)
    test        Teste les améliorations installées
    demo        Affiche une démonstration des fonctionnalités
    uninstall   Désinstalle les améliorations UX
    help        Affiche cette aide

AMÉLIORATIONS INSTALLÉES:
    • Système d'aide avancé (--help)
    • Auto-complétion Bash/Zsh
    • Commande status intelligente
    • Mode Quick Start pour débutants
    • Templates pré-remplis
    • Validation des inputs utilisateur

EXEMPLES:
    ./install-ux.sh                # Installation complète
    ./install-ux.sh test           # Test des fonctionnalités
    ./install-ux.sh demo           # Démonstration
EOF
            ;;
        *)
            echo -e "${RED}❌ Action inconnue: $action${NC}"
            echo "Utilisez: $0 help pour voir l'aide"
            exit 1
            ;;
    esac
}

# Point d'entrée
main "$@"