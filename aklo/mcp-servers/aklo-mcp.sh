#!/bin/bash
#==============================================================================
# AKLO MCP - Script principal universel
# Point d'entrée unique pour tous les serveurs MCP Aklo
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════╗
    ║                🤖 AKLO MCP                       ║
    ║          Serveurs MCP Universels                 ║
    ║     Node.js + Shell • Multi-clients              ║
    ╚══════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_help() {
    show_banner
    cat << EOF
${YELLOW}Usage:${NC} $0 <commande> [options]

${BLUE}📋 COMMANDES PRINCIPALES${NC}
  ${GREEN}config <client>${NC}     Génère configuration pour un client MCP
  ${GREEN}install${NC}             Installation complète avec tests
  ${GREEN}test${NC}                Tests des serveurs
  ${GREEN}demo${NC}                Démonstrations interactives
  ${GREEN}status${NC}              Statut des serveurs

${BLUE}🌍 CLIENTS SUPPORTÉS${NC}
  claude-desktop          Configuration Claude Desktop
  cursor                  Configuration Cursor
  vscode                  Configuration VS Code
  generic                 Configuration JSON générique
  cli                     Commandes ligne de commande
  all                     Toutes les configurations

${BLUE}🧪 TESTS ET DÉMOS${NC}
  ${GREEN}test fallback${NC}       Test système de fallback
  ${GREEN}test servers${NC}        Test serveurs uniquement
  ${GREEN}demo multi${NC}          Démo multi-clients
  ${GREEN}demo fallback${NC}       Démo système de fallback

${BLUE}⚙️  OPTIONS${NC}
  --node-only             Force serveurs Node.js
  --shell-only            Force serveurs Shell
  --help, -h              Affiche cette aide

${BLUE}💡 EXEMPLES${NC}
  $0 config claude-desktop    # Config pour Claude Desktop
  $0 config cursor           # Config pour Cursor
  $0 install                 # Installation complète
  $0 test                    # Tests rapides
  $0 demo multi              # Démo multi-clients
  $0 status                  # Statut système

${CYAN}🚀 Installation rapide : $0 install${NC}
EOF
}

cmd_config() {
    local client="$1"
    shift
    
    if [ -z "$client" ]; then
        echo -e "${YELLOW}Clients disponibles :${NC}"
        echo "  claude-desktop, cursor, vscode, generic, cli, all"
        echo ""
        echo -e "${BLUE}Usage :${NC} $0 config <client>"
        return 1
    fi
    
    echo -e "${BLUE}🔧 Configuration MCP pour : $client${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    "$SCRIPT_DIR/generate-config-universal.sh" "$client" "$@"
}

cmd_install() {
    echo -e "${BLUE}🚀 Installation complète des serveurs MCP Aklo${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    "$SCRIPT_DIR/setup-mcp.sh" "$@"
}

cmd_test() {
    local test_type="$1"
    
    case "$test_type" in
        "fallback")
            echo -e "${BLUE}🧪 Test du système de fallback${NC}"
            "$SCRIPT_DIR/test-fallback.sh"
            ;;
        "servers")
            echo -e "${BLUE}🧪 Test des serveurs uniquement${NC}"
            "$SCRIPT_DIR/setup-mcp.sh" --test-only
            ;;
        "")
            echo -e "${BLUE}🧪 Tests rapides${NC}"
            echo "$(printf '%.0s─' {1..30})"
            
            # Test serveurs shell (toujours disponibles)
            echo -e "${YELLOW}Test serveurs shell natifs :${NC}"
            if echo '{"method":"tools/list"}' | "$SCRIPT_DIR/shell-native/aklo-terminal.sh" >/dev/null 2>&1; then
                echo "✅ Serveur terminal shell OK"
            else
                echo "❌ Serveur terminal shell KO"
            fi
            
            if echo '{"method":"tools/list"}' | "$SCRIPT_DIR/shell-native/aklo-documentation.sh" >/dev/null 2>&1; then
                echo "✅ Serveur documentation shell OK"
            else
                echo "❌ Serveur documentation shell KO"
            fi
            
            # Test Node.js si disponible
            if command -v node >/dev/null 2>&1; then
                echo -e "\n${YELLOW}Test serveurs Node.js :${NC}"
                echo "✅ Node.js $(node --version) disponible"
                echo "✅ Serveurs Node.js prêts"
            else
                echo -e "\n${YELLOW}Node.js non disponible, utilisation shell natif${NC}"
            fi
            ;;
        *)
            echo "❌ Type de test inconnu: $test_type"
            echo "Types disponibles: fallback, servers"
            return 1
            ;;
    esac
}

cmd_demo() {
    local demo_type="$1"
    
    case "$demo_type" in
        "multi")
            echo -e "${BLUE}🎭 Démonstration multi-clients${NC}"
            "$SCRIPT_DIR/demo-multi-clients.sh"
            ;;
        "fallback")
            echo -e "${BLUE}🎭 Démonstration fallback${NC}"
            "$SCRIPT_DIR/demo-fallback.sh"
            ;;
        "")
            echo -e "${YELLOW}Démos disponibles :${NC}"
            echo "  multi     - Démonstration multi-clients"
            echo "  fallback  - Démonstration système de fallback"
            echo ""
            echo -e "${BLUE}Usage :${NC} $0 demo <type>"
            return 1
            ;;
        *)
            echo "❌ Type de démo inconnu: $demo_type"
            echo "Types disponibles: multi, fallback"
            return 1
            ;;
    esac
}

cmd_status() {
    echo -e "${BLUE}📊 Statut des serveurs MCP Aklo${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    # Environnement
    echo -e "${YELLOW}Environnement :${NC}"
    if command -v node >/dev/null 2>&1; then
        echo "✅ Node.js $(node --version)"
        if command -v npm >/dev/null 2>&1; then
            echo "✅ npm $(npm --version)"
        else
            echo "❌ npm non disponible"
        fi
    else
        echo "❌ Node.js non disponible"
    fi
    
    # Serveurs disponibles
    echo -e "\n${YELLOW}Serveurs disponibles :${NC}"
    
    # Shell natifs (toujours disponibles)
    if [ -x "$SCRIPT_DIR/shell-native/aklo-terminal.sh" ]; then
        echo "✅ Serveur terminal shell natif"
    else
        echo "❌ Serveur terminal shell natif manquant"
    fi
    
    if [ -x "$SCRIPT_DIR/shell-native/aklo-documentation.sh" ]; then
        echo "✅ Serveur documentation shell natif"
    else
        echo "❌ Serveur documentation shell natif manquant"
    fi
    
    # Node.js
    if [ -f "$SCRIPT_DIR/terminal/index.js" ] && [ -f "$SCRIPT_DIR/terminal/package.json" ]; then
        echo "✅ Serveur terminal Node.js"
    else
        echo "❌ Serveur terminal Node.js manquant"
    fi
    
    if [ -f "$SCRIPT_DIR/documentation/index.js" ] && [ -f "$SCRIPT_DIR/documentation/package.json" ]; then
        echo "✅ Serveur documentation Node.js"
    else
        echo "❌ Serveur documentation Node.js manquant"
    fi
    
    # Configuration recommandée
    echo -e "\n${YELLOW}Configuration recommandée :${NC}"
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
        echo "🎯 Serveurs Node.js (fonctionnalités complètes)"
        echo "   Générer avec: $0 config <client>"
    else
        echo "🐚 Serveurs Shell natifs (fallback)"
        echo "   Générer avec: $0 config <client> --shell-only"
    fi
    
    # Scripts utilitaires
    echo -e "\n${YELLOW}Scripts disponibles :${NC}"
    local scripts=("setup-mcp.sh" "generate-config-universal.sh" "test-fallback.sh" "demo-multi-clients.sh" "demo-fallback.sh")
    
    for script in "${scripts[@]}"; do
        if [ -x "$SCRIPT_DIR/$script" ]; then
            echo "✅ $script"
        else
            echo "❌ $script manquant"
        fi
    done
}

# Fonction principale
main() {
    local command="$1"
    shift
    
    case "$command" in
        "config")
            cmd_config "$@"
            ;;
        "install")
            cmd_install "$@"
            ;;
        "test")
            cmd_test "$@"
            ;;
        "demo")
            cmd_demo "$@"
            ;;
        "status")
            cmd_status "$@"
            ;;
        "help"|"--help"|"-h"|"")
            show_help
            ;;
        *)
            echo "❌ Commande inconnue: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"