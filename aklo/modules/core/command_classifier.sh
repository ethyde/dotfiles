#!/usr/bin/env bash
#==============================================================================
# AKLO COMMAND CLASSIFIER - FINAL
#==============================================================================

declare -A COMMAND_PROFILES
COMMAND_PROFILES["propose-pbi"]="PBI_COMMANDS"
COMMAND_PROFILES["status"]="SYSTEM_COMMANDS"

declare -A PROFILE_MODULES
PROFILE_MODULES["PBI_COMMANDS"]="core/parser.sh,commands/pbi_commands.sh"
PROFILE_MODULES["SYSTEM_COMMANDS"]="commands/system_commands.sh"

classify_command() {
    echo "${COMMAND_PROFILES[$1]}"
}

get_required_modules() {
    echo "${PROFILE_MODULES[$1]}"
}