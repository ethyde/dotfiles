#!/usr/bin/env bash
#==============================================================================
# AKLO KNOWLEDGE BASE COMMAND MODULE
#==============================================================================

create_artefact_kb() {
    local title="$1"
    local kb_file="${AKLO_PROJECT_ROOT}/docs/KNOWLEDGE-BASE.xml"
    
    # Vérifier si le fichier knowledge base existe déjà
    if [ ! -f "$kb_file" ]; then
        echo "ℹ️  Création du fichier knowledge base principal..."
        # Créer le répertoire docs s'il n'existe pas
        mkdir -p "${AKLO_PROJECT_ROOT}/docs"
        
        # Contexte pour créer le fichier principal
        local context_vars="title=${title}"
        
        if parse_and_generate_artefact "22-KNOWLEDGE-BASE" "knowledge_base" "$kb_file" "$context_vars"; then
            echo "✅ Fichier knowledge base créé : ${kb_file}"
        else
            echo "❌ La création du fichier knowledge base a échoué." >&2
            return 1
        fi
    else
        echo "ℹ️  Le fichier knowledge base existe déjà : ${kb_file}"
        echo "   📝 Pour ajouter une nouvelle entrée, éditez directement le fichier ou utilisez la commande 'aklo kb add'."
    fi
}

# Commande pour ajouter une entrée à la knowledge base existante
cmd_kb() {
    local action="$1"
    
    case "$action" in
        "add")
            local subject="$2"
            if [ -z "$subject" ]; then
                echo "Erreur: Le sujet de l'entrée est manquant." >&2
                echo "Usage: aklo kb add \"<sujet>\"" >&2
                return 1
            fi
            echo "ℹ️  Pour ajouter une entrée à la knowledge base, éditez directement le fichier /docs/KNOWLEDGE-BASE.xml"
            echo "   Sujet suggéré: $subject"
            ;;
        *)
            echo "Erreur: Action '$action' inconnue pour la commande 'kb'." >&2
            echo "Usage: aklo kb <add|new>" >&2
            return 1
            ;;
    esac
    return 0
} 