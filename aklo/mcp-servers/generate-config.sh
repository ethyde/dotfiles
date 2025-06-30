#!/bin/bash
#==============================================================================
# Générateur de configuration MCP propre (JSON uniquement)
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIN_NODE_MAJOR=16

# Fonction de détection Node.js silencieuse
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

# Fonction de génération de config Node.js
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

# Fonction de génération de config Shell
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

# Génération principale
main() {
    if detect_node_quiet; then
        generate_node_config
    else
        generate_shell_config
    fi
}

main "$@"