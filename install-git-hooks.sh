#!/bin/bash
#==============================================================================
# Installation des hooks Git pour la gestion automatique des permissions
#==============================================================================

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"
HOOKS_DIR="$REPO_ROOT/.git/hooks"
SOURCE_HOOKS_DIR="$REPO_ROOT/.githooks"

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
    ╔══════════════════════════════════════╗
    ║       🪝 INSTALL GIT HOOKS           ║
    ║     Installation automatique des     ║
    ║         hooks de permissions        ║
    ╚══════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

install_hooks() {
    show_banner
    
    # Vérifier que nous sommes dans un repo Git
    if [ ! -d "$REPO_ROOT/.git" ]; then
        log_warning "Ce script doit être exécuté dans un répertoire Git"
        exit 1
    fi
    
    # Vérifier que le répertoire source existe
    if [ ! -d "$SOURCE_HOOKS_DIR" ]; then
        log_warning "Répertoire .githooks non trouvé"
        exit 1
    fi
    
    log_info "Installation des hooks Git..."
    
    # Créer le répertoire hooks s'il n'existe pas
    mkdir -p "$HOOKS_DIR"
    
    # Installer chaque hook
    local hooks_installed=0
    for hook_file in "$SOURCE_HOOKS_DIR"/*; do
        if [ -f "$hook_file" ]; then
            local hook_name=$(basename "$hook_file")
            local target_hook="$HOOKS_DIR/$hook_name"
            
            # Copier le hook
            cp "$hook_file" "$target_hook"
            chmod +x "$target_hook"
            
            log_success "Hook installé: $hook_name"
            hooks_installed=$((hooks_installed + 1))
        fi
    done
    
    if [ $hooks_installed -gt 0 ]; then
        echo ""
        log_success "Installation terminée ! $hooks_installed hook(s) installé(s)"
        echo ""
        log_info "Les hooks suivants sont maintenant actifs:"
        echo "  • post-merge: Corrige les permissions après git pull/merge"
        echo ""
        log_info "Pour désinstaller: rm -f $HOOKS_DIR/post-merge"
    else
        log_warning "Aucun hook trouvé à installer"
    fi
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help        Afficher cette aide"
    echo "  -u, --uninstall   Désinstaller les hooks"
    echo ""
    echo "Ce script installe les hooks Git pour la gestion automatique"
    echo "des permissions des scripts."
}

uninstall_hooks() {
    echo "🗑️  Désinstallation des hooks Git..."
    
    local hooks_removed=0
    for hook_file in "$SOURCE_HOOKS_DIR"/*; do
        if [ -f "$hook_file" ]; then
            local hook_name=$(basename "$hook_file")
            local target_hook="$HOOKS_DIR/$hook_name"
            
            if [ -f "$target_hook" ]; then
                rm -f "$target_hook"
                log_success "Hook désinstallé: $hook_name"
                hooks_removed=$((hooks_removed + 1))
            fi
        fi
    done
    
    if [ $hooks_removed -gt 0 ]; then
        log_success "Désinstallation terminée ! $hooks_removed hook(s) supprimé(s)"
    else
        log_info "Aucun hook à désinstaller"
    fi
}

# Fonction principale
main() {
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        -u|--uninstall)
            uninstall_hooks
            ;;
        "")
            install_hooks
            ;;
        *)
            echo "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
}

# Vérifier si le script est exécuté directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 