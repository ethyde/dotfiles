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

# Fonction principale pour exécuter une commande shell sécurisée
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

# Routeur de commande principal
main() {
    local tool_name="$1"
    case "$tool_name" in
        "safe_shell")
            safe_shell
            ;;
        *)
            log_error "Unknown tool: $tool_name"
            ;;
    esac
}

# Exécuter le routeur principal
main "$@"