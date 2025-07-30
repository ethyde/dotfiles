#!/usr/bin/env bash

# Test d'intégration pour l'extraction et la mise en cache (TASK-6-2)

# Définition du test
test_extract_and_cache_integration() {
    # 1. Préparation
    test_suite "Integration Test: extract_and_cache_structure (XML natif)"
    
    # Source des modules nécessaires
    local script_dir
    script_dir="$(dirname "$0")"
    source "${script_dir}/../modules/cache/cache_functions.sh"
    source "${script_dir}/../modules/io/extract_functions.sh"

    local temp_dir
    temp_dir=$(mktemp -d)
    # Assurer le nettoyage à la fin du test
    trap "rm -rf '$temp_dir'" EXIT

    # Créer un faux fichier de protocole XML natif
    local protocol_file="$temp_dir/PROTOCOLE-TEST.xml"
    cat > "$protocol_file" << 'EOF'
<protocol name="test_proto">
  <artefact_template>
    <pbi>
      <id>99</id>
      <title>PBI XML Cache</title>
      <description>Test cache XML natif</description>
    </pbi>
  </artefact_template>
</protocol>
EOF

    # Définir les variables pour la fonction à tester
    local artefact_type="pbi"
    local protocol_name
    protocol_name=$(basename "$protocol_file" .xml)
    local cache_file
    cache_file=$(generate_cache_filename "$protocol_name" "$artefact_type")
    # Rediriger le cache vers notre répertoire temporaire
    cache_file="$temp_dir/$(basename "$cache_file")"
    local mtime_file="${cache_file}.mtime"

    # 2. Exécution
    local extracted_structure
    extracted_structure=$(extract_and_cache_structure "$protocol_file" "$artefact_type" "$cache_file")
    local exit_code=$?

    # 3. Assertions
    assert_exit_code 0 $exit_code "extract_and_cache_structure doit réussir"

    # Vérifier le contenu extrait
    local expected_structure
    expected_structure=$(cat << 'EOF'
<pbi>
  <id>99</id>
  <title>PBI XML Cache</title>
  <description>Test cache XML natif</description>
</pbi>
EOF
)
    assert_equals "$expected_structure" "$extracted_structure" "La structure extraite est correcte (XML)"

    # Vérifier la création des fichiers de cache
    assert_file_exists "$cache_file" "Le fichier de cache .parsed doit être créé"
    assert_file_exists "$mtime_file" "Le fichier de cache .mtime doit être créé"

    # Vérifier le contenu du fichier de cache
    local cached_content
    cached_content=$(cat "$cache_file")
    assert_equals "$expected_structure" "$cached_content" "Le contenu du fichier de cache est correct (XML)"
} 