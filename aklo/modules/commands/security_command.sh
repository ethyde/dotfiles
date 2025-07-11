#!/usr/bin/env bash
#==============================================================================
# AKLO SECURITY COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: new security
#------------------------------------------------------------------------------
create_artefact_security() {
    local title="$1"
    local security_dir="${AKLO_PROJECT_ROOT}/docs/backlog/11-security"
    mkdir -p "$security_dir"

    local next_id
    next_id=$(date +%Y-%m-%d)

    local filename="AUDIT-SECURITY-${next_id}-SCANNING.xml"
    local output_file="${security_dir}/${filename}"
    local context_vars="id=${next_id},title=${title}"

    echo "🛡️  Création de l'audit de sécurité : \"$title\""

    if [ "$AKLO_DRY_RUN" = true ]; then
        echo "[DRY-RUN] Créerait le fichier d'audit : '$output_file'"
    else
        if parse_and_generate_artefact "13-SECURITE-AUDIT" "security_audit_report" "$output_file" "$context_vars"; then
            echo "✅ Audit de sécurité créé : ${output_file}"
        else
            echo "❌ La création de l'audit a échoué."
            return 1
        fi
    fi
    return 0
} 