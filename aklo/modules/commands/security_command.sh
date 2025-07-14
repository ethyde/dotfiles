#!/usr/bin/env bash
#==============================================================================
# AKLO SECURITY COMMAND MODULE
#==============================================================================

#------------------------------------------------------------------------------
# COMMANDE: new security
#------------------------------------------------------------------------------
create_artefact_security() {
    local title="$1"
    local dir="${AKLO_PROJECT_ROOT}/docs/backlog/13-security"
    mkdir -p "$dir"
    local id=$(echo "$title" | tr ' ' '-' | sed 's/[^a-z0-9-]//g' | cut -c 1-50)-$(date +%Y%m%d)
    local file="${dir}/SECURITY-${id}-PROPOSED.xml"
    local context="id=${id},title=${title}"
    parse_and_generate_artefact "13-SECURITE-AUDIT" "security_audit" "$file" "$context" && echo "✅ Audit sécurité créé: $file" || return 1
} 