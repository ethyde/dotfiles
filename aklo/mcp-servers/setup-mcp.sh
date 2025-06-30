#!/bin/bash
#==============================================================================
# Installation et configuration automatique des serveurs MCP Aklo
# Logique intelligente : Node.js (optimal) → Shell natif (fallback)
#==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$HOME/.cursor-mcp-config.json"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════╗
    ║           🤖 AKLO MCP SETUP          ║
    ║     Installation intelligente        ║
    ║   avec fallback automatique          ║
    ╚══════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

log_step() {
    echo -e "\n${BLUE}🔄 $1${NC}"
    echo "$(printf '%.0s─' {1..50})"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

# Fonction de détection et génération de config
detect_and_configure() {
    log_step "Détection de l'environnement"
    
    # Exécuter la détection automatique et capturer seulement le JSON
    local temp_file=$(mktemp)
    "$SCRIPT_DIR/auto-detect.sh" > "$temp_file" 2>&1
    local detection_success=$?
    
    if [ $detection_success -eq 0 ]; then
        # Extraire la configuration JSON (entre les lignes contenant { et })
        local config_json=$(sed -n '/^{$/,/^}$/p' "$temp_file")
        
        if [ -n "$config_json" ]; then
            log_success "Configuration générée automatiquement"
            echo "$config_json"
            rm -f "$temp_file"
            return 0
        else
            log_error "Impossible d'extraire la configuration JSON"
            log_info "Output complet sauvé dans : $temp_file"
            return 1
        fi
    else
        log_error "Échec de la détection automatique"
        cat "$temp_file"
        rm -f "$temp_file"
        return 1
    fi
}

# Fonction de sauvegarde de la configuration
save_config() {
    local config="$1"
    local config_path="$2"
    
    log_step "Sauvegarde de la configuration"
    
    # Créer le répertoire si nécessaire
    mkdir -p "$(dirname "$config_path")"
    
    # Sauvegarder avec timestamp
    if [ -f "$config_path" ]; then
        local backup_path="${config_path}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$config_path" "$backup_path"
        log_info "Sauvegarde existante : $backup_path"
    fi
    
    # Écrire la nouvelle configuration
    echo "$config" > "$config_path"
    log_success "Configuration sauvegardée : $config_path"
}

# Fonction de validation de la configuration
validate_config() {
    local config_path="$1"
    
    log_step "Validation de la configuration"
    
    if [ ! -f "$config_path" ]; then
        log_error "Fichier de configuration non trouvé"
        return 1
    fi
    
    # Validation JSON basique
    if command -v python3 >/dev/null 2>&1; then
        if python3 -m json.tool "$config_path" >/dev/null 2>&1; then
            log_success "Configuration JSON valide"
        else
            log_error "Configuration JSON invalide"
            return 1
        fi
    else
        log_info "Python3 non disponible, validation JSON ignorée"
    fi
    
    # Vérifier que les serveurs existent
    local servers_valid=true
    
    while IFS= read -r line; do
        if echo "$line" | grep -q '"command"'; then
            local command_path=$(echo "$line" | sed 's/.*"command": *"\([^"]*\)".*/\1/')
            if [ ! -x "$command_path" ]; then
                log_warning "Commande non exécutable : $command_path"
                servers_valid=false
            fi
        fi
        
        if echo "$line" | grep -q '"args"'; then
            local args_line="$line"
            # Extraire le premier argument (chemin du script)
            local script_path=$(echo "$args_line" | sed 's/.*\[\s*"\([^"]*\)".*/\1/')
            if [ ! -f "$script_path" ]; then
                log_warning "Script serveur non trouvé : $script_path"
                servers_valid=false
            fi
        fi
    done < "$config_path"
    
    if [ "$servers_valid" = true ]; then
        log_success "Tous les serveurs sont accessibles"
        return 0
    else
        log_warning "Certains serveurs ne sont pas accessibles"
        return 1
    fi
}

# Fonction de test des serveurs
test_servers() {
    log_step "Test des serveurs MCP"
    
    # Test serveur terminal shell
    if [ -f "$SCRIPT_DIR/shell-native/aklo-terminal.sh" ]; then
        echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | \
            timeout 5 "$SCRIPT_DIR/shell-native/aklo-terminal.sh" | \
            grep -q '"tools"' && \
            log_success "Serveur terminal shell opérationnel" || \
            log_warning "Serveur terminal shell ne répond pas"
    fi
    
    # Test serveur documentation shell
    if [ -f "$SCRIPT_DIR/shell-native/aklo-documentation.sh" ]; then
        echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | \
            timeout 5 "$SCRIPT_DIR/shell-native/aklo-documentation.sh" | \
            grep -q '"tools"' && \
            log_success "Serveur documentation shell opérationnel" || \
            log_warning "Serveur documentation shell ne répond pas"
    fi
    
    # Test serveurs Node.js si disponibles
    if command -v node >/dev/null 2>&1; then
        for server in terminal documentation; do
            local server_path="$SCRIPT_DIR/$server/index.js"
            if [ -f "$server_path" ]; then
                if timeout 5 node -e "
                    const server = require('$server_path');
                    console.log('Server $server loaded successfully');
                " 2>/dev/null; then
                    log_success "Serveur $server Node.js opérationnel"
                else
                    log_warning "Serveur $server Node.js a des problèmes"
                fi
            fi
        done
    fi
}

# Fonction d'affichage des instructions finales
show_final_instructions() {
    local config_path="$1"
    
    echo -e "\n${GREEN}🎉 Installation terminée avec succès !${NC}"
    echo "$(printf '%.0s═' {1..50})"
    
    echo -e "\n${YELLOW}📋 Configuration générée :${NC}"
    echo "   $config_path"
    
    echo -e "\n${YELLOW}🔧 Prochaines étapes :${NC}"
    echo "1. Ouvrez Cursor"
    echo "2. Allez dans les paramètres MCP"
    echo "3. Importez ou copiez le contenu de : $config_path"
    echo "4. Redémarrez Cursor"
    echo "5. Testez avec une commande aklo dans le chat"
    
    echo -e "\n${YELLOW}🧪 Test rapide :${NC}"
    echo "Dans le chat Cursor, essayez :"
    echo "• 'Exécute aklo status'"
    echo "• 'Montre-moi le protocole 02-ARCHITECTURE'"
    echo "• 'Liste tous les protocoles Aklo'"
    
    echo -e "\n${CYAN}💡 Informations :${NC}"
    echo "• Configuration automatique avec fallback intelligent"
    echo "• Serveurs Node.js si disponible, sinon shell natif"
    echo "• Sauvegarde automatique des configurations existantes"
    echo "• Tests de validation inclus"
    
    if [ -f "$config_path" ]; then
        echo -e "\n${BLUE}📄 Contenu de la configuration :${NC}"
        cat "$config_path"
    fi
}

# Fonction principale
main() {
    show_banner
    
    log_info "Répertoire d'installation : $SCRIPT_DIR"
    log_info "Configuration cible : $CONFIG_FILE"
    
    # Étape 1: Détection et génération de configuration
    local config_json
    if config_json=$(detect_and_configure); then
        log_success "Détection réussie"
    else
        log_error "Échec de la détection, abandon"
        exit 1
    fi
    
    # Étape 2: Sauvegarde de la configuration
    save_config "$config_json" "$CONFIG_FILE"
    
    # Étape 3: Validation
    if validate_config "$CONFIG_FILE"; then
        log_success "Configuration validée"
    else
        log_warning "Configuration avec avertissements"
    fi
    
    # Étape 4: Test des serveurs
    test_servers
    
    # Étape 5: Instructions finales
    show_final_instructions "$CONFIG_FILE"
    
    echo -e "\n${GREEN}✨ Setup Aklo MCP terminé !${NC}"
}

# Gestion des options
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Affiche cette aide"
        echo "  --config PATH  Spécifie un chemin de configuration personnalisé"
        echo "  --test-only    Exécute seulement les tests"
        echo ""
        echo "Ce script configure automatiquement les serveurs MCP Aklo avec"
        echo "une logique de fallback intelligent (Node.js → Shell natif)."
        exit 0
        ;;
    --config)
        CONFIG_FILE="$2"
        shift 2
        ;;
    --test-only)
        test_servers
        exit 0
        ;;
esac

# Exécution principale
main "$@"