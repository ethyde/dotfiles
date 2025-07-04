#!/bin/bash

#==============================================================================
# Démonstration du Système de Métriques Avancées - TASK-13-7
#
# Auteur: AI_Agent
# Version: 1.0
# Script de démonstration du système de métriques et monitoring
#==============================================================================

# Configuration
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Variables de démonstration
DEMO_CACHE_DIR="/tmp/aklo_demo_cache"
DEMO_METRICS_DB="/tmp/demo_metrics_history.db"

# Nettoyage et préparation
echo "🧹 Préparation de l'environnement de démonstration..."
rm -rf "${DEMO_CACHE_DIR}"
mkdir -p "${DEMO_CACHE_DIR}"
export AKLO_CACHE_DIR="${DEMO_CACHE_DIR}"
export AKLO_METRICS_DB="${DEMO_METRICS_DB}"

# Chargement des modules
echo "📦 Chargement des modules de métriques..."
source "${PROJECT_ROOT}/modules/core/metrics_engine.sh"
source "${PROJECT_ROOT}/modules/core/monitoring_dashboard.sh"

echo "✅ Système de métriques initialisé avec succès !"
echo ""

#==============================================================================
# Démonstration 1: Collecte de métriques de chargement
#==============================================================================
echo "🚀 === DÉMONSTRATION 1: Métriques de Chargement ==="
echo ""

# Simulation de différentes commandes avec différents profils
echo "Simulation de commandes avec profils adaptatifs..."

# Commandes MINIMAL
collect_loading_metrics "get_config" "MINIMAL" "cli" "$(date +%s.%N)"
collect_loading_metrics "status" "MINIMAL" "cli" "$(date +%s.%N)"
collect_loading_metrics "help" "MINIMAL" "cli" "$(date +%s.%N)"
collect_loading_metrics "version" "MINIMAL" "cli" "$(date +%s.%N)"

# Commandes NORMAL
collect_loading_metrics "plan" "NORMAL" "cli" "$(date +%s.%N)"
collect_loading_metrics "dev" "NORMAL" "cli" "$(date +%s.%N)"
collect_loading_metrics "debug" "NORMAL" "cli" "$(date +%s.%N)"
collect_loading_metrics "review" "NORMAL" "cli" "$(date +%s.%N)"

# Commandes FULL
collect_loading_metrics "optimize" "FULL" "cli" "$(date +%s.%N)"
collect_loading_metrics "benchmark" "FULL" "cli" "$(date +%s.%N)"
collect_loading_metrics "monitor" "FULL" "cli" "$(date +%s.%N)"

echo "✅ Métriques de chargement collectées pour 11 commandes"
echo ""

#==============================================================================
# Démonstration 2: Suivi des performances
#==============================================================================
echo "📊 === DÉMONSTRATION 2: Suivi des Performances ==="
echo ""

echo "Simulation de performances réelles..."

# Performances MINIMAL (très rapides)
track_performance_metrics "get_config" "MINIMAL" "0.025" "success"
track_performance_metrics "status" "MINIMAL" "0.040" "success"
track_performance_metrics "help" "MINIMAL" "0.020" "success"
track_performance_metrics "version" "MINIMAL" "0.015" "success"

# Performances NORMAL (moyennes)
track_performance_metrics "plan" "NORMAL" "0.150" "success"
track_performance_metrics "dev" "NORMAL" "0.180" "success"
track_performance_metrics "debug" "NORMAL" "0.200" "success"
track_performance_metrics "review" "NORMAL" "0.170" "success"

# Performances FULL (plus lentes mais acceptables)
track_performance_metrics "optimize" "FULL" "0.800" "success"
track_performance_metrics "benchmark" "FULL" "0.950" "success"
track_performance_metrics "monitor" "FULL" "0.750" "success"

echo "✅ Performances suivies pour 11 commandes"
echo ""

#==============================================================================
# Démonstration 3: Monitoring de l'apprentissage
#==============================================================================
echo "🧠 === DÉMONSTRATION 3: Monitoring de l'Apprentissage ==="
echo ""

echo "Simulation de l'apprentissage automatique..."

# Apprentissage de nouvelles commandes
monitor_learning_efficiency "new_command_1" "NORMAL" "85" "prediction"
monitor_learning_efficiency "new_command_2" "MINIMAL" "92" "prediction"
monitor_learning_efficiency "unknown_cmd" "AUTO" "78" "learning"
monitor_learning_efficiency "experimental_feature" "FULL" "88" "learning"
monitor_learning_efficiency "custom_script" "NORMAL" "95" "confident"

# Apprentissage avec différents niveaux de confiance
monitor_learning_efficiency "low_confidence_cmd" "NORMAL" "65" "uncertain"
monitor_learning_efficiency "high_confidence_cmd" "MINIMAL" "98" "confident"

echo "✅ Apprentissage automatique simulé pour 7 nouvelles commandes"
echo ""

#==============================================================================
# Démonstration 4: Génération de rapports
#==============================================================================
echo "📋 === DÉMONSTRATION 4: Génération de Rapports ==="
echo ""

echo "Génération du rapport d'usage complet..."
echo ""
generate_usage_report "demo_session"
echo ""

echo "✅ Rapport d'usage généré avec succès"
echo ""

#==============================================================================
# Démonstration 5: Dashboard de monitoring
#==============================================================================
echo "📺 === DÉMONSTRATION 5: Dashboard de Monitoring ==="
echo ""

echo "Affichage du dashboard de monitoring..."
echo ""

# Affichage des métriques globales
display_global_metrics
echo ""

# Affichage des métriques de chargement
display_loading_metrics
echo ""

# Affichage des métriques de performance
display_performance_metrics
echo ""

# Affichage des métriques d'apprentissage
display_learning_metrics
echo ""

# Affichage des alertes
display_alerts
echo ""

echo "✅ Dashboard de monitoring affiché avec succès"
echo ""

#==============================================================================
# Démonstration 6: Export et persistance
#==============================================================================
echo "💾 === DÉMONSTRATION 6: Export et Persistance ==="
echo ""

echo "Export d'un snapshot du dashboard..."
local snapshot_file="${DEMO_CACHE_DIR}/demo_snapshot.txt"
export_dashboard_snapshot "$snapshot_file"
echo ""

echo "Contenu de la base de données de métriques:"
echo "─────────────────────────────────────────────"
head -20 "${DEMO_METRICS_DB}"
echo ""
echo "... ($(wc -l < "${DEMO_METRICS_DB}") lignes au total)"
echo ""

echo "✅ Export et persistance validés"
echo ""

#==============================================================================
# Résumé de la démonstration
#==============================================================================
echo "🎯 === RÉSUMÉ DE LA DÉMONSTRATION ==="
echo ""
echo "Système de métriques avancées TASK-13-7 - Fonctionnalités démontrées:"
echo ""
echo "✅ Collecte automatique des métriques de chargement"
echo "✅ Suivi en temps réel des performances par profil"
echo "✅ Monitoring de l'efficacité de l'apprentissage automatique"
echo "✅ Génération de rapports d'usage détaillés"
echo "✅ Dashboard de monitoring en temps réel"
echo "✅ Export et persistance des données"
echo "✅ Système d'alertes pour problèmes de performance"
echo "✅ Intégration complète avec l'architecture existante"
echo ""
echo "📊 Statistiques de la démonstration:"
echo "• Opérations de métriques: ${METRICS_OPERATIONS_COUNT}"
echo "• Profils utilisés: ${#PROFILE_USAGE_COUNT[@]}"
echo "• Métriques de chargement: ${#LOADING_METRICS[@]}"
echo "• Métriques de performance: ${#PERFORMANCE_METRICS[@]}"
echo "• Métriques d'apprentissage: ${#LEARNING_METRICS[@]}"
echo ""
echo "📁 Fichiers générés:"
echo "• Base de données: ${DEMO_METRICS_DB}"
echo "• Snapshot dashboard: ${snapshot_file}"
echo "• Cache directory: ${DEMO_CACHE_DIR}"
echo ""
echo "🎉 Démonstration terminée avec succès !"
echo ""
echo "Pour nettoyer les fichiers de démonstration:"
echo "rm -rf ${DEMO_CACHE_DIR}"
echo ""