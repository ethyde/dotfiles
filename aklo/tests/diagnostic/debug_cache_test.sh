#!/usr/bin/env bash

# Script de diagnostic pour le problème cache_is_valid
# Test direct de la fonction sans le framework de test

# Importer les helpers à tester
source "$(dirname "$0")/../../modules/cache/cache_functions.sh"

echo "=== DIAGNOSTIC CACHE_IS_VALID ==="
echo ""

# Configuration
export AKLO_PROJECT_ROOT="/tmp/aklo-test-root"
temp_dir=$(mktemp -d)
cache_file="$temp_dir/test_cache.parsed"
mtime_file="${cache_file}.mtime"
protocol_mtime="1234567890"

echo "Temp dir: $temp_dir"
echo "Cache file: $cache_file"
echo "Mtime file: $mtime_file"
echo "Protocol mtime: $protocol_mtime"
echo ""

# Test direct de la fonction
echo "=== Test direct de cache_is_valid ==="

# Cas 4 : cache et .mtime corrects
echo "Création des fichiers de test..."
echo "ok" > "$cache_file"
echo "$protocol_mtime" > "$mtime_file"

echo "Contenu des fichiers :"
echo "cache_file ($cache_file): '$(cat "$cache_file")'"
echo "mtime_file ($mtime_file): '$(cat "$mtime_file")'"
echo ""

echo "Test de cache_is_valid..."
if cache_is_valid "$cache_file" "$protocol_mtime"; then
    echo "✅ cache_is_valid retourne SUCCÈS (code 0)"
else
    echo "❌ cache_is_valid retourne ÉCHEC (code $?)"
fi

echo ""
echo "Test avec debug activé..."
# Test avec debug pour voir les valeurs internes
cache_is_valid "$cache_file" "$protocol_mtime"
echo "Code de sortie: $?"

echo ""
echo "Test manuel de la logique..."
if [ -f "$cache_file" ] && [ -f "$mtime_file" ]; then
    echo "✅ Les deux fichiers existent"
    local mtime
    mtime=$(cat "$mtime_file")
    echo "mtime lu: '$mtime'"
    echo "mtime attendu: '$protocol_mtime'"
    if [ "$mtime" = "$protocol_mtime" ]; then
        echo "✅ Les mtime sont identiques"
        echo "Code de sortie attendu: 0"
    else
        echo "❌ Les mtime sont différents"
        echo "Code de sortie attendu: 1"
    fi
else
    echo "❌ Un des fichiers n'existe pas"
    echo "Code de sortie attendu: 1"
fi

echo ""
echo "=== Nettoyage ==="
rm -rf "$temp_dir"
echo "Temp dir supprimé: $temp_dir" 