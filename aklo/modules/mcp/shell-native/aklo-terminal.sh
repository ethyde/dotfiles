#!/bin/sh
#==============================================================================
# Serveur MCP Terminal Aklo - Version Shell Native
# Alternative sans dépendance Node.js
#==============================================================================

# Protocole MCP simplifié en shell
# Lit les requêtes JSON depuis stdin et retourne des réponses JSON

handle_request() {
    local request="$1"
    
    # Parser basique JSON en shell (limité mais fonctionnel)
    local method=$(echo "$request" | grep -o '"method":"[^"]*"' | cut -d'"' -f4)
    local tool_name=$(echo "$request" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
    
    case "$method" in
        "tools/list")
            cat << 'EOF'
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "tools": [
      {
        "name": "aklo_execute_shell",
        "description": "Execute aklo commands via shell",
        "inputSchema": {
          "type": "object",
          "properties": {
            "command": {"type": "string"},
            "args": {"type": "array", "items": {"type": "string"}}
          }
        }
      },
      {
        "name": "aklo_status_shell", 
        "description": "Get project status via shell",
        "inputSchema": {"type": "object", "properties": {}}
      }
    ]
  }
}
EOF
            ;;
        "tools/call")
            case "$tool_name" in
                "aklo_execute_shell")
                    handle_aklo_execute "$request"
                    ;;
                "aklo_status_shell")
                    handle_aklo_status "$request"
                    ;;
                *)
                    echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32601,"message":"Unknown tool"}}'
                    ;;
            esac
            ;;
        *)
            echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32601,"message":"Unknown method"}}'
            ;;
    esac
}

handle_aklo_execute() {
    local request="$1"
    
    # Extraire la commande (parsing JSON basique)
    local command=$(echo "$request" | grep -o '"command":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$command" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32602,"message":"Missing command"}}'
        return
    fi
    
    # Exécuter la commande aklo
    local aklo_path="$(dirname "$0")/../../bin/aklo"
    local output
    
    if [ -x "$aklo_path" ]; then
        output=$("$aklo_path" "$command" 2>&1)
        local exit_code=$?
        
        # Échapper les guillemets et retours à la ligne pour JSON
        output=$(echo "$output" | sed 's/"/\\"/g' | tr '\n' '\\' | sed 's/\\/\\n/g')
        
        cat << EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "Command: aklo $command\\nExit code: $exit_code\\n\\nOutput:\\n$output"
      }
    ]
  }
}
EOF
    else
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32603,"message":"Aklo script not found"}}'
    fi
}

handle_aklo_status() {
    local status="Project Status:\\n"
    
    # Vérifier si aklo est initialisé
    if [ -f ".aklo.conf" ]; then
        status="${status}✅ Aklo initialized\\n"
        
        # Lire la config
        local workdir=$(grep "PROJECT_WORKDIR=" .aklo.conf | cut -d'=' -f2)
        status="${status}📁 Workdir: $workdir\\n"
    else
        status="${status}❌ Aklo not initialized\\n"
    fi
    
    # Vérifier Git
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        status="${status}🌿 Git branch: $branch\\n"
    else
        status="${status}🌿 Git: Not initialized\\n"
    fi
    
    # Compter les PBI
    if [ -d "docs/backlog/00-pbi" ]; then
        local pbi_count=$(find docs/backlog/00-pbi -name "PBI-*.md" 2>/dev/null | wc -l | tr -d ' ')
        status="${status}📋 PBI count: $pbi_count\\n"
    else
        status="${status}📋 PBI: No backlog found\\n"
    fi
    
    cat << EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "$status"
      }
    ]
  }
}
EOF
}

# Boucle principale pour lire les requêtes
main() {
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            handle_request "$line"
        fi
    done
}

# Démarrer le serveur
main