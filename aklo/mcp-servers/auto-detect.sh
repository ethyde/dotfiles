#!/bin/bash
#==============================================================================
# Auto-détection et fallback intelligent pour serveurs MCP Aklo
# Logique : Node.js (si compatible) → Shell natif (fallback)
#==============================================================================

set -e

# Configuration des versions supportées
MIN_NODE_MAJOR=16
SUPPORTED_LTS=("lts/hydrogen" "lts/iron" "lts/jod")  # Node 18, 20, 22
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
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

# Fonction de détection Node.js
detect_node() {
    log_info "Détection de Node.js..."
    
    # Vérifier si node est disponible
    if ! command -v node >/dev/null 2>&1; then
        log_warning "Node.js non trouvé dans PATH"
        return 1
    fi
    
    # Obtenir la version
    local node_version=$(node --version 2>/dev/null)
    if [ -z "$node_version" ]; then
        log_error "Impossible d'obtenir la version Node.js"
        return 1
    fi
    
    # Extraire le numéro de version majeure
    local major_version=$(echo "$node_version" | sed 's/v\([0-9]*\).*/\1/')
    
    log_info "Node.js détecté : $node_version (majeure: $major_version)"
    
    # Vérifier la compatibilité
    if [ "$major_version" -ge "$MIN_NODE_MAJOR" ]; then
        log_success "Version Node.js compatible (>= v$MIN_NODE_MAJOR)"
        
        # Vérifier npm
        if command -v npm >/dev/null 2>&1; then
            local npm_version=$(npm --version 2>/dev/null)
            log_success "npm disponible : v$npm_version"
            return 0
        else
            log_warning "npm non disponible avec cette installation Node.js"
            return 1
        fi
    else
        log_warning "Version Node.js trop ancienne (v$major_version < v$MIN_NODE_MAJOR)"
        return 1
    fi
}

# Fonction de détection NVM et LTS
detect_nvm_lts() {
    log_info "Vérification NVM et versions LTS..."
    
    # Charger NVM si disponible
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        source "$HOME/.nvm/nvm.sh"
        log_info "NVM chargé"
        
        # Vérifier les versions LTS disponibles
        for lts in "${SUPPORTED_LTS[@]}"; do
            if nvm ls "$lts" >/dev/null 2>&1; then
                log_success "Version LTS disponible : $lts"
                
                # Utiliser cette version
                nvm use "$lts" >/dev/null 2>&1
                if detect_node; then
                    log_success "Basculé vers $lts avec succès"
                    return 0
                fi
            fi
        done
        
        log_warning "Aucune version LTS compatible trouvée dans NVM"
    else
        log_info "NVM non disponible"
    fi
    
    return 1
}

# Fonction de test des serveurs Node.js
test_node_servers() {
    log_info "Test des serveurs MCP Node.js..."
    
    local terminal_server="$SCRIPT_DIR/terminal"
    local doc_server="$SCRIPT_DIR/documentation"
    
    # Vérifier que les serveurs existent
    if [ ! -f "$terminal_server/package.json" ] || [ ! -f "$doc_server/package.json" ]; then
        log_error "Serveurs Node.js non trouvés ou incomplets"
        return 1
    fi
    
    # Vérifier les dépendances
    local deps_ok=true
    
    for server in "$terminal_server" "$doc_server"; do
        if [ ! -d "$server/node_modules" ]; then
            log_warning "Dépendances manquantes dans $server"
            log_info "Installation des dépendances..."
            
            cd "$server"
            if npm install >/dev/null 2>&1; then
                log_success "Dépendances installées pour $(basename "$server")"
            else
                log_error "Échec installation dépendances pour $(basename "$server")"
                deps_ok=false
            fi
            cd "$SCRIPT_DIR"
        fi
    done
    
    if [ "$deps_ok" = true ]; then
        log_success "Serveurs Node.js prêts"
        return 0
    else
        log_error "Problème avec les serveurs Node.js"
        return 1
    fi
}

# Fonction de génération de config MCP Node.js
generate_node_config() {
    local node_path=$(which node)
    
    cat << EOF
{
  "mcpServers": {
    "aklo-terminal": {
      "command": "$node_path",
      "args": ["$SCRIPT_DIR/terminal/index.js"]
    },
    "aklo-documentation": {
      "command": "$node_path", 
      "args": ["$SCRIPT_DIR/documentation/index.js"]
    }
  }
}
EOF
}

# Fonction de génération de config MCP Shell
generate_shell_config() {
    cat << EOF
{
  "mcpServers": {
    "aklo-terminal-shell": {
      "command": "sh",
      "args": ["$SCRIPT_DIR/shell-native/aklo-terminal.sh"]
    },
    "aklo-documentation-shell": {
      "command": "sh", 
      "args": ["$SCRIPT_DIR/shell-native/aklo-documentation.sh"]
    }
  }
}
EOF
}

# Fonction principale de détection et configuration
main() {
    echo "🔍 Auto-détection environnement MCP Aklo"
    echo "========================================"
    
    local use_node=false
    local detection_log=""
    
    # Étape 1: Détection Node.js direct
    if detect_node; then
        use_node=true
        detection_log="✅ Node.js système compatible détecté"
    else
        # Étape 2: Tentative NVM + LTS
        log_info "Tentative détection via NVM..."
        if detect_nvm_lts; then
            use_node=true
            detection_log="✅ Node.js via NVM/LTS détecté et configuré"
        else
            detection_log="⚠️  Node.js non disponible ou incompatible"
        fi
    fi
    
    # Étape 3: Test des serveurs si Node.js disponible
    if [ "$use_node" = true ]; then
        if test_node_servers; then
            log_success "🎯 Configuration : Serveurs Node.js MCP"
            echo ""
            echo "📋 Configuration MCP à ajouter :"
            echo "================================"
            generate_node_config
            echo ""
            echo "💡 Détails de détection :"
            echo "   $detection_log"
            echo "   Node.js: $(node --version)"
            echo "   npm: $(npm --version)"
            echo "   Chemin: $(which node)"
        else
            log_warning "Serveurs Node.js non fonctionnels, fallback vers shell"
            use_node=false
        fi
    fi
    
    # Étape 4: Fallback shell natif
    if [ "$use_node" = false ]; then
        log_warning "🐚 Configuration : Serveurs Shell natifs (fallback)"
        
        # Vérifier que les serveurs shell existent
        if [ ! -f "$SCRIPT_DIR/shell-native/aklo-terminal.sh" ]; then
            log_error "Serveur shell natif manquant, création..."
            # Ici on pourrait recréer le serveur si nécessaire
        fi
        
        echo ""
        echo "📋 Configuration MCP à ajouter :"
        echo "================================"
        generate_shell_config
        echo ""
        echo "💡 Raison du fallback :"
        echo "   $detection_log"
        echo "   → Utilisation des serveurs shell natifs (fonctionnalités limitées)"
    fi
    
    echo ""
    echo "🔧 Prochaines étapes :"
    echo "====================="
    if [ "$use_node" = true ]; then
        echo "1. Copiez la configuration MCP ci-dessus"
        echo "2. Ajoutez-la à votre fichier de configuration Cursor/MCP"
        echo "3. Redémarrez Cursor pour activer les serveurs"
        echo "4. Testez avec une commande aklo dans le chat"
    else
        echo "1. Copiez la configuration MCP ci-dessus (version shell)"
        echo "2. Ajoutez-la à votre fichier de configuration Cursor/MCP"  
        echo "3. Redémarrez Cursor pour activer les serveurs"
        echo "4. Pour plus de fonctionnalités, installez Node.js >= v$MIN_NODE_MAJOR"
        echo "   puis relancez ce script"
    fi
}

# Exécution si appelé directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi