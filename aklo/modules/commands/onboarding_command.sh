#!/usr/bin/env bash
#==============================================================================
# AKLO ONBOARDING COMMAND MODULE
#==============================================================================

create_artefact_onboarding() {
    local title="$1"
    local onboarding_dir="${AKLO_PROJECT_ROOT}/docs/project"
    mkdir -p "$onboarding_dir"

    local current_date=$(date +%Y-%m-%d)
    local filename="ONBOARDING-SUMMARY-${current_date}.xml"
    local output_file="${onboarding_dir}/${filename}"
    local context_vars="date=${current_date},title=${title}"

    if parse_and_generate_artefact "14-ONBOARDING" "onboarding_summary" "$output_file" "$context_vars"; then
        echo "✅ Plan d'onboarding créé : ${output_file}"
    else
        echo "❌ La création du plan d'onboarding a échoué." >&2
        return 1
    fi
} 