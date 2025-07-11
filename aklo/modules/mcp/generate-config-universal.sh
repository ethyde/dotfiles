#!/usr/bin/env bash
#==============================================================================
# Générateur de configuration MCP universel
# Support multi-clients : Claude Desktop, Cursor, VS Code, CLI, etc.
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIN_NODE_MAJOR=16

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_help() {
    cat << EOF
🤖 Générateur de configuration MCP Aklo universel

Usage: $0 [CLIENT] [OPTIONS]

Clients supportés:
  claude-desktop    Configuration pour Claude Desktop
  cursor           Configuration pour Cursor  
  vscode           Configuration pour VS Code MCP
  generic          Configuration JSON générique
  cli              Commandes CLI pour test direct
  all              Génère toutes les configurations

Options:
  --node-only      Force l'utilisation des serveurs Node.js
  --shell-only     Force l'utilisation des serveurs shell natifs
  --help, -h       Affiche cette aide

Exemples:
  $0 claude-desktop     # Config pour Claude Desktop
  $0 cursor            # Config pour Cursor
  $0 generic           # JSON générique
  $0 cli               # Commandes de test CLI
  $0 all               # Toutes les configs
EOF
}

# Détection Node.js silencieuse
detect_node_quiet() {
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version 2>/dev/null)
        if [ -n "$node_version" ]; then
            local major_version=$(echo "$node_version" | sed 's/v\([0-9]*\).*/\1/')
            if [ "$major_version" -ge "$MIN_NODE_MAJOR" ] && command -v npm >/dev/null 2>&1; then
                return 0
            fi
        fi
    fi
    return 1
}

# Configuration Claude Desktop
generate_claude_desktop() {
    local use_node="$1"
    
    echo "# Configuration pour Claude Desktop"
    echo "# Fichier: ~/.claude_desktop_config.json"
    echo ""
    
    if [ "$use_node" = "true" ]; then
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
    else
        cat << EOF
{
  "mcpServers": {
    "aklo-terminal": {
      "command": "sh",
      "args": ["$SCRIPT_DIR/shell-native/aklo-terminal.sh"]
    },
    "aklo-documentation": {
      "command": "sh",
      "args": ["$SCRIPT_DIR/shell-native/aklo-documentation.sh"]
    }
  }
}
EOF
    fi
}

# Configuration Cursor
generate_cursor() {
    local use_node="$1"
    
    echo "# Configuration pour Cursor"
    echo "# Fichier: Settings > MCP Servers"
    echo ""
    
    generate_claude_desktop "$use_node"
}

# Configuration VS Code
generate_vscode() {
    local use_node="$1"
    
    echo "# Configuration pour VS Code avec extension MCP"
    echo "# Fichier: settings.json"
    echo ""
    
    if [ "$use_node" = "true" ]; then
        local node_path=$(which node)
        cat << EOF
{
  "mcp.servers": {
    "aklo-terminal": {
      "command": "$node_path",
      "args": ["$SCRIPT_DIR/terminal/index.js"],
      "description": "Aklo Terminal MCP Server"
    },
    "aklo-documentation": {
      "command": "$node_path",
      "args": ["$SCRIPT_DIR/documentation/index.js"],
      "description": "Aklo Documentation MCP Server"
    }
  }
}
EOF
    else
        cat << EOF
{
  "mcp.servers": {
    "aklo-terminal": {
      "command": "sh",
      "args": ["$SCRIPT_DIR/shell-native/aklo-terminal.sh"],
      "description": "Aklo Terminal MCP Server (Shell)"
    },
    "aklo-documentation": {
      "command": "sh",
      "args": ["$SCRIPT_DIR/shell-native/aklo-documentation.sh"],
      "description": "Aklo Documentation MCP Server (Shell)"
    }
  }
}
EOF
    fi
}

# Configuration générique
generate_generic() {
    local use_node="$1"
    
    echo "# Configuration MCP générique"
    echo "# Compatible avec tout client MCP standard"
    echo ""
    
    generate_claude_desktop "$use_node"
}

# Commandes CLI pour test
generate_cli() {
    local use_node="$1"
    
    echo "# Commandes CLI pour tester les serveurs MCP"
    echo ""
    
    if [ "$use_node" = "true" ]; then
        local node_path=$(which node)
        cat << EOF
# Test serveur terminal Node.js
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | $node_path $SCRIPT_DIR/terminal/index.js

# Test serveur documentation Node.js  
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | $node_path $SCRIPT_DIR/documentation/index.js

# Exemple d'appel d'outil
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"aklo_status","arguments":{}}}' | $node_path $SCRIPT_DIR/terminal/index.js
EOF
    else
        cat << EOF
# Test serveur terminal shell
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | $SCRIPT_DIR/shell-native/aklo-terminal.sh

# Test serveur documentation shell
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | $SCRIPT_DIR/shell-native/aklo-documentation.sh

# Exemple d'appel d'outil
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"aklo_status_shell","arguments":{}}}' | $SCRIPT_DIR/shell-native/aklo-terminal.sh
EOF
    fi
}

# Génération de toutes les configurations
generate_all() {
    local use_node="$1"
    
    echo -e "${CYAN}🤖 Configurations MCP Aklo pour tous les clients${NC}"
    echo "$(printf '%.0s═' {1..60})"
    
    if [ "$use_node" = "true" ]; then
        echo -e "${GREEN}✅ Mode: Serveurs Node.js (fonctionnalités complètes)${NC}"
    else
        echo -e "${YELLOW}🐚 Mode: Serveurs Shell natifs (fallback)${NC}"
    fi
    
    echo ""
    
    # Claude Desktop
    echo -e "${BLUE}📱 CLAUDE DESKTOP${NC}"
    echo "$(printf '%.0s─' {1..30})"
    generate_claude_desktop "$use_node"
    echo ""
    
    # Cursor
    echo -e "${BLUE}🖱️  CURSOR${NC}"
    echo "$(printf '%.0s─' {1..30})"
    generate_cursor "$use_node"
    echo ""
    
    # VS Code
    echo -e "${BLUE}📝 VS CODE${NC}"
    echo "$(printf '%.0s─' {1..30})"
    generate_vscode "$use_node"
    echo ""
    
    # CLI
    echo -e "${BLUE}💻 LIGNE DE COMMANDE${NC}"
    echo "$(printf '%.0s─' {1..30})"
    generate_cli "$use_node"
    echo ""
    
    echo -e "${CYAN}💡 Autres clients MCP compatibles :${NC}"
    echo "• Continue Dev"
    echo "• Zed Editor (avec extension MCP)"
    echo "• Clients MCP personnalisés"
    echo "• Intégrations API directes"
}

# Fonction principale
main() {
    local client="${1:-generic}"
    local force_mode=""
    
    # Parser les options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --node-only)
                force_mode="node"
                shift
                ;;
            --shell-only)
                force_mode="shell"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                if [ -z "$client" ] || [ "$client" = "generic" ]; then
                    client="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Déterminer le mode (Node.js ou shell)
    local use_node="false"
    
    case "$force_mode" in
        "node")
            if detect_node_quiet; then
                use_node="true"
            else
                echo -e "${YELLOW}⚠️  Node.js forcé mais non disponible, utilisation du shell${NC}" >&2
            fi
            ;;
        "shell")
            use_node="false"
            ;;
        *)
            if detect_node_quiet; then
                use_node="true"
            fi
            ;;
    esac
    
    # Générer la configuration selon le client
    case "$client" in
        "claude-desktop"|"claude")
            generate_claude_desktop "$use_node"
            ;;
        "cursor")
            generate_cursor "$use_node"
            ;;
        "vscode"|"vs-code")
            generate_vscode "$use_node"
            ;;
        "generic")
            generate_generic "$use_node"
            ;;
        "cli"|"command-line")
            generate_cli "$use_node"
            ;;
        "all")
            generate_all "$use_node"
            ;;
        *)
            echo "❌ Client non supporté: $client" >&2
            echo "Utilisez --help pour voir les clients disponibles" >&2
            exit 1
            ;;
    esac
}

main "$@"