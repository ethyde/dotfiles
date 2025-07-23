#!/usr/bin/env bash
#==============================================================================
# AKLO CORE PARSER - MODULE CENTRALISÉ (V4 - STABLE)
#==============================================================================

get_next_id() {
    local artefact_dir="$1" prefix="$2"
    if [ ! -d "$artefact_dir" ] && [ "${AKLO_DRY_RUN:-false}" = true ]; then
        echo "1"; return;
    fi
    local last_id
    last_id=$(find "$artefact_dir" -name "${prefix}*.xml" 2>/dev/null | grep -oE "${prefix}[0-9]+" | sed "s/${prefix}//" | sort -nr | head -1)
    echo "$(( ${last_id:-0} + 1 ))"
}

extract_artefact_xml() {
    local protocol_file="$1" artefact_tag="$2"
    if [ ! -f "$protocol_file" ]; then
        echo "Erreur: Fichier protocole introuvable à '$protocol_file'" >&2; return 1;
    fi
    awk -v tag="$artefact_tag" '
    /<\s*artefact_template/ { in_template=1 }
    /<\s*\/\s*artefact_template/ { in_template=0 }
    in_template {
        if ($0 ~ "<" tag "[ >]") { in_artefact=1 }
        if (in_artefact) { print }
        if ($0 ~ "</" tag ">") { exit }
    }' "$protocol_file"
}

parse_and_generate_artefact() {
    local protocol_name="$1" artefact_type="$2" output_file="$3" context_vars="$4"
    
    # Lire la configuration des protocoles depuis .aklo.conf si disponible
    if [ -z "$AKLO_PROTOCOLS_PATH" ] && [ -f ".aklo.conf" ]; then
        AKLO_PROTOCOLS_PATH=$(grep "^AKLO_PROTOCOLS_PATH=" ".aklo.conf" | cut -d'=' -f2 2>/dev/null)
    fi
    
    # Construire le chemin du protocole en priorité depuis la variable d'environnement
    local protocol_file
    if [ -n "$AKLO_PROTOCOLS_PATH" ]; then
        protocol_file="${AKLO_PROTOCOLS_PATH}/${protocol_name}.xml"
    else
        protocol_file="${AKLO_TOOL_DIR}/charte/PROTOCOLES/${protocol_name}.xml"
    fi
    local structure
    structure=$(extract_artefact_xml "$protocol_file" "$artefact_type")
    if [ -z "$structure" ]; then
        echo "❌ Erreur : Structure d'artefact '$artefact_type' non trouvée." >&2; return 1;
    fi
    
    local id_val title_val status_val date_val
    id_val=$(echo "$context_vars" | sed -n 's/.*id=\([^,]*\).*/\1/p')
    title_val=$(echo "$context_vars" | sed -n 's/.*title=\([^,]*\).*/\1/p')
    status_val=$(echo "$context_vars" | sed -n 's/.*status=\([^,]*\).*/\1/p')
    date_val=$(echo "$context_vars" | sed -n 's/.*date=\([^,]*\).*/\1/p')
    
    local title_val_escaped
    title_val_escaped=$(printf '%s\n' "$title_val" | sed 's:[&/\\]:\\&:g')

    local final_content
    final_content=$(echo "$structure" | sed -e "s/title=\"\[title\]\"/title=\"${title_val_escaped}\"/g" -e "s/id=\"\[id\]\"/id=\"${id_val}\"/g" -e "s/>\[status\]</>${status_val}</g" -e "s/>\[date\]</>${date_val}</g")

    if [ "${AKLO_DRY_RUN:-false}" = true ]; then return 0; fi
    
    local output_dir
    output_dir=$(dirname "$output_file")
    mkdir -p "$output_dir"
    
    echo "$final_content" > "$output_file"
    [ -s "$output_file" ]
}
