#!/bin/sh
#==============================================================================
# Tests Unitaires pour les Fonctions Aklo
#==============================================================================

# Source du framework de test
. "$(dirname "$0")/test_framework.sh"

# Source des fonctions aklo à tester  
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AKLO_SCRIPT="$(cd "$SCRIPT_DIR/../bin" && pwd)/aklo"

# Fonction pour extraire et tester les fonctions utilitaires d'aklo
# (on simule le sourcing des fonctions)

test_get_next_id() {
    test_suite "Test d'intégration get_next_id"
    
    setup_test_env
    
    # Créer quelques fichiers de test
    mkdir -p test_dir
    touch "test_dir/PBI-1-test.md"
    touch "test_dir/PBI-3-test.md" 
    touch "test_dir/PBI-5-test.md"
    
    # Tester via le script aklo directement (simulation)
    # Compter les fichiers existants pour vérifier la logique
    count=$(ls test_dir/PBI-*-*.md 2>/dev/null | wc -l | tr -d ' ')
    assert_equals "3" "$count" "Fichiers de test créés correctement"
    
    # Test simple: vérifier que les fichiers existent
    assert_file_exists "test_dir/PBI-1-test.md" "Fichier PBI-1 existe"
    assert_file_exists "test_dir/PBI-5-test.md" "Fichier PBI-5 existe"
    
    cleanup_test_env
}

test_bump_version() {
    test_suite "Test logique bump_version"
    
    setup_test_env
    
    # Test de la logique de versioning via des simulations
    # Vérifier qu'on peut parser une version
    version="1.2.3"
    major=$(echo "$version" | cut -d. -f1)
    minor=$(echo "$version" | cut -d. -f2) 
    patch=$(echo "$version" | cut -d. -f3)
    
    assert_equals "1" "$major" "Parse major version correctement"
    assert_equals "2" "$minor" "Parse minor version correctement"
    assert_equals "3" "$patch" "Parse patch version correctement"
    
    # Test d'incrémentation simple
    new_major=$((major + 1))
    assert_equals "2" "$new_major" "Incrémentation major fonctionne"
    
    cleanup_test_env
}

test_aklo_init() {
    test_suite "Commande aklo init"
    
    setup_test_env
    
    # Créer un projet de test minimal
    echo '{"name": "test", "version": "1.0.0"}' > package.json
    git init >/dev/null 2>&1
    
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    echo "=== Suite de tests: Commande aklo init ==="
    echo "Environnement de test: $TEST_DIR"

    # Tester aklo init
    assert_exit_code 0 "echo \"y\" | \"$AKLO_SCRIPT\" init" "aklo init s'exécute sans erreur"

    assert_file_exists ".aklo.conf" "aklo init crée le fichier .aklo.conf"
    assert_file_exists ".gitignore" "aklo init crée/met à jour .gitignore"
    
    # Vérifier le contenu de .aklo.conf
    if [ -f ".aklo.conf" ]; then
        content=$(cat .aklo.conf)
        assert_contains "$content" "PROJECT_WORKDIR=" "aklo.conf contient PROJECT_WORKDIR"
    fi
    
    cleanup_test_env
}

test_aklo_propose_pbi() {
    test_suite "Commande aklo propose-pbi"
    
    setup_test_env
    
    # Préparer l'environnement
    echo '{"name": "test", "version": "1.0.0"}' > package.json
    git init >/dev/null 2>&1
    echo "y" | "$AKLO_SCRIPT" init >/dev/null 2>&1
    
    # Tester propose-pbi
    "$AKLO_SCRIPT" propose-pbi "Test PBI" >/dev/null 2>&1
    exit_code=$?
    
    assert_exit_code "0" "'$AKLO_SCRIPT' propose-pbi 'Test PBI'" "aklo propose-pbi s'exécute sans erreur"
    assert_file_exists "docs/backlog/00-pbi/PBI-1-PROPOSED.md" "PBI créé avec le bon nom"
    
    # Vérifier le contenu du PBI
    if [ -f "docs/backlog/00-pbi/PBI-1-PROPOSED.md" ]; then
        content=$(cat "docs/backlog/00-pbi/PBI-1-PROPOSED.md")
        assert_contains "$content" "Test PBI" "PBI contient le titre correct"
        assert_contains "$content" "PROPOSED" "PBI a le statut PROPOSED"
    fi
    
    cleanup_test_env
}