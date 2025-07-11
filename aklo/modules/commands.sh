#!/usr/bin/env bash
# Module unifié pour toutes les commandes Aklo

#==============================================================================
# Fonction: cmd_init
# Description: Initialise un nouveau projet Aklo.
#==============================================================================
cmd_init() {
    echo "Initialisation du projet Aklo..."
    
    # Utilise AKLO_PROJECT_ROOT pour garantir des chemins absolus et fiables.
    local pbi_dir="${AKLO_PROJECT_ROOT}/pbi"
    local config_file="${AKLO_PROJECT_ROOT}/aklo/config/.aklo.conf"
    
    mkdir -p "$pbi_dir"
    echo "  -> Répertoire '$pbi_dir' créé."

    if [ ! -f "$config_file" ]; then
        echo "PBI_DIR=\"$pbi_dir\"" > "$config_file"
        echo "  -> Fichier de configuration '$config_file' créé."
    fi
    
    echo "✅ Initialisation terminée."
}

#==============================================================================
# Fonction: cmd_propose-pbi
# Description: Crée un nouvel artefact PBI.
#==============================================================================
cmd_propose-pbi() {
    local title="$1"
    if [ -z "$title" ]; then
        echo "Erreur: Le titre du PBI est requis." >&2
        echo "Usage: aklo propose-pbi \"Titre du PBI\"" >&2
        return 1
    fi

    # Le parser retourne maintenant le contenu brut.
    local artefact_content
    artefact_content=$(parse_and_generate_artefact "03-DEVELOPPEMENT" "pbi")
    
    if [ -z "$artefact_content" ]; then
        echo "❌ Échec de la génération du PBI." >&2
        return 1
    fi
    
    # C'est la commande qui gère la logique de nom de fichier et d'écriture.
    local pbi_dir; pbi_dir=$(get_config "PBI_DIR" "pbi")
    mkdir -p "$pbi_dir"
    
    local next_id; next_id=$(get_next_id_cached "PBI" "$pbi_dir")
    local filename="PBI-${next_id}-PROPOSED.xml"
    local output_file="${pbi_dir}/${filename}"
    
    # Injecte le titre dans le contenu avant l'écriture
    export PBI_TITLE="$title" 
    # Note: L'injection des variables d'environnement n'est pas encore implémentée
    # dans le parser simplifié, mais la balise <title> sera présente.
    
    echo "$artefact_content" > "$output_file"
    echo "✅ PBI créé: $output_file"
}
cmd_pbi() { cmd_propose-pbi "$@"; } 