#!/usr/bin/env bash
#==============================================================================
# AKLO COMMAND CLASSIFIER - AVEC "PLAN"
#==============================================================================

declare -A COMMAND_PROFILES
COMMAND_PROFILES["new"]="CREATE_ARTEFACT"
COMMAND_PROFILES["status"]="SYSTEM_COMMANDS"
COMMAND_PROFILES["init"]="SYSTEM_COMMANDS"
COMMAND_PROFILES["plan"]="PLAN_COMMANDS"

declare -A PROFILE_MODULES
PROFILE_MODULES["CREATE_ARTEFACT"]="core/parser.sh,commands/new_command.sh,commands/pbi_commands.sh"
PROFILE_MODULES["SYSTEM_COMMANDS"]="commands/system_commands.sh"
PROFILE_MODULES["PLAN_COMMANDS"]="core/parser.sh,commands/task_commands.sh"

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