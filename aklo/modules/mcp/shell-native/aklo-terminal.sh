#!/bin/bash
#==============================================================================
# Aklo Terminal - Serveur de commandes shell sécurisé pour MCP
#
# Reçoit des requêtes JSON sur stdin pour exécuter des commandes shell
# de manière sécurisée et retourne le résultat sur stdout.
#==============================================================================

# Fonction pour logger les erreurs et quitter
log_error() {
    local message="$1"
    # Formatte l'erreur en JSON et l'envoie sur stderr
    jq -n --arg msg "$message" '{"status": "error", "message": $msg}' >&2
    exit 1
}

#==============================================================================
# Fonction : safe_shell
# Description :
#   Exécute une commande shell de façon sécurisée selon le protocole MCP.
#   - Valide la commande via une whitelist externe (commands.whitelist)
#   - Gère le timeout d’exécution
#   - Exécute dans un répertoire de travail spécifique
#   - Retourne un résultat JSON structuré (status, stdout, stderr, exit_code)
#
# Usage :
#   safe_shell
#   (attend un JSON sur stdin avec les champs suivants)
#
# Paramètres JSON attendus :
#   {
#     "command": "<commande shell>",
#     "workdir": "<répertoire de travail, optionnel>",
#     "timeout": <timeout en ms, optionnel>
#   }
#
# Sécurité :
#   - Seule la commande de base (ex: "ls" de "ls -l") est validée via la whitelist
#   - Toute commande non listée est rejetée
#   - Timeout par défaut à 30s si non précisé
#   - Exécution isolée dans le répertoire spécifié
#
# Protocole MCP :
#   - Respecte la structure de réponse JSON attendue par le serveur MCP
#   - Conforme à la charte Aklo (pas d’exécution hors whitelist, logs structurés)
#
# Limitations :
#   - Ne gère pas les pipes/redirects complexes (validation sur la commande de base uniquement)
#   - Dépend de jq et timeout
#==============================================================================
safe_shell() {
    # Déterminer le chemin du script pour un accès fiable aux fichiers de config
    local script_dir
    script_dir=$(cd "$(dirname "$0")" && pwd)
    local whitelist_file="$script_dir/../../../config/commands.whitelist"

    # Lire l'entrée JSON depuis stdin
    local input
    input=$(cat)
    
    # Valider que l'entrée n'est pas vide
    if [ -z "$input" ]; then
        log_error "Input JSON is empty"
    fi

    # Parser l'entrée JSON avec jq
    local command
    command=$(echo "$input" | jq -r '.command')
    local workdir
    workdir=$(echo "$input" | jq -r '.workdir // "."') # Défaut au répertoire courant
    local timeout_ms
    timeout_ms=$(echo "$input" | jq -r '.timeout')
    
    # Valider les entrées
    if [ "$command" = "null" ] || [ -z "$command" ]; then
        log_error "Missing 'command' in input JSON"
    fi

    # Extraire la commande de base (ex: 'ls' de 'ls -l')
    local base_cmd
    base_cmd=$(echo "$command" | awk '{print $1}')

    # Vérifier si la commande est dans la liste autorisée du fichier
    if [ ! -f "$whitelist_file" ]; then
        log_error "Whitelist file not found at: $whitelist_file"
    fi

    if ! grep -Fxq "$base_cmd" "$whitelist_file"; then
        log_error "Command '$base_cmd' is not in the allowed list."
    fi

    # Exécuter la commande avec un timeout dans le bon répertoire
    local stdout stderr exit_code
    local output
    
    # Convertir timeout en secondes pour la commande `timeout`
    local timeout_sec
    timeout_sec=$(echo "$timeout_ms / 1000" | bc -l)

    # Exécution dans un sous-shell pour isoler le `cd`
    output=$( (cd "$workdir" && timeout "$timeout_sec" bash -c "$command") 2> >(stderr=$(cat); echo "$stderr" >&2) )
    exit_code=$?
    stdout=$output

    # Formatter la sortie en JSON
    jq -n \
      --arg status "success" \
      --arg stdout "$stdout" \
      --arg stderr "$stderr" \
      --argjson exit_code "$exit_code" \
      '{"status": $status, "stdout": $stdout, "stderr": $stderr, "exit_code": $exit_code}'
}

#==============================================================================
# Fonction : project_info
# Description :
#   Retourne les informations projet (package.json, git, .aklo.conf, artefacts XML)
#   - Parsing JSON hybride (jq ou fallback natif)
#   - Extraction des infos package.json (name, version, description)
#   - Infos git (branche, status, remote)
#   - Lecture .aklo.conf (si présent)
#   - Comptage artefacts XML (PBI, TASK) par statut
#   - Retour JSON structuré conforme MCP
#
# Usage :
#   project_info
#   (attend un JSON sur stdin avec le champ optionnel workdir)
#
# Limitations :
#   - Fallback natif limité si jq absent
#   - Ne gère pas les sous-modules git
#==============================================================================
project_info() {
    # Déterminer le chemin du script pour un accès fiable
    local script_dir
    script_dir=$(cd "$(dirname "$0")" && pwd)
    # Lire l'entrée JSON depuis stdin
    local input
    input=$(cat)
    # Parsing workdir (jq ou fallback natif)
    local workdir
    if command -v jq >/dev/null 2>&1; then
        workdir=$(echo "$input" | jq -r '.workdir // "."')
    else
        workdir=$(echo "$input" | grep -o '"workdir"[ ]*:[ ]*"[^"]*"' | sed 's/.*: *"\([^"]*\)"/\1/')
        [ -z "$workdir" ] && workdir="."
    fi
    # Extraction package.json
    local pkg_file="$workdir/package.json"
    local pkg_name pkg_version pkg_desc
    if [ -f "$pkg_file" ]; then
        if command -v jq >/dev/null 2>&1; then
            pkg_name=$(jq -r '.name' "$pkg_file")
            pkg_version=$(jq -r '.version' "$pkg_file")
            pkg_desc=$(jq -r '.description' "$pkg_file")
        else
            pkg_name=$(grep '"name"' "$pkg_file" | head -1 | sed 's/.*: *"\([^"]*\)",*/\1/')
            pkg_version=$(grep '"version"' "$pkg_file" | head -1 | sed 's/.*: *"\([^"]*\)",*/\1/')
            pkg_desc=$(grep '"description"' "$pkg_file" | head -1 | sed 's/.*: *"\([^"]*\)",*/\1/')
        fi
    fi
    # Infos git
    local git_branch git_status git_remote
    if [ -d "$workdir/.git" ]; then
        git_branch=$(cd "$workdir" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
        git_status=$(cd "$workdir" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        git_remote=$(cd "$workdir" && git remote get-url origin 2>/dev/null)
    fi
    # Lecture .aklo.conf
    local aklo_conf_file="$workdir/aklo/config/.aklo.conf"
    local aklo_conf=""
    [ -f "$aklo_conf_file" ] && aklo_conf=$(cat "$aklo_conf_file")
    # Comptage artefacts XML (PBI, TASK) par statut
    local pbi_total pbi_proposed pbi_done task_total task_todo task_done
    pbi_total=$(find "$workdir/docs/backlog/00-pbi" -name 'PBI-*.xml' 2>/dev/null | wc -l | tr -d ' ')
    pbi_proposed=$(grep -l '<status>PROPOSED</status>' "$workdir/docs/backlog/00-pbi"/PBI-*.xml 2>/dev/null | wc -l | tr -d ' ')
    pbi_done=$(grep -l '<status>DONE</status>' "$workdir/docs/backlog/00-pbi"/PBI-*.xml 2>/dev/null | wc -l | tr -d ' ')
    task_total=$(find "$workdir/docs/backlog/01-tasks" -name 'TASK-*.xml' 2>/dev/null | wc -l | tr -d ' ')
    task_todo=$(grep -l '<status>TODO</status>' "$workdir/docs/backlog/01-tasks"/TASK-*.xml 2>/dev/null | wc -l | tr -d ' ')
    task_done=$(grep -l '<status>DONE</status>' "$workdir/docs/backlog/01-tasks"/TASK-*.xml 2>/dev/null | wc -l | tr -d ' ')
    # Retour JSON structuré
    jq -n --arg pkg_name "$pkg_name" --arg pkg_version "$pkg_version" --arg pkg_desc "$pkg_desc" \
          --arg git_branch "$git_branch" --arg git_status "$git_status" --arg git_remote "$git_remote" \
          --arg aklo_conf "$aklo_conf" \
          --argjson pbi_total "$pbi_total" --argjson pbi_proposed "$pbi_proposed" --argjson pbi_done "$pbi_done" \
          --argjson task_total "$task_total" --argjson task_todo "$task_todo" --argjson task_done "$task_done" \
          '{
            package: { name: $pkg_name, version: $pkg_version, description: $pkg_desc },
            git: { branch: $git_branch, status_count: $git_status, remote: $git_remote },
            aklo_conf: $aklo_conf,
            artefacts: {
              pbi: { total: $pbi_total, proposed: $pbi_proposed, done: $pbi_done },
              task: { total: $task_total, todo: $task_todo, done: $task_done }
            }
          }'
}

# Routeur de commande principal
main() {
    local tool_name="$1"
    case "$tool_name" in
        "safe_shell")
            safe_shell
            ;;
        "project_info")
            project_info
            ;;
        "tools/list")
            jq -n '{ tools: ["safe_shell", "project_info"] }'
            ;;
        *)
            log_error "Unknown tool: $tool_name"
            ;;
    esac
}

# Exécuter le routeur principal
main "$@"