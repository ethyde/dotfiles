#!/usr/bin/env bash

# Script de diagnostic pour le problème assert_true
# Test spécifique de assert_true avec cache_is_valid

# Importer le framework de test
source "$(dirname "$0")/../framework/test_framework.sh"

# Importer les helpers à tester
source "$(dirname "$0")/../../modules/cache/cache_functions.sh"

echo "=== DIAGNOSTIC ASSERT_TRUE ==="
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
echo "Création des fichiers de test..."
echo "ok" > "$cache_file"
echo "$protocol_mtime" > "$mtime_file"

echo "Test direct :"
if cache_is_valid "$cache_file" "$protocol_mtime"; then
    echo "✅ cache_is_valid direct: SUCCÈS (code 0)"
else
    echo "❌ cache_is_valid direct: ÉCHEC (code $?)"
fi

echo ""
echo "=== Test avec eval (comme dans assert_true) ==="
echo "Test avec eval 'cache_is_valid \"$cache_file\" \"$protocol_mtime\"' :"
if eval "cache_is_valid \"$cache_file\" \"$protocol_mtime\""; then
    echo "✅ cache_is_valid avec eval: SUCCÈS (code 0)"
else
    echo "❌ cache_is_valid avec eval: ÉCHEC (code $?)"
fi

echo ""
echo "=== Test avec assert_true ==="
echo "Test avec assert_true :"
# Réinitialiser les compteurs de test
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

assert_true "cache_is_valid \"$cache_file\" \"$protocol_mtime\"" "Test assert_true avec cache_is_valid"

echo ""
echo "=== Test avec commande simple ==="
echo "Test avec assert_true et commande simple :"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

assert_true "true" "Test assert_true avec true"
assert_true "echo 'test' > /dev/null" "Test assert_true avec echo"

echo ""
echo "=== Test avec fonction simple ==="
echo "Test avec assert_true et fonction simple :"
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

test_simple_function() {
    return 0
}

assert_true "test_simple_function" "Test assert_true avec fonction simple"

echo ""
echo "=== Nettoyage ==="
rm -rf "$temp_dir"
echo "Temp dir supprimé: $temp_dir" 