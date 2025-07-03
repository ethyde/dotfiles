#!/bin/bash

# Tests unitaires pour TASK-6-4 - Phase GREEN
# Test des fonctionnalités de monitoring cache

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 Tests Phase GREEN - Monitoring Cache${NC}"
echo "======================================================================="

cd /Users/eplouvie/Projets/dotfiles

# Source des fonctions de monitoring
source ak../modules/cache/cache_monitoring.sh

# Test 1: Configuration cache avancée
echo -e "${BLUE}Test 1: Configuration cache avancée${NC}"
if command -v get_cache_config >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Fonction get_cache_config disponible"
    
    # Tester la lecture de configuration
    get_cache_config
    if [ "$CACHE_ENABLED" = "true" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Configuration cache lue correctement"
    else
        echo -e "${RED}✗ FAIL${NC}: Configuration cache incorrecte"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Fonction get_cache_config manquante"
fi

# Test 2: Commande aklo cache status
echo -e "${BLUE}Test 2: Commande aklo cache status${NC}"
if ./aklo/bin/aklo cache status >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Commande 'aklo cache status' fonctionne"
    
    # Vérifier l'output
    output=$(./aklo/bin/aklo cache status 2>&1)
    if echo "$output" | grep -q "STATUT DU CACHE AKLO"; then
        echo -e "${GREEN}✓ PASS${NC}: Output cache status correct"
    else
        echo -e "${RED}✗ FAIL${NC}: Output cache status incorrect"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Commande 'aklo cache status' échoue"
fi

# Test 3: Commande aklo cache clear
echo -e "${BLUE}Test 3: Commande aklo cache clear${NC}"
# Créer un fichier cache pour le test
mkdir -p /tmp/aklo_cache
echo "test" > /tmp/aklo_cache/test.parsed

if ./aklo/bin/aklo cache clear >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Commande 'aklo cache clear' fonctionne"
    
    # Vérifier que le cache est vidé
    if [ ! -f "/tmp/aklo_cache/test.parsed" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Cache effectivement vidé"
    else
        echo -e "${RED}✗ FAIL${NC}: Cache non vidé"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Commande 'aklo cache clear' échoue"
fi

# Test 4: Commande aklo cache benchmark
echo -e "${BLUE}Test 4: Commande aklo cache benchmark${NC}"
if ./aklo/bin/aklo cache benchmark >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Commande 'aklo cache benchmark' fonctionne"
else
    echo -e "${RED}✗ FAIL${NC}: Commande 'aklo cache benchmark' échoue"
fi

# Test 5: Métriques cache
echo -e "${BLUE}Test 5: Métriques cache${NC}"
if command -v record_cache_metric >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Fonction record_cache_metric disponible"
    
    # Tester l'enregistrement d'une métrique
    record_cache_metric "hit" 50
    if [ -f "/tmp/aklo_cache/cache_metrics.json" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Fichier métriques créé"
        
        # Vérifier le contenu
        if grep -q '"hits"' "/tmp/aklo_cache/cache_metrics.json"; then
            echo -e "${GREEN}✓ PASS${NC}: Métriques enregistrées correctement"
        else
            echo -e "${RED}✗ FAIL${NC}: Métriques incorrectes"
        fi
    else
        echo -e "${RED}✗ FAIL${NC}: Fichier métriques non créé"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Fonction record_cache_metric manquante"
fi

# Test 6: Aide des commandes cache
echo -e "${BLUE}Test 6: Aide des commandes cache${NC}"
if ./aklo/bin/aklo cache --help >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Aide des commandes cache disponible"
    
    # Vérifier le contenu de l'aide
    help_output=$(./aklo/bin/aklo cache --help 2>&1)
    if echo "$help_output" | grep -q "status" && echo "$help_output" | grep -q "clear" && echo "$help_output" | grep -q "benchmark"; then
        echo -e "${GREEN}✓ PASS${NC}: Aide complète et correcte"
    else
        echo -e "${RED}✗ FAIL${NC}: Aide incomplète"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Aide des commandes cache manquante"
fi

# Test 7: Intégration métriques dans parser
echo -e "${BLUE}Test 7: Intégration métriques dans parser${NC}"
# Nettoyer le cache
rm -rf /tmp/aklo_cache
mkdir -p /tmp/aklo_cache

# Générer un PBI pour tester les métriques
if ./aklo/bin/aklo propose-pbi "Test Metrics Integration" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}: Génération PBI avec métriques réussie"
    
    # Vérifier que les métriques ont été enregistrées
    if [ -f "/tmp/aklo_cache/cache_metrics.json" ]; then
        echo -e "${GREEN}✓ PASS${NC}: Métriques automatiquement enregistrées"
        
        # Vérifier le contenu des métriques
        metrics_content=$(cat /tmp/aklo_cache/cache_metrics.json)
        if echo "$metrics_content" | grep -q '"total_requests": [1-9]'; then
            echo -e "${GREEN}✓ PASS${NC}: Métriques contiennent des données"
        else
            echo -e "${RED}✗ FAIL${NC}: Métriques vides ou incorrectes"
        fi
    else
        echo -e "${RED}✗ FAIL${NC}: Métriques non enregistrées automatiquement"
    fi
else
    echo -e "${RED}✗ FAIL${NC}: Génération PBI avec métriques échouée"
fi

# Nettoyer les fichiers de test
rm -f docs/backlog/00-pbi/PBI-*-Test-Metrics-*.md
rm -rf /tmp/aklo_cache

echo "======================================================================="
echo -e "${GREEN}🎉 Phase GREEN terminée !${NC}"