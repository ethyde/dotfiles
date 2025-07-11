#!/usr/bin/env bash

# Script de validation des conventions de configuration Aklo
# Usage: ./validate-conventions.sh [fichier.conf]

CONFIG_FILE="${1:-/Users/eplouvie/Projets/dotfiles/aklo/config/.aklo.conf}"
ERRORS=0

echo "🔍 Validation des conventions de configuration Aklo"
echo "Fichier analysé: $CONFIG_FILE"
echo ""

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Erreur: Fichier de configuration non trouvé: $CONFIG_FILE"
    exit 1
fi

# Test 1: Variables globales en UPPERCASE
echo "📋 Test 1: Variables globales en UPPERCASE"
GLOBAL_VARS=$(awk '/^\[.*\]/{in_section=1; next} /^$/{in_section=0} !in_section && /^[a-z]/ && !/^#/' "$CONFIG_FILE" || true)
if [[ -n "$GLOBAL_VARS" ]]; then
    echo "❌ Variables globales en lowercase détectées:"
    echo "$GLOBAL_VARS" | sed 's/^/  /'
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Toutes les variables globales sont en UPPERCASE"
fi
echo ""

# Test 2: Variables de section en lowercase
echo "📋 Test 2: Variables de section en lowercase"
SECTION_VARS=$(awk '/^\[.*\]/{in_section=1; next} /^$/{in_section=0} in_section && /^[A-Z]/ && !/^#/' "$CONFIG_FILE" || true)
if [[ -n "$SECTION_VARS" ]]; then
    echo "❌ Variables de section en UPPERCASE détectées:"
    echo "$SECTION_VARS" | sed 's/^/  /'
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Toutes les variables de section sont en lowercase"
fi
echo ""

# Test 3: Valeurs textuelles avec guillemets
echo "📋 Test 3: Valeurs textuelles avec guillemets"
UNQUOTED_TEXT=$(grep -E "=.*[[:space:]].*[^\"']$" "$CONFIG_FILE" | grep -v "^#" || true)
if [[ -n "$UNQUOTED_TEXT" ]]; then
    echo "⚠️  Valeurs potentiellement non protégées par des guillemets:"
    echo "$UNQUOTED_TEXT" | sed 's/^/  /'
    echo "  Note: Vérifiez si ces valeurs contiennent des espaces ou caractères spéciaux"
else
    echo "✅ Toutes les valeurs textuelles semblent correctement protégées"
fi
echo ""

# Test 4: Noms de sections en lowercase
echo "📋 Test 4: Noms de sections en lowercase"
UPPERCASE_SECTIONS=$(grep -E "^\[[A-Z]" "$CONFIG_FILE" || true)
if [[ -n "$UPPERCASE_SECTIONS" ]]; then
    echo "❌ Sections avec noms en UPPERCASE détectées:"
    echo "$UPPERCASE_SECTIONS" | sed 's/^/  /'
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Tous les noms de sections sont en lowercase"
fi
echo ""

# Résumé
echo "📊 Résumé de la validation"
if [[ $ERRORS -eq 0 ]]; then
    echo "✅ Toutes les conventions sont respectées!"
    echo "🎉 Le fichier de configuration est conforme aux standards Aklo"
    exit 0
else
    echo "❌ $ERRORS erreur(s) de convention détectée(s)"
    echo "📖 Consultez aklo/config/CONVENTIONS.md pour les détails"
    exit 1
fi