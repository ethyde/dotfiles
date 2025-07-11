#!/usr/bin/env bash
#==============================================================================
# Script de correction automatique des permissions pour tous les scripts
# Trouve et rend exécutables tous les scripts .sh, binaires et autres exécutables
#==============================================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=false
VERBOSE=false
FIXED_COUNT=0
CHECKED_COUNT=0

log_step() {
    echo -e "\n${BLUE}🔄 $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

log_fixed() {
    echo -e "${GREEN}🔧 $1${NC}"
}

show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════╗
    ║       🔧 FIX SCRIPT PERMISSIONS      ║
    ║     Correction automatique des       ║
    ║         permissions manquantes       ║
    ╚══════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Fonction pour vérifier si un fichier est exécutable
is_executable() {
    local file="$1"
    [ -x "$file" ]
}

# Fonction pour vérifier si un fichier devrait être exécutable
should_be_executable() {
    local file="$1"
    local filename=$(basename "$file")
    local extension="${filename##*.}"
    
    # Scripts shell
    if [[ "$extension" == "sh" ]]; then
        return 0
    fi
    
    # Scripts sans extension dans bin/
    if [[ "$file" == */bin/* && "$extension" == "$filename" ]]; then
        return 0
    fi
    
    # Scripts avec shebang
    if [ -f "$file" ]; then
        local first_line=$(head -n1 "$file" 2>/dev/null || echo "")
        if [[ "$first_line" =~ ^#! ]]; then
            return 0
        fi
    fi
    
    # Scripts spécifiques connus
    case "$filename" in
        "install"|"aklo"|"dotbot")
            return 0
            ;;
    esac
    
    return 1
}

# Fonction pour corriger les permissions d'un fichier
fix_file_permissions() {
    local file="$1"
    local rel_path="${file#$DOTFILES_ROOT/}"
    
    CHECKED_COUNT=$((CHECKED_COUNT + 1))
    
    if should_be_executable "$file"; then
        if ! is_executable "$file"; then
            if [ "$DRY_RUN" = true ]; then
                log_warning "SERAIT CORRIGÉ: $rel_path"
            else
                chmod +x "$file"
                log_fixed "CORRIGÉ: $rel_path"
            fi
            FIXED_COUNT=$((FIXED_COUNT + 1))
        elif [ "$VERBOSE" = true ]; then
            log_info "OK: $rel_path"
        fi
    fi
}

# Fonction pour scanner récursivement un répertoire
scan_directory() {
    local dir="$1"
    local exclude_patterns=(
        "*/\.git/*"
        "*/node_modules/*"
        "*/\.npm/*"
        "*/\.nvm/*"
        "*/__pycache__/*"
        "*/\.venv/*"
        "*/venv/*"
        "*/\.pytest_cache/*"
        "*/.dotbot/*"
    )
    
    if [ "$VERBOSE" = true ]; then
        log_info "Scan du répertoire: ${dir#$DOTFILES_ROOT/}"
    fi
    
    # Construire la commande find avec exclusions
    local find_cmd="find \"$dir\" -type f"
    for pattern in "${exclude_patterns[@]}"; do
        find_cmd="$find_cmd ! -path \"$pattern\""
    done
    
    # Exécuter la commande et traiter les fichiers
    eval "$find_cmd" | while IFS= read -r file; do
        fix_file_permissions "$file"
    done
}

# Fonction pour lister les répertoires critiques
list_critical_directories() {
    local critical_dirs=(
        "$DOTFILES_ROOT/bin"
        "$DOTFILES_ROOT/aklo/bin"
        "$DOTFILES_ROOT/aklo/tests"
        "$DOTFILES_ROOT/aklo/mcp-servers"
        "$DOTFILES_ROOT/aklo/ux-improvements"
        "$DOTFILES_ROOT/shell/docs"
        "$DOTFILES_ROOT/dotbot/bin"
    )
    
    echo "📁 Répertoires critiques à vérifier:"
    for dir in "${critical_dirs[@]}"; do
        if [ -d "$dir" ]; then
            local count=$(find "$dir" -name "*.sh" -o -name "install" -o -name "aklo" -o -name "dotbot" 2>/dev/null | wc -l | tr -d ' ')
            echo "  • ${dir#$DOTFILES_ROOT/} ($count scripts)"
        fi
    done
}

# Fonction de rapport final
show_report() {
    echo ""
    log_step "Rapport de correction"
    
    echo "📊 Statistiques:"
    echo "  • Fichiers vérifiés: $CHECKED_COUNT"
    echo "  • Fichiers corrigés: $FIXED_COUNT"
    
    if [ "$DRY_RUN" = true ]; then
        echo ""
        log_warning "Mode DRY-RUN activé - aucune modification effectuée"
        echo "Pour appliquer les corrections: $0 --fix"
    elif [ "$FIXED_COUNT" -gt 0 ]; then
        echo ""
        log_success "Toutes les permissions ont été corrigées !"
    else
        echo ""
        log_success "Toutes les permissions sont déjà correctes !"
    fi
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help        Afficher cette aide"
    echo "  -n, --dry-run     Mode simulation (ne modifie rien)"
    echo "  -f, --fix         Corriger les permissions (défaut)"
    echo "  -v, --verbose     Mode verbeux"
    echo "  -l, --list        Lister les répertoires critiques"
    echo "  -c, --check       Vérifier seulement (équivalent à --dry-run --verbose)"
    echo ""
    echo "Ce script trouve et corrige automatiquement les permissions"
    echo "de tous les scripts dans le projet dotfiles."
    echo ""
    echo "Exemples:"
    echo "  $0                    # Corriger toutes les permissions"
    echo "  $0 --dry-run          # Voir ce qui serait corrigé"
    echo "  $0 --check            # Vérification détaillée"
    echo "  $0 --list             # Lister les répertoires"
}

# Fonction principale
main() {
    # Traitement des arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -f|--fix)
                DRY_RUN=false
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -l|--list)
                list_critical_directories
                exit 0
                ;;
            -c|--check)
                DRY_RUN=true
                VERBOSE=true
                shift
                ;;
            *)
                echo "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    show_banner
    
    # Vérifier que nous sommes dans le bon répertoire
    if [ ! -f "$DOTFILES_ROOT/install" ] || [ ! -d "$DOTFILES_ROOT/aklo" ]; then
        log_warning "Ce script doit être exécuté depuis la racine du projet dotfiles"
        exit 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log_info "Mode simulation - aucune modification ne sera effectuée"
    fi
    
    list_critical_directories
    
    log_step "Scan et correction des permissions"
    
    # Scanner tout le projet
    scan_directory "$DOTFILES_ROOT"
    
    show_report
    
    # Suggestions
    echo ""
    echo -e "${YELLOW}💡 Conseils :${NC}"
    echo "• Ajoutez ce script à votre processus d'installation"
    echo "• Exécutez-le après chaque git clone ou pull"
    echo "• Utilisez --check pour vérifier régulièrement"
}

# Vérifier si le script est exécuté directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 