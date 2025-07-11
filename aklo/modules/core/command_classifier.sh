#!/usr/bin/env bash
#==============================================================================
# AKLO COMMAND CLASSIFIER - CORRECTION FINALE DES DÉPENDANCES
#==============================================================================

declare -A COMMAND_PROFILES
COMMAND_PROFILES["new"]="CREATE_ARTEFACT"
COMMAND_PROFILES["plan"]="PLAN_COMMANDS"
COMMAND_PROFILES["status"]="SYSTEM_COMMANDS"
COMMAND_PROFILES["init"]="INIT_COMMAND"
COMMAND_PROFILES["start-task"]="TASK_LIFECYCLE"
COMMAND_PROFILES["submit-task"]="TASK_LIFECYCLE"
COMMAND_PROFILES["merge-task"]="TASK_LIFECYCLE"
COMMAND_PROFILES["release"]="RELEASE_LIFECYCLE"
COMMAND_PROFILES["hotfix"]="RELEASE_LIFECYCLE"
COMMAND_PROFILES["cache"]="CACHE_MGMT"
COMMAND_PROFILES["config"]="PERF_CONFIG"
COMMAND_PROFILES["monitor"]="MONITORING"

declare -A PROFILE_MODULES
# Les modules de création ont aussi besoin de la config pour les chemins.
PROFILE_MODULES["CREATE_ARTEFACT"]="core/config.sh core/parser.sh commands/new_command.sh commands/pbi_commands.sh commands/debug_command.sh commands/refactor_command.sh commands/optimize_command.sh commands/experiment_command.sh commands/security_command.sh commands/docs_command.sh commands/scratchpad_command.sh commands/kb_command.sh commands/meta_command.sh"
PROFILE_MODULES["PLAN_COMMANDS"]="core/config.sh core/parser.sh commands/task_commands.sh"
PROFILE_MODULES["SYSTEM_COMMANDS"]="core/config.sh commands/system_commands.sh" # Ajout pour la cohérence
PROFILE_MODULES["INIT_COMMAND"]="commands/init_command.sh"
PROFILE_MODULES["TASK_LIFECYCLE"]="core/config.sh commands/start-task_command.sh commands/submit-task_command.sh commands/merge-task_command.sh"
PROFILE_MODULES["RELEASE_LIFECYCLE"]="core/config.sh commands/release_command.sh commands/hotfix_command.sh"

# CORRECTION FINALE : s'assurer que TOUS les profils qui en ont besoin chargent TOUTES leurs dépendances.
PROFILE_MODULES["CACHE_MGMT"]="core/config.sh commands/cache_command.sh cache/cache_monitoring.sh"
PROFILE_MODULES["PERF_CONFIG"]="core/config.sh commands/config_command.sh performance/performance_tuning.sh"
PROFILE_MODULES["MONITORING"]="core/config.sh commands/monitor_command.sh io/io_monitoring.sh performance/performance_tuning.sh"

# Fonction pour classifier une commande.
classify_command() {
    local command_name="$1"
    local profile="${COMMAND_PROFILES[$command_name]}"
    echo "${profile:-UNKNOWN}"
}

# Fonction pour obtenir la liste des modules.
get_required_modules() {
    local profile_name="$1"
    echo "${PROFILE_MODULES[$profile_name]}"
}