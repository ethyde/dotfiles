#!/usr/bin/env bash

#==============================================================================
# Monitoring Dashboard - Dashboard de monitoring temps réel TASK-13-7
#
# Auteur: AI_Agent
# Version: 1.0
# Module de dashboard pour le monitoring en temps réel des métriques
#==============================================================================

# Configuration de base
set -e

# Dépendances
if [[ ! -f "${BASH_SOURCE%/*}/metrics_engine.sh" ]]; then
    echo "Erreur: metrics_engine.sh requis" >&2
    exit 1
fi

source "${BASH_SOURCE%/*}/metrics_engine.sh"

# Variables globales du dashboard
DASHBOARD_REFRESH_INTERVAL=2
DASHBOARD_MAX_LINES=50
DASHBOARD_HISTORY_SIZE=100

# Configuration d'affichage
DASHBOARD_COLORS=true
DASHBOARD_COMPACT_MODE=false
DASHBOARD_SHOW_GRAPHS=true

#==============================================================================
# Fonction: start_monitoring_dashboard
# Description: Démarre le dashboard de monitoring en temps réel
# Paramètres: $1 - intervalle de rafraîchissement (optionnel)
# Retour: 0 si succès, 1 si erreur
#==============================================================================
start_monitoring_dashboard() {
    local interval="${1:-$DASHBOARD_REFRESH_INTERVAL}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Initialisation du dashboard
    echo "=== Aklo Monitoring Dashboard ==="
    echo "Démarré à: ${timestamp}"
    echo "Intervalle: ${interval}s"
    echo "Appuyez sur Ctrl+C pour arrêter"
    echo ""
    
    # Boucle principale du dashboard
    while true; do
        display_dashboard_content
        sleep "$interval"
    done
}

#==============================================================================
# Fonction: display_dashboard_content
# Description: Affiche le contenu du dashboard
# Paramètres: Aucun
# Retour: 0 si succès, 1 si erreur
#==============================================================================
display_dashboard_content() {
    local timestamp=$(date '+%H:%M:%S')
    
    # Nettoyage de l'écran
    clear
    
    # En-tête du dashboard
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│                    AKLO MONITORING DASHBOARD                    │"
    echo "│                        ${timestamp}                             │"
    echo "└─────────────────────────────────────────────────────────────────┘"
    echo ""
    
    # Métriques globales
    display_global_metrics
    echo ""
    
    # Métriques de chargement
    display_loading_metrics
    echo ""
    
    # Métriques de performance
    display_performance_metrics
    echo ""
    
    # Métriques d'apprentissage
    display_learning_metrics
    echo ""
    
    # Alertes et notifications
    display_alerts
    echo ""
    
    # Pied de page
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│ Refresh: ${DASHBOARD_REFRESH_INTERVAL}s | Ctrl+C pour arrêter                           │"
    echo "└─────────────────────────────────────────────────────────────────┘"
}

#==============================================================================
# Fonction: display_global_metrics
# Description: Affiche les métriques globales
# Paramètres: Aucun
# Retour: 0 si succès, 1 si erreur
#==============================================================================
display_global_metrics() {
    echo "📊 MÉTRIQUES GLOBALES"
    echo "─────────────────────"
    echo "• Opérations totales: ${METRICS_OPERATIONS_COUNT}"
    echo "• Profils actifs: ${#PROFILE_USAGE_COUNT[@]}"
    echo "• Métriques de chargement: ${#LOADING_METRICS[@]}"
    echo "• Métriques de performance: ${#PERFORMANCE_METRICS[@]}"
    echo "• Métriques d'apprentissage: ${#LEARNING_METRICS[@]}"
    
    # Calcul du taux d'activité
    local activity_rate=$(calculate_activity_rate)
    echo "• Taux d'activité: ${activity_rate}%"
}

#==============================================================================
# Fonction: display_loading_metrics
# Description: Affiche les métriques de chargement
# Paramètres: Aucun
# Retour: 0 si succès, 1 si erreur
#==============================================================================
display_loading_metrics() {
    echo "⚡ MÉTRIQUES DE CHARGEMENT"
    echo "─────────────────────────"
    
    # Affichage des dernières métriques de chargement
    local count=0
    for key in "${!LOADING_METRICS[@]}"; do
        if [[ $count -lt 5 ]]; then
            local command=$(echo "$key" | cut -d'_' -f1)
            local profile=$(echo "$key" | cut -d'_' -f2)
            local time="${LOADING_METRICS[$key]}"
            echo "• ${command} (${profile}): ${time}s"
            ((count++))
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        echo "• Aucune métrique de chargement disponible"
    fi
}

#==============================================================================
# Fonction: display_performance_metrics
# Description: Affiche les métriques de performance
# Paramètres: Aucun
# Retour: 0 si succès, 1 si erreur
#==============================================================================
display_performance_metrics() {
    echo "🚀 MÉTRIQUES DE PERFORMANCE"
    echo "───────────────────────────"
    
    # Affichage des métriques de performance
    local count=0
    for key in "${!PERFORMANCE_METRICS[@]}"; do
        if [[ $count -lt 5 ]]; then
            local command=$(echo "$key" | cut -d'_' -f1)
            local profile=$(echo "$key" | cut -d'_' -f2)
            local time="${PERFORMANCE_METRICS[$key]}"
            echo "• ${command} (${profile}): ${time}s"
            ((count++))
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        echo "• Aucune métrique de performance disponible"
    fi
}

#==============================================================================
# Fonction: display_learning_metrics
# Description: Affiche les métriques d'apprentissage
# Paramètres: Aucun
# Retour: 0 si succès, 1 si erreur
#==============================================================================
display_learning_metrics() {
    echo "🧠 MÉTRIQUES D'APPRENTISSAGE"
    echo "────────────────────────────"
    
    # Affichage des métriques d'apprentissage
    local count=0
    for key in "${!LEARNING_METRICS[@]}"; do
        if [[ $count -lt 5 ]]; then
            local command=$(echo "$key" | cut -d'_' -f1)
            local profile=$(echo "$key" | cut -d'_' -f2)
            local confidence="${LEARNING_METRICS[$key]}"
            echo "• ${command} (${profile}): ${confidence}% confiance"
            ((count++))
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        echo "• Aucune métrique d'apprentissage disponible"
    fi
}

#==============================================================================
# Fonction: display_alerts
# Description: Affiche les alertes et notifications
# Paramètres: Aucun
# Retour: 0 si succès, 1 si erreur
#==============================================================================
display_alerts() {
    echo "🚨 ALERTES ET NOTIFICATIONS"
    echo "───────────────────────────"
    
    # Vérification des alertes de performance
    local alerts_count=0
    
    # Alerte pour chargement lent (simplifiée)
    for key in "${!LOADING_METRICS[@]}"; do
        local time="${LOADING_METRICS[$key]}"
        # Comparaison simple sans bc
        if [[ $(echo "$time" | cut -d'.' -f1) -gt 0 ]]; then
            local command=$(echo "$key" | cut -d'_' -f1)
            echo "⚠️  Chargement lent détecté: ${command} (${time}s)"
            ((alerts_count++))
        fi
    done
    
    # Alerte pour performance dégradée (simplifiée)
    for key in "${!PERFORMANCE_METRICS[@]}"; do
        local time="${PERFORMANCE_METRICS[$key]}"
        # Comparaison simple sans bc
        if [[ $(echo "$time" | cut -d'.' -f1) -gt 0 ]]; then
            local command=$(echo "$key" | cut -d'_' -f1)
            echo "⚠️  Performance dégradée: ${command} (${time}s)"
            ((alerts_count++))
        fi
    done
    
    # Alerte pour apprentissage peu fiable
    for key in "${!LEARNING_METRICS[@]}"; do
        local confidence="${LEARNING_METRICS[$key]}"
        if [[ $confidence -lt 70 ]]; then
            local command=$(echo "$key" | cut -d'_' -f1)
            echo "⚠️  Apprentissage peu fiable: ${command} (${confidence}%)"
            ((alerts_count++))
        fi
    done
    
    if [[ $alerts_count -eq 0 ]]; then
        echo "✅ Aucune alerte - Système opérationnel"
    fi
}

#==============================================================================
# Fonction: calculate_activity_rate
# Description: Calcule le taux d'activité du système
# Paramètres: Aucun
# Retour: Taux d'activité en pourcentage
#==============================================================================
calculate_activity_rate() {
    local total_operations=$METRICS_OPERATIONS_COUNT
    local max_operations=1000  # Référence arbitraire
    
    if [[ $total_operations -eq 0 ]]; then
        echo "0"
        return 0
    fi
    
    local rate=$(echo "scale=0; ($total_operations * 100) / $max_operations" | bc -l 2>/dev/null || echo "0")
    
    # Limitation à 100%
    if [[ $rate -gt 100 ]]; then
        rate=100
    fi
    
    echo "$rate"
}

#==============================================================================
# Fonction: export_dashboard_snapshot
# Description: Exporte un instantané du dashboard
# Paramètres: $1 - fichier de sortie (optionnel)
# Retour: 0 si succès, 1 si erreur
#==============================================================================
export_dashboard_snapshot() {
    local output_file="${1:-${AKLO_CACHE_DIR:-/tmp}/dashboard_snapshot_$(date +%Y%m%d_%H%M%S).txt}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    {
        echo "=== AKLO DASHBOARD SNAPSHOT ==="
        echo "Généré le: ${timestamp}"
        echo ""
        display_global_metrics
        echo ""
        display_loading_metrics
        echo ""
        display_performance_metrics
        echo ""
        display_learning_metrics
        echo ""
        display_alerts
    } > "$output_file"
    
    echo "Snapshot exporté: $output_file"
    return 0
}

#==============================================================================
# Fonction: generate_dashboard_report
# Description: Génère un rapport complet du dashboard
# Paramètres: $1 - période (last_hour, last_day, last_week)
# Retour: Rapport formaté
#==============================================================================
generate_dashboard_report() {
    local period="${1:-last_hour}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "=== RAPPORT DASHBOARD - ${period} ==="
    echo "Généré le: ${timestamp}"
    echo ""
    
    # Utilisation du rapport du metrics engine
    if declare -f generate_usage_report >/dev/null 2>&1; then
        generate_usage_report "$period"
    else
        echo "Erreur: Fonction generate_usage_report non disponible"
        return 1
    fi
    
    return 0
}

# Fonction d'initialisation automatique
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script exécuté directement
    start_monitoring_dashboard "$@"
fi