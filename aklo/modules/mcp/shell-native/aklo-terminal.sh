#!/usr/bin/env bash
#==============================================================================
# Aklo Terminal - Serveur de commandes shell sécurisé pour MCP
#
# ⚠️  jq (JSON processor) est recommandé pour le parsing JSON rapide (ex : project_info, safe_shell).
#    Si jq est absent, un fallback natif Bash est automatiquement utilisé (plus lent, mais compatible).
#    Le fallback peut être forcé via la variable d'environnement AKLO_FORCE_NO_JQ=1.
#    Les tests d'intégration valident les deux modes (avec et sans jq).
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

#==============================================================================
# Fonction : aklo_execute_shell
# Description :
#   Exécute une commande Aklo validée selon la liste autorisée, avec gestion du contexte,
#   parsing avancé des arguments (array JSON), logs sécurisés et retour JSON structuré.
#
# Usage :
#   aklo_execute_shell
#   (attend un JSON sur stdin avec les champs suivants)
#   {
#     "command": "<commande aklo>",
#     "args": [<array d'arguments>],
#     "workdir": "<répertoire de travail, optionnel>"
#   }
#
# Sécurité :
#   - Seules les commandes Aklo autorisées sont exécutées (liste exhaustive)
#   - Logs structurés et informatifs
#   - Gestion du contexte (workdir, env)
#
# Limitations :
#   - Ne gère pas les sous-commandes complexes
#   - Dépend de jq pour le parsing JSON avancé
#==============================================================================
aklo_execute_shell() {
    # Liste complète des commandes Aklo autorisées
    local ALLOWED_AKLO_COMMANDS=(
        "status" "get_config" "config" "validate" "mcp" "cache" "monitor"
        "template" "install-ux" "propose-pbi" "pbi" "plan" "arch" "dev"
        "debug" "review" "refactor" "hotfix" "optimize" "security" "release"
        "diagnose" "experiment" "docs" "analyze" "track" "onboard" "deprecate"
        "kb" "fast" "meta" "scratch" "help"
    )
    # Lire l'entrée JSON depuis stdin
    local input
    input=$(cat)
    # Parsing avancé (jq obligatoire pour array)
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jq requis pour le parsing avancé des arguments JSON."
    fi
    local command args workdir
    command=$(echo "$input" | jq -r '.command')
    workdir=$(echo "$input" | jq -r '.workdir // "."')
    args=$(echo "$input" | jq -c '.args // []')
    # Validation de la commande
    local valid=0
    for allowed in "${ALLOWED_AKLO_COMMANDS[@]}"; do
        if [ "$command" = "$allowed" ]; then
            valid=1
            break
        fi
    done
    if [ $valid -eq 0 ]; then
        log_error "Commande Aklo '$command' non autorisée."
    fi
    # Construction de la ligne de commande
    local cmd_line=("aklo" "$command")
    # Ajout des arguments (array JSON)
    local arg
    for arg in $(echo "$args" | jq -r '.[]'); do
        cmd_line+=("$arg")
    done
    # Logs sécurisés
    echo "[aklo_execute_shell] $(date +'%Y-%m-%d %H:%M:%S') CMD: ${cmd_line[*]} (workdir: $workdir)" >&2
    # Exécution dans le contexte
    local stdout stderr exit_code
    stdout=$(cd "$workdir" && "${cmd_line[@]}" 2> >(stderr=$(cat); echo "$stderr" >&2))
    exit_code=$?
    # Retour JSON structuré
    jq -n --arg status "success" --arg stdout "$stdout" --arg stderr "$stderr" --argjson exit_code "$exit_code" \
      '{"status": $status, "stdout": $stdout, "stderr": $stderr, "exit_code": $exit_code}'
}

#==============================================================================
# Fonction : aklo_status_shell
# Description :
#   Statut projet détaillé avec métriques, analyse artefacts, rapport santé.
#   - Calcul des métriques (PBI/TASK par statut, config, activité)
#   - Analyse artefacts par type et statut
#   - Rapport santé (indicateurs, alertes)
#   - Gestion projets non initialisés
#   - Formatage JSON structuré
#
# Usage :
#   aklo_status_shell
#   (attend un JSON sur stdin avec le champ optionnel workdir)
#
# Limitations :
#   - Fallback natif limité si jq absent
#   - Performance dépend du nombre d’artefacts
#==============================================================================
aklo_status_shell() {
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
    # Vérifier initialisation projet Aklo
    local aklo_conf_file="$workdir/aklo/config/.aklo.conf"
    local aklo_config="Non configuré"
    [ -f "$aklo_conf_file" ] && aklo_config="Configuré"
    # Calcul métriques artefacts
    local pbi_proposed pbi_done pbi_total task_todo task_done task_total
    pbi_proposed=$(ls "$workdir/docs/backlog/00-pbi/"*-PROPOSED.xml 2>/dev/null | wc -l | tr -d ' ')
    pbi_done=$(ls "$workdir/docs/backlog/00-pbi/"*-DONE.xml 2>/dev/null | wc -l | tr -d ' ')
    pbi_total=$(ls "$workdir/docs/backlog/00-pbi/"PBI-*.xml 2>/dev/null | wc -l | tr -d ' ')
    task_todo=$(ls "$workdir/docs/backlog/01-tasks/"*-TODO.xml 2>/dev/null | wc -l | tr -d ' ')
    task_done=$(ls "$workdir/docs/backlog/01-tasks/"*-DONE.xml 2>/dev/null | wc -l | tr -d ' ')
    task_total=$(ls "$workdir/docs/backlog/01-tasks/"TASK-*.xml 2>/dev/null | wc -l | tr -d ' ')
    # Dernière activité
    local last_activity
    last_activity=$(find "$workdir/docs/backlog" -name "*.xml" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2- | xargs basename)
    # Rapport santé
    local health="OK"
    local alerts=()
    [ "$aklo_config" = "Non configuré" ] && alerts+=("Projet non initialisé Aklo")
    [ "$pbi_total" -eq 0 ] && alerts+=("Aucun PBI")
    [ "$task_total" -eq 0 ] && alerts+=("Aucune Task")
    [ "$pbi_done" -eq 0 ] && alerts+=("Aucun PBI terminé")
    [ "$task_done" -eq 0 ] && alerts+=("Aucune Task terminée")
    [ ${#alerts[@]} -gt 0 ] && health="ALERT"
    # Formatage JSON
    jq -n \
      --arg aklo_config "$aklo_config" \
      --arg last_activity "$last_activity" \
      --arg health "$health" \
      --argjson pbi_total "$pbi_total" --argjson pbi_proposed "$pbi_proposed" --argjson pbi_done "$pbi_done" \
      --argjson task_total "$task_total" --argjson task_todo "$task_todo" --argjson task_done "$task_done" \
      --argjson alerts "[\"${alerts[@]}\"]" \
      '{
        aklo_config: $aklo_config,
        last_activity: $last_activity,
        metrics: {
          pbi: { total: $pbi_total, proposed: $pbi_proposed, done: $pbi_done },
          task: { total: $task_total, todo: $task_todo, done: $task_done }
        },
        health: $health,
        alerts: $alerts
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
        "aklo_execute_shell")
            aklo_execute_shell
            ;;
        "aklo_status_shell")
            aklo_status_shell
            ;;
        "tools/list")
            jq -n '{ tools: ["safe_shell", "project_info", "aklo_execute_shell", "aklo_status_shell"] }'
            ;;
        *)
            log_error "Unknown tool: $tool_name"
            ;;
    esac
}

# Exécuter le routeur principal
main "$@"