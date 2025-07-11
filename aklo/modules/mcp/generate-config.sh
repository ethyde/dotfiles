#!/usr/bin/env bash
#==============================================================================
# Générateur de configuration MCP propre (JSON uniquement)
# Logique Native-First : Shell principal, Node.js bonus
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIN_NODE_MAJOR=16

# Fonction de détection Node.js silencieuse (pour bonus uniquement)
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

# Fonction de génération de config Shell (principale)
generate_shell_config() {
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
}

# Fonction de génération de config Node.js (étendue)
generate_node_config() {
    local node_path=$(which node)
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
    },
    "aklo-terminal-node": {
      "command": "$node_path",
      "args": ["$SCRIPT_DIR/terminal/index.js"]
    },
    "aklo-documentation-node": {
      "command": "$node_path",
      "args": ["$SCRIPT_DIR/documentation/index.js"]
    }
  }
}
EOF
}

# Génération principale (Native-First)
main() {
    # Toujours inclure les serveurs shell natifs (principal)
    # Ajouter Node.js si disponible (bonus)
    if detect_node_quiet; then
        generate_node_config  # Shell + Node.js
    else
        generate_shell_config  # Shell uniquement
    fi
}

main "$@"