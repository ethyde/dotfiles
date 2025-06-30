#!/bin/sh
#==============================================================================
# Script Principal pour Exécuter Tous les Tests Aklo
#==============================================================================

# Source du framework de test
. "$(dirname "$0")/test_framework.sh"

# Source des tests spécifiques
. "$(dirname "$0")/test_aklo_functions.sh"

# Fonction principale qui exécute tous les tests
main() {
    echo "🧪 Framework de Tests Aklo - Version Native Shell"
    echo "Compatible: macOS, Linux, Windows WSL"
    echo ""
    
    # Vérifier que le script aklo existe
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    AKLO_SCRIPT="$SCRIPT_DIR/../bin/aklo"
    if [ ! -f "$AKLO_SCRIPT" ]; then
        echo "❌ Script aklo introuvable: $AKLO_SCRIPT"
        exit 1
    fi
    
    # Rendre le script exécutable si nécessaire
    chmod +x "$AKLO_SCRIPT"
    
    # Exécuter tous les tests
    test_get_next_id
    test_bump_version
    test_aklo_init
    test_aklo_propose_pbi
}

# Exécuter les tests avec le framework
run_tests main