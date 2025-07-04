#!/bin/bash

# Module performance_profiles.sh
# TASK-13-3: Création des profils adaptatifs de performance
# Implémente les trois profils de performance adaptatifs (MINIMAL, NORMAL, FULL)

# Fonction get_profile_config
# Retourne la configuration d'un profil donné
# @param $1 Le nom du profil (MINIMAL, NORMAL, FULL)
# @return Configuration du profil sous forme de variables
get_profile_config() {
    local profile="$1"
    
    if [[ -z "$profile" ]]; then
        echo "Erreur: Nom de profil requis"
        return 1
    fi
    
    case "$profile" in
        "MINIMAL")
            echo "MODULES=\"core/basic_functions\""
            echo "TARGET_TIME=\"0.050\""
            echo "DESCRIPTION=\"Commandes de configuration rapides\""
            ;;
        "NORMAL")
            echo "MODULES=\"core/basic_functions cache/regex_cache cache/id_cache\""
            echo "TARGET_TIME=\"0.200\""
            echo "DESCRIPTION=\"Commandes de développement standard\""
            ;;
        "FULL")
            echo "MODULES=\"all_modules\""
            echo "TARGET_TIME=\"1.000\""
            echo "DESCRIPTION=\"Commandes d'optimisation et monitoring\""
            ;;
        *)
            echo "Erreur: Profil inconnu '$profile'"
            return 1
            ;;
    esac
}

# Fonction detect_optimal_profile
# Détecte le profil optimal basé sur la commande et le contexte
# @param $1 La commande à analyser
# @return Le nom du profil optimal
detect_optimal_profile() {
    local command="$1"
    
    # Si AKLO_PROFILE est défini, l'utiliser comme override
    if [[ -n "$AKLO_PROFILE" ]]; then
        echo "$AKLO_PROFILE"
        return 0
    fi
    
    # Détection basée sur la commande
    case "$command" in
        "status"|"help"|"version"|"config")
            echo "MINIMAL"
            ;;
        "init"|"propose-pbi"|"plan"|"start-task"|"submit-task")
            echo "NORMAL"
            ;;
        "analyze"|"optimize"|"monitor"|"benchmark")
            echo "FULL"
            ;;
        *)
            # Par défaut, utiliser NORMAL
            echo "NORMAL"
            ;;
    esac
}

# Fonction apply_profile
# Configure l'environnement selon le profil spécifié
# @param $1 Le nom du profil à appliquer
apply_profile() {
    local profile="$1"
    
    if [[ -z "$profile" ]]; then
        echo "Erreur: Nom de profil requis"
        return 1
    fi
    
    # Récupérer la configuration du profil
    local config=$(get_profile_config "$profile")
    if [[ $? -ne 0 ]]; then
        echo "Erreur: Impossible de récupérer la configuration du profil '$profile'"
        return 1
    fi
    
    # Appliquer la configuration
    while IFS= read -r line; do
        if [[ "$line" =~ ^MODULES=\"(.*)\"$ ]]; then
            export AKLO_MODULES="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^TARGET_TIME=\"(.*)\"$ ]]; then
            export AKLO_TARGET_TIME="${BASH_REMATCH[1]}"
        elif [[ "$line" =~ ^DESCRIPTION=\"(.*)\"$ ]]; then
            export AKLO_PROFILE_DESCRIPTION="${BASH_REMATCH[1]}"
        fi
    done <<< "$config"
    
    # Marquer le profil comme appliqué
    export AKLO_CURRENT_PROFILE="$profile"
}

# Fonction validate_profile
# Valide la cohérence d'un profil
# @param $1 Le nom du profil à valider
# @return 0 si valide, 1 sinon
validate_profile() {
    local profile="$1"
    
    if [[ -z "$profile" ]]; then
        echo "Erreur: Nom de profil requis"
        return 1
    fi
    
    # Vérifier que le profil existe
    local config=$(get_profile_config "$profile" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "Erreur: Profil '$profile' non trouvé"
        return 1
    fi
    
    # Vérifier que la configuration contient les éléments requis
    if echo "$config" | grep -q "MODULES=\"" && echo "$config" | grep -q "TARGET_TIME=\""; then
        return 0
    else
        echo "Erreur: Configuration du profil '$profile' incomplète"
        return 1
    fi
}

# Fonction get_profile_metrics
# Récupère les métriques de performance d'un profil
# @param $1 Le nom du profil
# @return Métriques du profil
get_profile_metrics() {
    local profile="$1"
    
    if [[ -z "$profile" ]]; then
        echo "Erreur: Nom de profil requis"
        return 1
    fi
    
    # Valider le profil
    if ! validate_profile "$profile"; then
        return 1
    fi
    
    # Récupérer la configuration
    local config=$(get_profile_config "$profile")
    local modules_count=0
    local target_time=""
    
    # Parser la configuration
    while IFS= read -r line; do
        if [[ "$line" =~ ^MODULES=\"(.*)\"$ ]]; then
            local modules="${BASH_REMATCH[1]}"
            if [[ "$modules" == "all_modules" ]]; then
                modules_count=10  # Estimation pour tous les modules
            else
                modules_count=$(echo "$modules" | wc -w)
            fi
        elif [[ "$line" =~ ^TARGET_TIME=\"(.*)\"$ ]]; then
            target_time="${BASH_REMATCH[1]}"
        fi
    done <<< "$config"
    
    # Retourner les métriques
    echo "PROFILE=$profile"
    echo "MODULES_COUNT=$modules_count"
    echo "TARGET_TIME=${target_time}s"
    echo "LAST_MEASURED=N/A"
}

# Fonction d'initialisation du module
init_performance_profiles() {
    # Vérifier que les profils sont bien définis
    for profile in MINIMAL NORMAL FULL; do
        if ! validate_profile "$profile"; then
            echo "Erreur: Profil '$profile' invalide"
            return 1
        fi
    done
    
    return 0
}

# Initialiser le module au chargement
init_performance_profiles