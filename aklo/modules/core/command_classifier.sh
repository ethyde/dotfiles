#!/usr/bin/env bash
#==============================================================================
# AKLO COMMAND CLASSIFIER - DOUBLE PROFIL (MÉTIER & TECHNIQUE)
#==============================================================================

# Mapping commande → profil métier
declare -A COMMAND_TO_PROFILE
COMMAND_TO_PROFILE["get_config"]="MINIMAL"
COMMAND_TO_PROFILE["status"]="MINIMAL"
COMMAND_TO_PROFILE["version"]="MINIMAL"
COMMAND_TO_PROFILE["help"]="MINIMAL"
COMMAND_TO_PROFILE["plan"]="NORMAL"
COMMAND_TO_PROFILE["dev"]="NORMAL"
COMMAND_TO_PROFILE["debug"]="NORMAL"
COMMAND_TO_PROFILE["review"]="NORMAL"
COMMAND_TO_PROFILE["new"]="NORMAL"
COMMAND_TO_PROFILE["template"]="NORMAL"
COMMAND_TO_PROFILE["optimize"]="FULL"
COMMAND_TO_PROFILE["benchmark"]="FULL"
COMMAND_TO_PROFILE["cache"]="FULL"
COMMAND_TO_PROFILE["monitor"]="FULL"
COMMAND_TO_PROFILE["diagnose"]="FULL"

# Mapping profil métier → profil technique
# (On garde les profils techniques existants)
declare -A PROFILE_TO_TECHNICAL
PROFILE_TO_TECHNICAL["MINIMAL"]="SYSTEM_COMMANDS"
PROFILE_TO_TECHNICAL["NORMAL"]="PLAN_COMMANDS"
PROFILE_TO_TECHNICAL["FULL"]="CACHE_MGMT"

# Profils techniques → modules (inchangé)
declare -A PROFILE_MODULES
PROFILE_MODULES["SYSTEM_COMMANDS"]="core/config.sh commands/system_commands.sh"
PROFILE_MODULES["PLAN_COMMANDS"]="core/config.sh core/parser.sh commands/task_commands.sh"
PROFILE_MODULES["CACHE_MGMT"]="core/config.sh commands/cache_command.sh cache/cache_monitoring.sh"
# ... (ajouter les autres profils techniques si besoin)

# Fonction pour classifier une commande (profil métier)
classify_command() {
    local command_name="$1"
    echo "${COMMAND_TO_PROFILE[$command_name]:-UNKNOWN}"
}

# Fonction pour obtenir le profil technique à partir du profil métier
get_technical_profile() {
    local profile="$1"
    echo "${PROFILE_TO_TECHNICAL[$profile]:-UNKNOWN}"
}

# Fonction pour obtenir la liste des modules à partir du profil métier
get_required_modules() {
    local profile="$1"
    local technical_profile
    technical_profile=$(get_technical_profile "$profile")
    echo "${PROFILE_MODULES[$technical_profile]}"
}

# Fonction pour détecter la commande principale à partir des arguments
# (premier argument non option)
detect_command_from_args() {
    for arg in "$@"; do
        if [[ ! "$arg" =~ ^- ]]; then
            echo "$arg"
            return
        fi
    done
    echo ""
}