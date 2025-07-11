#!/bin/bash
# Module unifié pour toutes les commandes Aklo

#==============================================================================
# Fonction: cmd_init
#==============================================================================
cmd_init() {
    echo "Initialisation du projet Aklo..."
    local pbi_dir="${AKLO_PROJECT_ROOT}/pbi"
    local config_file="${AKLO_PROJECT_ROOT}/aklo/config/.aklo.conf"
    mkdir -p "$pbi_dir"
    if [ ! -f "$config_file" ]; then
        echo "PBI_DIR=\"$pbi_dir\"" > "$config_file"
    fi
    echo "✅ Initialisation terminée."
}

#==============================================================================
# Fonction: cmd_propose-pbi
#==============================================================================
cmd_propose_pbi() {
    local title="$2"
    [ -z "$title" ] && echo "Erreur: Titre manquant." >&2 && return 1
    
    local pbi_dir; pbi_dir=$(get_config "PBI_DIR" "pbi")
    mkdir -p "$pbi_dir"
    
    local next_id; next_id=$(get_next_id_cached "PBI" "$pbi_dir")
    local safe_title; safe_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9 -]//g' -e 's/ /-/g')
    local filename="PBI-${next_id}-${safe_title}.xml"
    local output_file="${pbi_dir}/${filename}"
    
    export PBI_TITLE="$title"
    if parse_and_generate_artefact "03-DEVELOPPEMENT" "pbi" "full" "$output_file"; then
        echo "✅ PBI créé: $output_file"
    else
        echo "❌ Échec de la création du PBI." >&2 && return 1
    fi
}
cmd_pbi() { cmd_propose-pbi "$@"; }

#==============================================================================
# Fonction: cmd_status
#==============================================================================
cmd_status() {
    echo "📊 Aklo project status"
    local pbi_dir; pbi_dir=$(get_config "PBI_DIR" "pbi")
    local pbi_count=0
    [ -d "$pbi_dir" ] && pbi_count=$(find "$pbi_dir" -type f -name "PBI-*.xml" | wc -l | tr -d ' ')
    echo "  - PBIs: $pbi_count"
}

#==============================================================================
# Fonction: cmd_help
#==============================================================================
cmd_help() {
    echo "Usage: aklo <command> [options...]"
    echo "Core Commands: init, propose-pbi, status, help"
}

#==============================================================================
# Fonction: cmd_get_config & get_config
#==============================================================================
cmd_get_config() {
    local key="$2"
    local default_value="$3"
    local config_file="${AKLO_PROJECT_ROOT}/aklo/config/.aklo.conf"
    if [ ! -f "$config_file" ]; then
        [ -n "$default_value" ] && echo "$default_value" && return 0
        return 1
    fi
    local value; value=$(sed -n "/^${key}=/s/^[^=]*=//p" "$config_file" | tr -d '"')
    [ -n "$value" ] && echo "$value" || echo "$default_value"
}
get_config() { cmd_get_config "get_config" "$@"; }

#==============================================================================
# Fonction: cmd_plan
#==============================================================================
cmd_plan() {
    echo "La commande 'plan' est en cours de développement."
} 