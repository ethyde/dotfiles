#!/usr/bin/env bash

# Source du framework et des dépendances
source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"
source "${AKLO_PROJECT_ROOT}/aklo/modules/cache/cache_functions.sh"
source "${AKLO_PROJECT_ROOT}/aklo/modules/io/extract_functions.sh"
source "${AKLO_PROJECT_ROOT}/aklo/modules/parser/parser_cached.sh"

# Mock de la fonction de filtrage
apply_intelligent_filtering() {
    local content="$1"
    echo "$content"
}

# --- Définition des Tests ---

test_cache_miss_then_hit_sequence() {
    local test_temp_dir
    test_temp_dir=$(mktemp -d)
    # Assurer le nettoyage à la fin du test
    trap 'rm -rf "$test_temp_dir"' EXIT

    # Configuration de l'environnement de test
    export AKLO_CACHE_DIR="${test_temp_dir}/cache"
    export AKLO_CACHE_DEBUG=true
    mkdir -p "${AKLO_CACHE_DIR}"

    local protocol_dir="${test_temp_dir}/protocols"
    mkdir -p "$protocol_dir"
    export AKLO_PROTOCOLS_PATH="$protocol_dir"

    cat > "${protocol_dir}/03-DEVELOPPEMENT.xml" <<'EOF'
<protocol name="03-DEVELOPPEMENT">
  <artefact_template>
    <pbi>
      <id>123</id>
      <title>PBI XML Green</title>
      <description>Test parser green XML natif</description>
    </pbi>
  </artefact_template>
</protocol>
EOF

    local output_file="${test_temp_dir}/output.xml"
    local cache_file
    cache_file=$(generate_cache_filename "03-DEVELOPPEMENT" "pbi")

    # --- Étape 1: Cache Miss ---
    echo "-> Test Case: Le parser doit créer les fichiers sur un cache miss"
    local log_miss
    log_miss=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "pbi" "full" "$output_file" "" 2>&1)
    
    assert_true "[ $? -eq 0 ]" "  La génération (miss) doit réussir"
    assert_file_exists "$output_file" "  Le fichier de sortie doit être créé (miss)"
    assert_file_exists "$cache_file" "  Le fichier cache doit être créé (miss)"
    assert_contains "$log_miss" "MISS" "  Le log doit indiquer un CACHE MISS"
    assert_file_contains "$output_file" "<title>PBI XML Green</title>" "  Le titre doit être présent dans la sortie (miss)"

    # --- Étape 2: Cache Hit ---
    echo "-> Test Case: Le parser doit utiliser le cache (HIT)"
    
    # On obtient le mtime du protocole AVANT le second appel
    local protocol_mtime
    protocol_mtime=$(get_file_mtime "${protocol_dir}/03-DEVELOPPEMENT.xml")
    
    # On passe ce mtime au contexte (même si la fonction ne l'utilise pas directement,
    # c'est une bonne pratique pour simuler le contexte réel)
    local log_hit
    log_hit=$(parse_and_generate_artefact_cached "03-DEVELOPPEMENT" "pbi" "full" "$output_file" "mtime=${protocol_mtime}" 2>&1)

    assert_contains "$log_hit" "HIT" "  Le log doit maintenant indiquer un CACHE HIT"
    # On vérifie que le contenu du fichier de sortie n'a PAS changé, prouvant le HIT
    assert_file_contains "$output_file" "<title>PBI XML Green</title>" "  Le contenu de sortie ne doit pas changer (hit)"
}

# --- Exécution ---

test_suite "Parser avec Cache (Green Path) - Scénario Complet"
test_cache_miss_then_hit_sequence
test_summary 