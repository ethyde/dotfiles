#!/usr/bin/env bash
#==============================================================================
# AKLO CORE PARSER - MODULE CONSOLIDÉ V5 - ROBUSTE
#==============================================================================

# --- Fonction de calcul d'ID (logique existante, validée) ---
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

# --- Fonction d'extraction XML FIABLE ---
extract_artefact_xml() {
    local protocol_file="$1"
    local artefact_tag="$2"

    if [ ! -f "$protocol_file" ]; then
        echo "Erreur: Fichier protocole introuvable à '$protocol_file'" >&2
        return 1
    fi

    # 1. Trouver les numéros de ligne du bloc <artefact_template>
    local start_template_line
    start_template_line=$(grep -n "<artefact_template" "$protocol_file" | cut -d: -f1)
    local end_template_line
    end_template_line=$(grep -n "</artefact_template>" "$protocol_file" | cut -d: -f1)

    if [ -z "$start_template_line" ] || [ -z "$end_template_line" ]; then
        return 1 # Le bloc template n'a pas été trouvé
    fi

    # 2. Extraire le contenu de ce bloc
    local template_content
    template_content=$(sed -n "${start_template_line},${end_template_line}p" "$protocol_file")

    # 3. Extraire le tag spécifique depuis ce contenu
    echo "$template_content" | sed -n "/<${artefact_tag}/,/<\/${artefact_tag}>/p"
}


# --- Fonction Principale du Parser ---
parse_and_generate_artefact() {
    local protocol_name="$1"
    local artefact_type="$2"
    local output_file="$3"
    local context_vars="$4"

    local protocol_file="${AKLO_PROJECT_ROOT}/aklo/charte/PROTOCOLES/${protocol_name}.xml"

    local structure
    structure=$(extract_artefact_xml "$protocol_file" "$artefact_type")

    if [ -z "$structure" ]; then
        echo "❌ Erreur : Structure d'artefact '$artefact_type' non trouvée dans le protocole '$protocol_name'." >&2
        return 1
    fi

    # Remplacement des variables contextuelles
    local id_val title_val title_val_escaped current_date
    id_val=$(echo "$context_vars" | sed -n 's/.*id=\([^,]*\).*/\1/p')
    title_val=$(echo "$context_vars" | sed -n 's/.*title=\([^,]*\).*/\1/p')
    title_val_escaped=$(printf '%s\n' "$title_val" | sed 's:[&/\\]:\\&:g')
    current_date=$(date +%Y-%m-%d)

    structure=$(echo "$structure" | sed "s/\[id\]/$id_val/g")
    structure=$(echo "$structure" | sed "s/\[title\]/$title_val_escaped/g")
    structure=$(echo "$structure" | sed "s/\[date\]/$current_date/g")
    structure=$(echo "$structure" | sed "s/\[status\]/PROPOSED/g")

    echo "$structure" > "$output_file"
    
    [ -s "$output_file" ]
} 