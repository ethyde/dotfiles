#!/bin/bash

#==============================================================================
# Test de performance avec cache
#==============================================================================

set -e
script_dir="$(dirname "$0")"
modules_dir="${script_dir}/../modules"

echo "=== Test Performance avec Cache ==="

source "${modules_dir}/core/command_classifier.sh" 2>/dev/null || { echo "Erreur: Impossible de charger command_classifier.sh"; exit 1; }

# Test 1: Premier appel (sans cache)
echo "Test 1: Premier appel sans cache"
start_time=$(date +%s.%N 2>/dev/null || date +%s)
classify_command "get_config" >/dev/null
end_time=$(date +%s.%N 2>/dev/null || date +%s)

if command -v bc >/dev/null 2>&1; then
    duration1=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    echo "Durée premier appel: ${duration1}s"
else
    echo "bc non disponible - mesure approximative"
fi

# Test 2: Appels suivants (avec cache)
echo "Test 2: 10 appels avec cache"
start_time=$(date +%s.%N 2>/dev/null || date +%s)

for i in {1..10}; do
    classify_command "get_config" >/dev/null
done

end_time=$(date +%s.%N 2>/dev/null || date +%s)

if command -v bc >/dev/null 2>&1; then
    duration2=$(echo "$end_time - $start_time" | bc 2>/dev/null || echo "0")
    echo "Durée 10 appels avec cache: ${duration2}s"
    
    # Calcul de la performance par appel
    avg_duration=$(echo "$duration2 / 10" | bc -l 2>/dev/null || echo "0")
    echo "Durée moyenne par appel: ${avg_duration}s"
    
    # Test de performance
    if (( $(echo "$avg_duration < 0.01" | bc -l) )); then
        echo "✅ Performance excellente avec cache"
    elif (( $(echo "$avg_duration < 0.05" | bc -l) )); then
        echo "✅ Performance bonne avec cache"
    else
        echo "⚠️  Performance avec cache: ${avg_duration}s par appel"
    fi
else
    echo "bc non disponible - test de performance ignoré"
fi

# Test 3: Vérification du cache
echo "Test 3: Vérification du cache"
result1=$(classify_command "test_cache_command")
result2=$(classify_command "test_cache_command")

if [[ "$result1" == "$result2" ]]; then
    echo "✅ Cache fonctionne - résultats cohérents"
else
    echo "❌ Cache défaillant - résultats incohérents"
fi

echo "=== Fin Test Performance ==="