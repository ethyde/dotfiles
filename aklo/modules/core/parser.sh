#!/usr/bin/env bash
#==============================================================================
# AKLO CORE PARSER - MODULE CONSOLIDÉ V10 - SED ATOMIQUE
#==============================================================================

# --- Fonctions get_next_id et extract_artefact_xml (inchangées et validées) ---
get_next_id() {
    local artefact_dir="$1"
    local prefix="$2"
    local last_id
    last_id=$(find "$artefact_dir" -name "${prefix}*.xml" 2>/dev/null | \
              grep -oE "${prefix}[0-9]+" | \
              sed "s/${prefix}//" | \
              sort -nr | \
              head -1)
    local next_id=$(( ${last_id:-0} + 1 ))
    echo "$next_id"
}

extract_artefact_xml() {
    local protocol_file="$1"
    local artefact_tag="$2"
    if [ ! -f "$protocol_file" ]; then
        echo "Erreur: Fichier protocole introuvable à '$protocol_file'" >&2
        return 1
    fi
    awk -v tag="$artefact_tag" '
    BEGIN { in_template=0; in_artefact=0 }
    /<\s*artefact_template/ { in_template=1 }
    /<\s*\/\s*artefact_template/ { in_template=0 }
    in_template {
        if ($0 ~ "<" tag "[ >]") { in_artefact=1 }
        if (in_artefact) { print }
        if ($0 ~ "</" tag ">") { in_artefact=0 }
    }
    ' "$protocol_file"
}

# --- Fonction Principale du Parser (avec sed atomique) ---
parse_and_generate_artefact() {
    local protocol_name="$1"
    local artefact_type="$2"
    local output_file="$3"
    local context_vars="$4"

    local protocol_file="${AKLO_TOOL_DIR}/charte/PROTOCOLES/${protocol_name}.xml"

    local structure
    structure=$(extract_artefact_xml "$protocol_file" "$artefact_type")

    if [ -z "$structure" ]; then
        echo "❌ Erreur : Structure d'artefact '$artefact_type' non trouvée dans le protocole '$protocol_name'." >&2
        return 1
    fi
    
    local id_val title_val status_val date_val
    id_val=$(echo "$context_vars" | sed -n 's/.*id=\([^,]*\).*/\1/p')
    title_val=$(echo "$context_vars" | sed -n 's/.*title=\([^,]*\).*/\1/p')
    status_val=$(echo "$context_vars" | sed -n 's/.*status=\([^,]*\).*/\1/p')
    date_val=$(echo "$context_vars" | sed -n 's/.*date=\([^,]*\).*/\1/p')
    
    local title_val_escaped
    title_val_escaped=$(printf '%s\n' "$title_val" | sed 's:[&/\\]:\\&:g')

    # --- CORRECTION FINALE : sed atomique avec plusieurs expressions ---
    # Applique tous les remplacements en une seule passe robuste.
    echo "$structure" | sed \
        -e "s/title=\"\[title\]\"/title=\"${title_val_escaped}\"/g" \
        -e "s/id=\"\[id\]\"/id=\"${id_val}\"/g" \
        -e "s/>\[status\]</>${status_val}</g" \
        -e "s/>\[date\]</>${date_val}</g" \
        -e "s/>TASK-\[id\]-1</>TASK-${id_val}-1</g" \
        -e "s/>TASK-\[id\]-2</>TASK-${id_val}-2</g" \
        -e "s/>ARCH-\[id\]-1.xml</>ARCH-${id_val}-1.xml</g" \
        > "$output_file"
    
    # La vérification finale qui garantit que le fichier n'est pas vide
    [ -s "$output_file" ]
} 