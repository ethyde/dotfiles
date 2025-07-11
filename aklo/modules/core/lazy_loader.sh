#!/usr/bin/env bash
#==============================================================================
# LAZY LOADER V2 - Chargement paresseux robuste
#==============================================================================

# Cache en mémoire des modules déjà chargés pour éviter les re-chargements
declare -A LOADED_MODULES_CACHE

#------------------------------------------------------------------------------
# Charge un module de manière sécurisée (fail-safe).
# PREND EN ENTRÉE un chemin relatif depuis le répertoire /modules.
#
# @param $1 Chemin relatif du module (ex: "core/parser.sh" ou "commands/pbi_commands.sh")
#------------------------------------------------------------------------------
load_module_fail_safe() {
    local relative_module_path="$1"
    
    # 1. Validation des entrées
    if [ -z "$relative_module_path" ]; then
        echo "Erreur interne: tentative de chargement d'un module vide." >&2
        return 1 # Échoue pour signaler un problème de logique interne
    fi

    # 2. Vérifier si le module est déjà dans le cache mémoire
    if [ -n "${LOADED_MODULES_CACHE[$relative_module_path]}" ]; then
        return 0 # Déjà chargé, succès immédiat
    fi

    # 3. Construire le chemin absolu et vérifier l'existence du fichier
    local absolute_module_path="${AKLO_PROJECT_ROOT}/aklo/modules/${relative_module_path}"
    if [ ! -f "$absolute_module_path" ]; then
        echo "Erreur critique: Module '${relative_module_path}' introuvable." >&2
        echo "  Chemin cherché: ${absolute_module_path}" >&2
        return 1
    fi

    # 4. Charger (sourcer) le module
    source "$absolute_module_path"
    
    # 5. Mettre à jour le cache mémoire pour les prochains appels
    LOADED_MODULES_CACHE["$relative_module_path"]=true
    return 0
}