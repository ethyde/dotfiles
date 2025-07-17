#!/usr/bin/env bash
#==============================================================================
# AKLO JOURNAL COMMAND MODULE
#==============================================================================

create_artefact_journal() {
    local title="$1"
    local journal_dir="${AKLO_PROJECT_ROOT}/docs/backlog/15-journal"
    mkdir -p "$journal_dir"

    # Utilise la date actuelle pour le nom du fichier
    local current_date=$(date +%Y-%m-%d)
    local filename="JOURNAL-${current_date}.xml"
    local output_file="${journal_dir}/${filename}"
    
    # Vérifier si le journal du jour existe déjà
    if [ -f "$output_file" ]; then
        echo "ℹ️  Le journal du ${current_date} existe déjà : ${output_file}"
        echo "   Vous pouvez l'éditer directement ou utiliser 'aklo status' pour voir les entrées récentes."
        return 0
    fi

    # Contexte pour le parser
    local context_vars="date=${current_date},title=${title:-"Journal du ${current_date}"}"

    if parse_and_generate_artefact "18-JOURNAL" "journal" "$output_file" "$context_vars"; then
        echo "✅ Journal créé : ${output_file}"
        echo "   📝 Vous pouvez maintenant ajouter des entrées manuellement ou via d'autres commandes Aklo."
    else
        echo "❌ La création du journal a échoué." >&2
        return 1
    fi
} 