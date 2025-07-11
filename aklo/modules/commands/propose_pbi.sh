#!/bin/bash

# Commande: propose-pbi - Créer un nouveau Product Backlog Item
command_propose_pbi() {
  local title="$1"
  local agent_assistance=$(get_config "AGENT_ASSISTANCE" || echo "full")
  local auto_journal=$(get_config "AUTO_JOURNAL" || echo "true")
  
  case "$title" in
    "--help"|"help"|"")
      echo "Usage: aklo propose-pbi \"<titre>\" [--template <template_name>]"
      # ... (contenu de l'aide)
      exit 0
      ;;
    "--template")
      agent_assistance="$2"
      title="$3"
      ;;
  esac

  if [ -z "$title" ]; then
    echo "❌ Erreur : Le titre du PBI est requis." >&2
    echo "Usage: aklo propose-pbi \"<titre>\""
    exit 1
  fi

  local pbi_dir
  pbi_dir=$(get_config_value "PBI_DIR" "docs/backlog/00-pbi")
  mkdir -p "$pbi_dir"
  
  local next_id
  next_id=$(get_next_id "$pbi_dir" "PBI")
  
  local pbi_file="${pbi_dir}/PBI-${next_id}-PROPOSED.xml"
  local today
  today=$(date +%Y-%m-%d)
  
  echo "🎯 Création du PBI-${next_id}: \"$title\""

  generate_pbi_from_protocol "$pbi_file" "$next_id" "$title" "$today" "$agent_assistance"

  if [ "$auto_journal" = "true" ]; then
    update_journal "PRODUCT-OWNER" "Création PBI" "PBI-${next_id}: $title" "PBI-${next_id}-PROPOSED.xml"
  fi
  
  echo ""
  echo "✅ PBI-${next_id}-PROPOSED.xml créé avec succès !"
  echo "📍 Fichier: $pbi_file"
  echo ""
  echo "Prochaines étapes:"
  echo "  1. Réviser et compléter le PBI"
  echo "  2. Valider avec l'équipe"
  echo "  3. aklo plan $next_id (pour décomposer en tâches)"
}

# Fonction de génération PBI - Parser dynamique du protocole PRODUCT-OWNER
generate_pbi_from_protocol() {
  local file="$1"
  local id="$2"
  local title="$3"
  local date="$4"
  local assistance_level="$5"

  local context_vars="PBI_ID=${id};TITLE=${title};DATE=${date};STATUS=PROPOSED"
  
  parse_and_generate_artefact "00-PRODUCT-OWNER" "pbi" "$assistance_level" "$file" "$context_vars"
  
  if [ $? -ne 0 ]; then
    echo "❌ Erreur : Échec de génération PBI depuis le protocole" >&2
    echo "   Vérifiez l'intégrité du protocole PRODUCT-OWNER" >&2
    return 1
  fi
} 