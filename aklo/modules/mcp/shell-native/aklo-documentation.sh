#!/bin/sh
#==============================================================================
# Serveur MCP Documentation Aklo - Version Shell Native
# Alternative sans dépendance Node.js
#==============================================================================

# Chemin vers la charte Aklo
CHARTE_DIR="$(dirname "$0")/../../charte"

handle_request() {
    local request="$1"
    
    # Parser basique JSON en shell
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
        "name": "read_protocol_shell",
        "description": "Read specific Aklo protocol via shell",
        "inputSchema": {
          "type": "object",
          "properties": {
            "protocol_number": {"type": "string"},
            "protocol_name": {"type": "string"}
          }
        }
      },
      {
        "name": "list_protocols_shell",
        "description": "List all available protocols via shell",
        "inputSchema": {"type": "object", "properties": {}}
      },
      {
        "name": "search_documentation_shell",
        "description": "Search through documentation via shell",
        "inputSchema": {
          "type": "object",
          "properties": {
            "keywords": {"type": "string"}
          }
        }
      }
    ]
  }
}
EOF
            ;;
        "tools/call")
            case "$tool_name" in
                "read_protocol_shell")
                    handle_read_protocol "$request"
                    ;;
                "list_protocols_shell")
                    handle_list_protocols "$request"
                    ;;
                "search_documentation_shell")
                    handle_search_documentation "$request"
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

handle_read_protocol() {
    local request="$1"
    
    # Extraire les paramètres
    local protocol_number=$(echo "$request" | grep -o '"protocol_number":"[^"]*"' | cut -d'"' -f4)
    local protocol_name=$(echo "$request" | grep -o '"protocol_name":"[^"]*"' | cut -d'"' -f4)
    
    local protocol_file=""
    
    # Déterminer le fichier de protocole
    if [ -n "$protocol_number" ]; then
        # Recherche par numéro (ex: "02" -> "02-ARCHITECTURE.xml")
        protocol_file=$(find "$CHARTE_DIR/PROTOCOLES" -name "${protocol_number}-*.xml" 2>/dev/null | head -1)
    elif [ -n "$protocol_name" ]; then
        # Recherche par nom (insensible à la casse)
        protocol_file=$(find "$CHARTE_DIR/PROTOCOLES" -iname "*${protocol_name}*.xml" 2>/dev/null | head -1)
    fi
    
    if [ -z "$protocol_file" ] || [ ! -f "$protocol_file" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32603,"message":"Protocol not found"}}'
        return
    fi
    
    # Lire le contenu du protocole
    local content=$(cat "$protocol_file" 2>/dev/null | sed 's/"/\\"/g' | tr '\n' '\\' | sed 's/\\/\\n/g')
    local filename=$(basename "$protocol_file")
    
    cat << EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "📋 Protocole Aklo: $filename\\n\\n$content"
      }
    ]
  }
}
EOF
}

handle_list_protocols() {
    local protocols_list="📚 Protocoles Aklo disponibles:\\n\\n"
    
    if [ -d "$CHARTE_DIR/PROTOCOLES" ]; then
        # Lister tous les protocoles
        for protocol_file in "$CHARTE_DIR/PROTOCOLES"/*.xml; do
            if [ -f "$protocol_file" ]; then
                local filename=$(basename "$protocol_file")
                local title=$(head -1 "$protocol_file" 2>/dev/null | sed 's/^#* *//' || echo "Sans titre")
                protocols_list="${protocols_list}• $filename: $title\\n"
            fi
        done
    else
        protocols_list="${protocols_list}❌ Répertoire PROTOCOLES non trouvé\\n"
    fi
    
    # Ajouter les autres documents
    if [ -f "$CHARTE_DIR/00-CADRE-GLOBAL.xml" ]; then
        protocols_list="${protocols_list}\\n📖 Documents additionnels:\\n"
        protocols_list="${protocols_list}• 00-CADRE-GLOBAL.xml: Cadre global du protocole\\n"
    fi
    
    if [ -f "$CHARTE_DIR/../config/.aklo.conf" ]; then
        protocols_list="${protocols_list}• .aklo.conf: Configuration projet\\n"
    fi
    
    cat << EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "$protocols_list"
      }
    ]
  }
}
EOF
}

handle_search_documentation() {
    local request="$1"
    
    # Extraire les mots-clés
    local keywords=$(echo "$request" | grep -o '"keywords":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$keywords" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32602,"message":"Missing keywords"}}'
        return
    fi
    
    local search_results="🔍 Recherche: '$keywords'\\n\\n"
    local found_results=false
    
    # Rechercher dans tous les fichiers de documentation
    if [ -d "$CHARTE_DIR" ]; then
        # Recherche dans les protocoles
        for doc_file in "$CHARTE_DIR"/*.xml "$CHARTE_DIR/PROTOCOLES"/*.xml; do
            if [ -f "$doc_file" ]; then
                # Recherche insensible à la casse
                local matches=$(grep -i "$keywords" "$doc_file" 2>/dev/null | head -3)
                if [ -n "$matches" ]; then
                    found_results=true
                    local filename=$(basename "$doc_file")
                    search_results="${search_results}📄 $filename:\\n"
                    
                    # Ajouter les correspondances (limitées pour éviter la surcharge)
                    echo "$matches" | while IFS= read -r line; do
                        # Échapper pour JSON et limiter la longueur
                        local escaped_line=$(echo "$line" | sed 's/"/\\"/g' | cut -c1-100)
                        search_results="${search_results}  → $escaped_line\\n"
                    done
                    search_results="${search_results}\\n"
                fi
            fi
        done
    fi
    
    if [ "$found_results" = false ]; then
        search_results="${search_results}❌ Aucun résultat trouvé pour '$keywords'\\n"
        search_results="${search_results}\\n💡 Suggestions:\\n"
        search_results="${search_results}• Vérifiez l'orthographe\\n"
        search_results="${search_results}• Essayez des mots-clés plus généraux\\n"
        search_results="${search_results}• Utilisez list_protocols_shell pour voir tous les protocoles\\n"
    fi
    
    cat << EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text", 
        "text": "$search_results"
      }
    ]
  }
}
EOF
}

# Boucle principale
main() {
    while IFS= read -r line; do
        if [ -n "$line" ]; then
            handle_request "$line"
        fi
    done
}

# Démarrer le serveur
main