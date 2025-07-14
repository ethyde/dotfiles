#!/usr/bin/env bash
#==============================================================================
# AKLO PBI COMMANDS MODULE (Version Finale et Fonctionnelle)
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: create_artefact_pbi
# Gère la logique de création d'un nouvel artefact PBI.
#------------------------------------------------------------------------------
create_artefact_pbi() {
    local title="$1"

    # Vérification que le titre n'est pas vide
    if [ -z "$title" ]; then
        echo "Erreur: Un titre est requis pour créer un PBI." >&2
        return 1
    fi

    echo "🎯 Création du PBI: \"$title\""

    # Le PBI est créé dans le répertoire de travail courant (défini par AKLO_PROJECT_ROOT)
    local pbi_dir="${AKLO_PROJECT_ROOT}/docs/backlog/00-pbi"
    
    # Création du répertoire s'il n'existe pas
    if ! mkdir -p "$pbi_dir"; then
        echo "❌ Erreur critique: Impossible de créer le répertoire des PBI à l'emplacement : $pbi_dir" >&2
        return 1
    fi

    # Obtention du prochain ID disponible
    local next_id
    next_id=$(get_next_id "$pbi_dir" "PBI-")
    
    # Nettoyage du titre pour le nom de fichier
    local sanitized_title
    sanitized_title=$(echo "$title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)
    local filename="PBI-${next_id}-${sanitized_title}-PROPOSED.xml"
    local output_file="${pbi_dir}/${filename}"
    
    # Construction du contexte complet pour le parser
    local current_date
    current_date=$(date +%Y-%m-%d)
    local context_vars="id=${next_id},title=${title},status=PROPOSED,date=${current_date}"

    # Appel du parser pour générer le fichier final
    if parse_and_generate_artefact "00-PRODUCT-OWNER" "pbi" "$output_file" "$context_vars"; then
        echo "✅ PBI créé : ${output_file}"
    else
        echo "❌ La création du fichier PBI a échoué lors de l'appel au parser." >&2
        return 1
    fi
} 