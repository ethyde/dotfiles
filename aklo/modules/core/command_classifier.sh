#!/usr/bin/env bash
#==============================================================================
# AKLO COMMAND CLASSIFIER - AVEC CONFIGURATION
#==============================================================================

declare -A COMMAND_PROFILES
COMMAND_PROFILES["new"]="CREATE_ARTEFACT"
COMMAND_PROFILES["plan"]="PLAN_COMMANDS"
COMMAND_PROFILES["status"]="SYSTEM_COMMANDS"
COMMAND_PROFILES["init"]="SYSTEM_COMMANDS"
COMMAND_PROFILES["start-task"]="TASK_LIFECYCLE"
COMMAND_PROFILES["submit-task"]="TASK_LIFECYCLE"
COMMAND_PROFILES["merge-task"]="TASK_LIFECYCLE"

declare -A PROFILE_MODULES
PROFILE_MODULES["CREATE_ARTEFACT"]="core/parser.sh commands/new_command.sh commands/pbi_commands.sh"
PROFILE_MODULES["PLAN_COMMANDS"]="core/parser.sh commands/task_commands.sh"
PROFILE_MODULES["SYSTEM_COMMANDS"]="commands/system_commands.sh"
# Ajout de core/config.sh comme dépendance
PROFILE_MODULES["TASK_LIFECYCLE"]="core/config.sh commands/start-task_command.sh commands/submit-task_command.sh commands/merge-task_command.sh"

classify_command() {
    local command_name="$1"
    local profile="${COMMAND_PROFILES[$command_name]}"
    if [ -z "$profile" ]; then
        echo "UNKNOWN"
    else
        echo "$profile"
    fi
}

get_required_modules() {
    local profile_name="$1"
    echo "${PROFILE_MODULES[$profile_name]}"
}