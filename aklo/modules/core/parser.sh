#!/usr/bin/env bash
#==============================================================================
# AKLO CORE PARSER - MODULE CONSOLIDÉ V8 - INJECTION TITRE CORRIGÉE
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

# --- Fonction d'extraction XML FIABLE et UNIVERSELLE ---
extract_artefact_xml() {
    local protocol_file="$1"
    local artefact_tag="$2"

    if [ ! -f "$protocol_file" ]; then
        echo "Erreur: Fichier protocole introuvable à '$protocol_file'" >&2
        return 1
    fi

    # Version awk portable et robuste qui ne génère pas d'erreur de syntaxe.
    awk -v tag="$artefact_tag" '
    BEGIN {
        in_template = 0
        in_artefact = 0
    }
    /<\s*artefact_template/ {
        in_template = 1
    }
    /<\s*\/\s*artefact_template/ {
        in_template = 0
    }
    (in_template == 1) {
        if ($0 ~ "<" tag) {
            in_artefact = 1
        }
        if (in_artefact == 1) {
            print
        }
        if ($0 ~ "</" tag ">") {
            in_artefact = 0
        }
    }
    ' "$protocol_file"
}

# --- Fonction Principale du Parser (Corrigée) ---
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
    
    local id_val title_val pbi_id_val task_id_val
    id_val=$(echo "$context_vars" | sed -n 's/.*id=\([^,]*\).*/\1/p')
    title_val=$(echo "$context_vars" | sed -n 's/.*title=\([^,]*\).*/\1/p')
    pbi_id_val=$(echo "$context_vars" | sed -n 's/.*pbi_id=\([^,]*\).*/\1/p')
    task_id_val=$(echo "$context_vars" | sed -n 's/.*task_id=\([^,]*\).*/\1/p')
    
    local title_val_escaped
    title_val_escaped=$(printf '%s\n' "$title_val" | sed 's:[&/\\]:\\&:g')

    # Remplacement des placeholders dans les attributs ET le contenu
    # CORRECTION : On remplace [title] aussi bien en tant que placeholder simple
    # qu'en tant que valeur d'attribut.
    structure=$(echo "$structure" | sed "s/title=\"\[title\]\"/title=\"$title_val_escaped\"/g")
    structure=$(echo "$structure" | sed "s/\[id\]/$id_val/g")
    structure=$(echo "$structure" | sed "s/\[title\]/$title_val_escaped/g") # Pour le contenu de balise <title>
    structure=$(echo "$structure" | sed "s/\[pbi_id\]/$pbi_id_val/g")
    structure=$(echo "$structure" | sed "s/\[task_id\]/$task_id_val/g")
    structure=$(echo "$structure" | sed "s/\[status\]/PROPOSED/g")

    echo "$structure" > "$output_file"
    
    [ -s "$output_file" ]
} 