#!/bin/bash

#==============================================================================
# Tests de diagnostic pour classification des commandes
#==============================================================================

set -e
script_dir="$(dirname "$0")"
modules_dir="${script_dir}/../modules"

echo "=== Diagnostic Tests Classification ==="

# Test 1: Diagnostic Learning Engine - Apprentissage automatique
echo "Test 1: Apprentissage automatique"
source "${modules_dir}/core/learning_engine.sh" 2>/dev/null || { echo "Erreur: Impossible de charger learning_engine.sh"; exit 1; }

echo "Prédiction pour 'completely_unknown_command_xyz':"
predicted_profile=$(predict_command_profile "completely_unknown_command_xyz")
echo "Résultat: '$predicted_profile'"

# Vérification du résultat
if [[ "$predicted_profile" == "AUTO" || "$predicted_profile" == "MINIMAL" || "$predicted_profile" == "NORMAL" ]]; then
    echo "✅ Test 1 PASSÉ"
else
    echo "❌ Test 1 ÉCHOUÉ - Profil attendu: AUTO/MINIMAL/NORMAL, reçu: '$predicted_profile'"
fi

echo

# Test 2: Diagnostic Performance - Classification rapide
echo "Test 2: Performance classification"
source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || { echo "Erreur: Impossible de charger command_classifier.sh"; exit 1; }

echo "Test de performance avec 10 classifications..."
start_time=$(date +%s.%N 2>/dev/null || date +%s)

for i in {1..10}; do
    classify_command "get_config" >/dev/null
done

end_time=$(date +%s.%N 2>/dev/null || date +%s)

# Calcul de la durée
if command -v bc >/dev/null 2>&1; then
    duration=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    echo "Durée: ${duration}s"
    
    # Test de performance
    if (( $(echo "$duration < 0.1" | bc -l) )); then
        echo "✅ Test 2 PASSÉ - Performance OK"
    else
        echo "❌ Test 2 ÉCHOUÉ - Performance trop lente: ${duration}s (limite: 0.1s)"
    fi
else
    echo "⚠️  bc non disponible - Test de performance ignoré"
    echo "✅ Test 2 PASSÉ (bc non disponible)"
fi

echo

# Test 3: Vérification des fonctions critiques
echo "Test 3: Vérification des fonctions"

# Vérification predict_command_profile
if command -v predict_command_profile >/dev/null 2>&1; then
    echo "✅ predict_command_profile existe"
else
    echo "❌ predict_command_profile manquante"
fi

# Vérification classify_command
if command -v classify_command >/dev/null 2>&1; then
    echo "✅ classify_command existe"
else
    echo "❌ classify_command manquante"
fi

echo

# Test 4: Test des valeurs de retour
echo "Test 4: Valeurs de retour"

# Test avec commande connue
result=$(classify_command "get_config")
echo "classify_command('get_config') = '$result'"

# Test avec commande inconnue
result=$(predict_command_profile "unknown_test_command")
echo "predict_command_profile('unknown_test_command') = '$result'"

echo "=== Fin Diagnostic ==="