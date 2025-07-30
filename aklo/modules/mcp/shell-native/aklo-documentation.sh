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
      },
      {
        "name": "project_documentation_summary",
        "description": "Generate comprehensive project documentation summary",
        "inputSchema": {
          "type": "object",
          "properties": {
            "project_path": {
              "type": "string",
              "description": "Path to the project directory"
            },
            "include_artefacts": {
              "type": "boolean",
              "description": "Whether to include detailed artefact counts",
              "default": true
            }
          },
          "required": ["project_path"]
        }
      },
      {
        "name": "server_info",
        "description": "Get server information and status",
        "inputSchema": {
          "type": "object",
          "properties": {}
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
                "project_documentation_summary")
                    handle_project_summary "$request"
                    ;;
                "server_info")
                    handle_server_info "$request"
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
    
    # Extraire les paramètres
    local keywords=$(echo "$request" | grep -o '"keywords":"[^"]*"' | cut -d'"' -f4)
    local scope=$(echo "$request" | grep -o '"scope":"[^"]*"' | cut -d'"' -f4)
    
    # Valeur par défaut pour scope
    if [ -z "$scope" ]; then
        scope="all"
    fi
    
    if [ -z "$keywords" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32602,"message":"Missing keywords"}}'
        return
    fi
    
    local search_results="🔍 Recherche: '$keywords' (scope: $scope)\\n\\n"
    local found_results=false
    
    # Rechercher selon le scope
    case "$scope" in
        "protocols")
            # Recherche uniquement dans les protocoles
            local charte_dir="$(pwd)/aklo/charte"
            if [ -d "$charte_dir/PROTOCOLES" ]; then
                for doc_file in "$charte_dir/PROTOCOLES"/*.xml; do
                    if [ -f "$doc_file" ]; then
                        local matches=$(grep -i "$keywords" "$doc_file" 2>/dev/null | head -3)
                        if [ -n "$matches" ]; then
                            found_results=true
                            local filename=$(basename "$doc_file")
                            search_results="${search_results}📄 Protocole: $filename\\n"
                            
                            echo "$matches" | while IFS= read -r line; do
                                local escaped_line=$(echo "$line" | sed 's/"/\\"/g' | cut -c1-100)
                                search_results="${search_results}  → $escaped_line\\n"
                            done
                            search_results="${search_results}\\n"
                        fi
                    fi
                done
            fi
            ;;
        "artefacts")
            # Recherche dans les artefacts du projet
            local project_root=$(pwd)
            local backlog_path="$project_root/docs/backlog"
            if [ -d "$backlog_path" ]; then
                for artefact_file in $(find "$backlog_path" -name "*.xml" 2>/dev/null); do
                    if [ -f "$artefact_file" ]; then
                        local matches=$(grep -i "$keywords" "$artefact_file" 2>/dev/null | head -2)
                        if [ -n "$matches" ]; then
                            found_results=true
                            local filename=$(basename "$artefact_file")
                            local relative_path=$(echo "$artefact_file" | sed "s|$project_root/||")
                            search_results="${search_results}📄 Artefact: $relative_path\\n"
                            
                            echo "$matches" | while IFS= read -r line; do
                                local escaped_line=$(echo "$line" | sed 's/"/\\"/g' | cut -c1-100)
                                search_results="${search_results}  → $escaped_line\\n"
                            done
                            search_results="${search_results}\\n"
                        fi
                    fi
                done
            fi
            ;;
        "all"|*)
            # Recherche dans tous les fichiers de documentation
            local charte_dir="$(pwd)/aklo/charte"
            if [ -d "$charte_dir" ]; then
                # Recherche dans les protocoles
                for doc_file in "$charte_dir"/*.xml "$charte_dir/PROTOCOLES"/*.xml; do
                    if [ -f "$doc_file" ]; then
                        local matches=$(grep -i "$keywords" "$doc_file" 2>/dev/null | head -3)
                        if [ -n "$matches" ]; then
                            found_results=true
                            local filename=$(basename "$doc_file")
                            search_results="${search_results}📄 $filename:\\n"
                            
                            echo "$matches" | while IFS= read -r line; do
                                local escaped_line=$(echo "$line" | sed 's/"/\\"/g' | cut -c1-100)
                                search_results="${search_results}  → $escaped_line\\n"
                            done
                            search_results="${search_results}\\n"
                        fi
                    fi
                done
                
                # Recherche dans les artefacts si disponible
                local project_root=$(pwd)
                local backlog_path="$project_root/docs/backlog"
                if [ -d "$backlog_path" ]; then
                    for artefact_file in $(find "$backlog_path" -name "*.xml" 2>/dev/null | head -5); do
                        if [ -f "$artefact_file" ]; then
                            local matches=$(grep -i "$keywords" "$artefact_file" 2>/dev/null | head -1)
                            if [ -n "$matches" ]; then
                                found_results=true
                                local filename=$(basename "$artefact_file")
                                local relative_path=$(echo "$artefact_file" | sed "s|$project_root/||")
                                search_results="${search_results}📄 Artefact: $relative_path\\n"
                                
                                echo "$matches" | while IFS= read -r line; do
                                    local escaped_line=$(echo "$line" | sed 's/"/\\"/g' | cut -c1-100)
                                    search_results="${search_results}  → $escaped_line\\n"
                                done
                                search_results="${search_results}\\n"
                            fi
                        fi
                    done
                fi
            fi
            ;;
    esac
    
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

handle_project_summary() {
    local request="$1"
    
    # Extraire les paramètres
    local project_path=$(echo "$request" | grep -o '"project_path":"[^"]*"' | cut -d'"' -f4)
    local include_artefacts=$(echo "$request" | grep -o '"include_artefacts":[^,}]*' | cut -d':' -f2 | tr -d '"')
    
    # Valeur par défaut pour include_artefacts
    if [ -z "$include_artefacts" ]; then
        include_artefacts="true"
    fi
    
    # Validation du chemin
    if [ -z "$project_path" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32602,"message":"Missing project_path parameter"}}'
        return
    fi
    
    if [ ! -d "$project_path" ]; then
        echo '{"jsonrpc":"2.0","id":1,"error":{"code":-32603,"message":"Project directory not found"}}'
        return
    fi
    
    # Préparer le résumé
    local summary="📊 Résumé de la Documentation du Projet\n"
    summary="${summary}📁 Projet: $project_path\n\n"
    
    # Vérifier la configuration Aklo
    if [ -f "$project_path/.aklo.conf" ]; then
        summary="${summary}✅ Projet initialisé avec Aklo\n\n"
    else
        summary="${summary}❌ Projet non initialisé avec Aklo\n\n"
    fi
    
    # Scanner les artefacts si demandé
    if [ "$include_artefacts" != "false" ]; then
        local backlog_path="$project_path/docs/backlog"
        if [ -d "$backlog_path" ]; then
            summary="${summary}📋 Artefacts du Projet:\n"
            
            # Définir les types d'artefacts à scanner
            local artefact_types=(
                "PBI:00-pbi:PBI-*.xml"
                "Tasks:01-tasks:TASK-*.xml"
                "Architecture:02-architecture:ARCH-*.xml"
                "Debug:04-debug:DEBUG-*.xml"
                "Reviews:07-reviews:REVIEW-*.xml"
                "Journal:15-journal:JOURNAL-*.xml"
            )
            
            for type_info in "${artefact_types[@]}"; do
                IFS=':' read -r type_name type_path type_pattern <<< "$type_info"
                local type_full_path="$backlog_path/$type_path"
                
                if [ -d "$type_full_path" ]; then
                    local count=$(find "$type_full_path" -name "$type_pattern" 2>/dev/null | wc -l)
                    summary="${summary}   $type_name: $count fichier(s)\n"
                else
                    summary="${summary}   $type_name: 0 fichier(s)\n"
                fi
            done
        else
            summary="${summary}📋 Artefacts: Répertoire docs/backlog/ non trouvé\n"
        fi
    fi
    
    # Échapper le contenu pour JSON
    local escaped_summary=$(echo "$summary" | sed 's/"/\\"/g' | tr '\n' '\\' | sed 's/\\/\\n/g')
    
    cat << EOF
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "$escaped_summary"
      }
    ]
  }
}
EOF
}

handle_server_info() {
    local request="$1"
    
    # Obtenir les informations du serveur
    local server_version="1.0.0"
    local start_time=$(date '+%Y-%m-%d %H:%M:%S')
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    local pid=$$
    local current_dir=$(pwd)
    local tools_count=7  # Nombre d'outils disponibles
    
    # Calculer l'uptime (simulation basique - toujours 0 car nouveau processus)
    local uptime="0m 0s"
    
    # Obtenir des informations système
    local system_info=$(uname -s)
    local shell_info=$(echo $SHELL)
    
    # Préparer le résultat
    local result="🤖 Serveur MCP Documentation Aklo\n\n"
    result="${result}📦 Version: $server_version\n"
    result="${result}🕐 Démarré: $start_time\n"
    result="${result}⏱️  Uptime: $uptime\n"
    result="${result}🔧 PID: $pid\n"
    result="${result}📁 Répertoire: $current_dir\n"
    result="${result}🛠️  Outils disponibles: $tools_count\n"
    result="${result}💻 Système: $system_info\n"
    result="${result}🐚 Shell: $shell_info\n\n"
    
    result="${result}💡 Pour redémarrer après modification:\n"
    result="${result}   cd aklo/modules/mcp/shell-native && ./aklo-documentation.sh\n\n"
    result="${result}🔍 Mode développement:\n"
    result="${result}   Utilisez directement le script shell natif\n"
    
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