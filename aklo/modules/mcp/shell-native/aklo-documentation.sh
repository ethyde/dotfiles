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
      },
      {
        "name": "read_artefact",
        "description": "Read and analyze a specific artefact with metadata extraction",
        "inputSchema": {
          "type": "object",
          "properties": {
            "artefact_path": {
              "type": "string",
              "description": "Path to the artefact file to read"
            },
            "extract_metadata": {
              "type": "boolean",
              "description": "Whether to extract metadata from the artefact",
              "default": true
            }
          },
          "required": ["artefact_path"]
        }
      },
      {
        "name": "validate_artefact",
        "description": "Validate artefact structure according to Aklo protocols",
        "inputSchema": {
          "type": "object",
          "properties": {
            "artefact_path": {
              "type": "string",
              "description": "Path to the artefact file to validate"
            },
            "artefact_type": {
              "type": "string",
              "description": "Type of artefact (PBI, TASK, DEBUG, ARCH, REVIEW)",
              "enum": ["PBI", "TASK", "DEBUG", "ARCH", "REVIEW"]
            }
          },
          "required": ["artefact_path", "artefact_type"]
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
                "read_artefact")
                    handle_read_artefact "$request"
                    ;;
                "validate_artefact")
                    handle_validate_artefact "$request"
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

handle_read_artefact() {
    local request="$1"
    
    # Extraire les paramètres
    local artefact_path=$(echo "$request" | grep -o '"artefact_path":"[^"]*"' | cut -d'"' -f4)
    local extract_metadata=$(echo "$request" | grep -o '"extract_metadata":"[^"]*"' | cut -d'"' -f4)
    
    # Valeur par défaut pour extract_metadata
    if [ -z "$extract_metadata" ]; then
        extract_metadata="true"
    fi
    
    # Validation du chemin
    if [ -z "$artefact_path" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32602,"message":"Missing artefact_path parameter"}}'
        return
    fi
    
    if [ ! -f "$artefact_path" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32603,"message":"Artefact file not found"}}'
        return
    fi
    
    # Lire le contenu du fichier
    local content=$(cat "$artefact_path" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32603,"message":"Cannot read artefact file"}}'
        return
    fi
    
    # Préparer le résultat
    local result="📄 Artefact: $(basename "$artefact_path")\n"
    result="${result}📁 Chemin: $artefact_path\n\n"
    
    # Extraction des métadonnées si demandée
    if [ "$extract_metadata" = "true" ]; then
        local metadata=$(extract_artefact_metadata "$content")
        if [ -n "$metadata" ]; then
            result="${result}📊 Métadonnées:\n$metadata\n"
        fi
    fi
    
    result="${result}📝 Contenu:\n\n$content"
    
    # Échapper le contenu pour JSON
    local escaped_result=$(echo "$result" | sed 's/"/\\"/g' | tr '\n' '\\' | sed 's/\\/\\n/g')
    
    cat << EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "$escaped_result"
      }
    ]
  }
}
EOF
}

handle_validate_artefact() {
    local request="$1"
    
    # Extraire les paramètres
    local artefact_path=$(echo "$request" | grep -o '"artefact_path":"[^"]*"' | cut -d'"' -f4)
    local artefact_type=$(echo "$request" | grep -o '"artefact_type":"[^"]*"' | cut -d'"' -f4)
    
    # Validation des paramètres
    if [ -z "$artefact_path" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32602,"message":"Missing artefact_path parameter"}}'
        return
    fi
    
    if [ -z "$artefact_type" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32602,"message":"Missing artefact_type parameter"}}'
        return
    fi
    
    if [ ! -f "$artefact_path" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32603,"message":"Artefact file not found"}}'
        return
    fi
    
    # Lire le contenu du fichier
    local content=$(cat "$artefact_path" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32603,"message":"Cannot read artefact file"}}'
        return
    fi
    
    # Préparer le rapport de validation
    local validation="✅ Validation de l'Artefact\n"
    validation="${validation}📄 Fichier: $(basename "$artefact_path")\n"
    validation="${validation}📋 Type: $artefact_type\n\n"
    
    # Effectuer la validation
    local issues=$(validate_artefact_structure "$content" "$artefact_type")
    
    if [ -z "$issues" ]; then
        validation="${validation}✅ Artefact valide selon les protocoles Aklo\n"
    else
        validation="${validation}⚠️  Problèmes détectés:\n\n$issues"
    fi
    
    # Échapper le contenu pour JSON
    local escaped_validation=$(echo "$validation" | sed 's/"/\\"/g' | tr '\n' '\\' | sed 's/\\/\\n/g')
    
    cat << EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "$escaped_validation"
      }
    ]
  }
}
EOF
}

extract_artefact_metadata() {
    local content="$1"
    local metadata=""
    
    # Extraire les métadonnées XML basiques
    local status=$(echo "$content" | grep -o '<status>[^<]*</status>' | sed 's/<[^>]*>//g' | head -1)
    local created_date=$(echo "$content" | grep -o '<created_date>[^<]*</created_date>' | sed 's/<[^>]*>//g' | head -1)
    local owner=$(echo "$content" | grep -o '<owner>[^<]*</owner>' | sed 's/<[^>]*>//g' | head -1)
    local priority=$(echo "$content" | grep -o '<priority>[^<]*</priority>' | sed 's/<[^>]*>//g' | head -1)
    
    # Métadonnées spécifiques aux TASK
    local pbi_id=$(echo "$content" | grep -o 'pbi_id="[^"]*"' | sed 's/.*pbi_id="\([^"]*\)".*/\1/' | head -1)
    local task_id=$(echo "$content" | grep -o 'task_id="[^"]*"' | sed 's/.*task_id="\([^"]*\)".*/\1/' | head -1)
    local parent_pbi=$(echo "$content" | grep -o '<parent_pbi>[^<]*</parent_pbi>' | sed 's/<[^>]*>//g' | head -1)
    local assignee=$(echo "$content" | grep -o '<assignee>[^<]*</assignee>' | sed 's/<[^>]*>//g' | head -1)
    local git_branch=$(echo "$content" | grep -o '<git_branch>[^<]*</git_branch>' | sed 's/<[^>]*>//g' | head -1)
    
    # Métadonnées communes
    if [ -n "$status" ]; then
        metadata="${metadata}   Status: $status\n"
    fi
    if [ -n "$created_date" ]; then
        metadata="${metadata}   Created Date: $created_date\n"
    fi
    if [ -n "$owner" ]; then
        metadata="${metadata}   Owner: $owner\n"
    fi
    if [ -n "$priority" ]; then
        metadata="${metadata}   Priority: $priority\n"
    fi
    
    # Métadonnées spécifiques aux TASK
    if [ -n "$pbi_id" ]; then
        metadata="${metadata}   PBI ID: $pbi_id\n"
    fi
    if [ -n "$task_id" ]; then
        metadata="${metadata}   Task ID: $task_id\n"
    fi
    if [ -n "$parent_pbi" ]; then
        metadata="${metadata}   Parent PBI: $parent_pbi\n"
    fi
    if [ -n "$assignee" ]; then
        metadata="${metadata}   Assignee: $assignee\n"
    fi
    if [ -n "$git_branch" ]; then
        metadata="${metadata}   Git Branch: $git_branch\n"
    fi
    
    echo "$metadata"
}

validate_artefact_structure() {
    local content="$1"
    local artefact_type="$2"
    local issues=""
    
    # Validations communes
    if ! echo "$content" | grep -q '<.*>'; then
        issues="${issues}❌ Structure XML invalide\n"
    fi
    
    # Validation du statut (balise ou attribut)
    if ! echo "$content" | grep -q '<status>[^<]*</status>' && ! echo "$content" | grep -q 'status="[^"]*"'; then
        issues="${issues}❌ Statut manquant dans les métadonnées\n"
    fi
    
    # Validations spécifiques par type
    case "$artefact_type" in
        "PBI")
            if ! echo "$content" | grep -q '<user_story>'; then
                issues="${issues}❌ Section 'user_story' manquante\n"
            fi
            if ! echo "$content" | grep -q '<acceptance_criteria>'; then
                issues="${issues}❌ Section 'acceptance_criteria' manquante\n"
            fi
            ;;
        "TASK")
            if ! echo "$content" | grep -q '<definition_of_done>'; then
                issues="${issues}❌ Section 'definition_of_done' manquante\n"
            fi
            if ! echo "$content" | grep -q 'pbi_id="[^"]*"'; then
                issues="${issues}❌ Attribut 'pbi_id' manquant\n"
            fi
            ;;
        "DEBUG")
            if ! echo "$content" | grep -q '<bug_description>'; then
                issues="${issues}❌ Section 'bug_description' manquante\n"
            fi
            ;;
        "ARCH")
            if ! echo "$content" | grep -q '<technical_approach>'; then
                issues="${issues}❌ Section 'technical_approach' manquante\n"
            fi
            ;;
        "REVIEW")
            if ! echo "$content" | grep -q '<review_findings>'; then
                issues="${issues}❌ Section 'review_findings' manquante\n"
            fi
            ;;
    esac
    
    echo "$issues"
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