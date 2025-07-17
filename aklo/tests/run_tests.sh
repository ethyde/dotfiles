#!/usr/bin/env bash
#==============================================================================
# Script Principal pour Exécuter Tous les Tests Aklo
#==============================================================================

# Exporter la racine du projet pour les scripts de test
export AKLO_PROJECT_ROOT
AKLO_PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

# Fonction principale qui exécute tous les tests
main() {
    local run_all=false
    if [ "$1" = "--all" ]; then
        run_all=true
        echo "🏃 Mode d'exécution complet (inclus les benchmarks et tests de performance)"
    else
        echo "🚀 Mode d'exécution rapide (exclus les benchmarks et tests de performance)"
    fi

    echo "🧪 Framework de Tests Aklo - Version Native Shell"
    echo "Compatible: macOS, Linux, Windows WSL"
    echo ""

    # Vérifier que le script aklo existe
    local SCRIPT_DIR
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    local AKLO_SCRIPT="$SCRIPT_DIR/../bin/aklo"
    if [ ! -f "$AKLO_SCRIPT" ]; then
        echo "❌ Script aklo introuvable: $AKLO_SCRIPT"
        exit 1
    fi

    # Rendre le script exécutable si nécessaire
    chmod +x "$AKLO_SCRIPT"

    # Découverte des fichiers de test
    TEST_DIR=$(dirname "$0")
    echo "🔍 Découverte et exécution des fichiers de test..."
    
    local test_files
    # --- Exclusion des répertoires archive et diagnostic ---
    if [ "$run_all" = true ]; then
        test_files=$(find "$TEST_DIR" -type f -name 'test_*.sh' ! -path "*/archive/*" ! -path "*/diagnostic/*")
    else
        test_files=$(find "$TEST_DIR" -type f -name 'test_*.sh' ! -path "*/archive/*" ! -path "*/diagnostic/*" | grep -v -E 'benchmark|performance')
    fi
    
    echo "$test_files" | while read -r test_script; do
        # Exclure le framework lui-même et les lignes vides potentielles
        if [ "$test_script" != "$TEST_DIR/framework/test_framework.sh" ] && [ -n "$test_script" ]; then
            echo -e "\n--- Exécution de $(basename "$test_script") ---"
            # Exécuter chaque script de test avec bash
            bash "$test_script"
        fi
    done
    echo -e "\n✅ Tous les fichiers de test ont été exécutés."
}

# Le framework n'est sourcé qu'ici pour que la fonction run_tests soit définie
source "$(dirname "$0")/framework/test_framework.sh"

# Appel de la fonction main en passant les arguments du script
main "$@"
