#!/bin/bash

# Test d'intégration pour l'extraction et la mise en cache (TASK-6-2)

# Définition du test
test_extract_and_cache_integration() {
    # 1. Préparation
    test_suite "Integration Test: extract_and_cache_structure"
    source_test_helpers "cache/cache_functions.sh" "io/extract_functions.sh"

    local temp_dir
    temp_dir=$(mktemp -d)
    # Assurer le nettoyage à la fin du test
    add_cleanup "rm -rf '$temp_dir'"

    # Créer un faux fichier de protocole
    local protocol_file="$temp_dir/PROTOCOLE-TEST.xml"
    cat > "$protocol_file" << 'EOF'
# Protocole de Test

## SECTION 2: Structures

### 2.3. Structure Obligatoire Du Fichier PBI
```markdown
# PBI-{{ID}} : {{TITLE}}

**As a** [user type]
**I want to** [goal]
**So that** [reason]
```

## SECTION 3: Processus
EOF

    # Définir les variables pour la fonction à tester
    local artefact_type="PBI"
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
# PBI-{{ID}} : {{TITLE}}

**As a** [user type]
**I want to** [goal]
**So that** [reason]
EOF
)
    assert_equals "$expected_structure" "$extracted_structure" "La structure extraite est correcte"

    # Vérifier la création des fichiers de cache
    assert_file_exists "$cache_file" "Le fichier de cache .parsed doit être créé"
    assert_file_exists "$mtime_file" "Le fichier de cache .mtime doit être créé"

    # Vérifier le contenu du fichier de cache
    local cached_content
    cached_content=$(cat "$cache_file")
    assert_equals "$expected_structure" "$cached_content" "Le contenu du fichier de cache est correct"
} 