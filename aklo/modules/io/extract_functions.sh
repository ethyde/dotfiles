#!/bin/bash

# Fonctions d'extraction et de mise en cache pour aklo
# TASK-6-2: Fonction de mise en cache des structures protocoles
# Phase BLUE: Version refactorisée et optimisée

# Source des fonctions de cache (TASK-6-1)
source "$(dirname "${BASH_SOURCE[0]}")/../cache/cache_functions.sh"

# Fonction utilitaire pour obtenir le pattern d'un type d'artefact
# Utilise un case au lieu d'un tableau associatif pour compatibilité
get_artefact_pattern_internal() {
    local artefact_type="$1"
    
    case "$artefact_type" in
        "PBI")
            echo "### 2\.3\. Structure Obligatoire Du Fichier PBI"
            ;;
        "TASK")
            echo "### 2\.3\. Structure Obligatoire Du Fichier Task"
            ;;
        "DEBUG")
            echo "### 2\.3\. Structure Obligatoire Du Fichier Debug"
            ;;
        "ARCH")
            echo "### 2\.3\. Structure Obligatoire Du Fichier ARCH"
            ;;
        "REVIEW")
            echo "### 2\.2\. Structure Obligatoire Du Fichier Review"
            ;;
        "JOURNAL")
            echo "### 2\.3\. Structure Obligatoire du Fichier Journal"
            ;;
        "REFACTOR")
            echo "### 2\.3\. Structure Obligatoire Du Fichier Refactor"
            ;;
        "RELEASE")
            echo "### 2\.3\. Structure Obligatoire du Fichier Release"
            ;;
        "HOTFIX")
            echo "### 2\.3\. Structure Obligatoire du Fichier Hotfix"
            ;;
        "OPTIM")
            echo "### 2\.3\. Structure Obligatoire Du Fichier Optim"
            ;;
        "AUDIT")
            echo "### 2\.3\. Structure Obligatoire du Fichier d'Audit"
            ;;
        "EXPERIMENT")
            echo "### 2\.3\. Structure Obligatoire Du Fichier Experiment"
            ;;
        "USER-DOCS")
            echo "### 2\.3\. Structure Obligatoire du Fichier de Documentation"
            ;;
        "COMPETITION")
            echo "### 2\.3\. Structure Obligatoire du Fichier d'Analyse"
            ;;
        "TRACKING-PLAN")
            echo "### 2\.3\. Structure Obligatoire du Fichier de Tracking"
            ;;
        "ONBOARDING")
            echo "### 2\.3\. : STRUCTURE DU RAPPORT D'ONBOARDING"
            ;;
        "DEPRECATION")
            echo "### 2\.3\. Structure Obligatoire du Fichier de Dépréciation"
            ;;
        "KNOWLEDGE-BASE")
            echo "### 2\.2\. Structure Recommandée du Fichier"
            ;;
        "FAST-TRACK")
            echo "### 2\.3\. Structure Obligatoire du Fichier Fast-Track"
            ;;
        "META-IMPROVEMENT")
            echo "### 2\.3\. Structure Obligatoire du Fichier Improve"
            ;;
        *)
            return 1
            ;;
    esac
}

# Fonction utilitaire pour valider un type d'artefact
# Usage: is_valid_artefact_type <artefact_type>
# Retourne: 0 si valide, 1 si invalide
is_valid_artefact_type() {
    local artefact_type="$1"
    
    if [ -z "$artefact_type" ]; then
        return 1
    fi
    
    # Vérifier si le type existe en essayant d'obtenir son pattern
    get_artefact_pattern_internal "$artefact_type" >/dev/null 2>&1
}

# Fonction utilitaire pour obtenir le pattern d'un type d'artefact
# Usage: get_artefact_pattern <artefact_type>
# Retourne: pattern sur stdout, 0 si succès, 1 si erreur
get_artefact_pattern() {
    local artefact_type="$1"
    
    if [ -z "$artefact_type" ]; then
        return 1
    fi
    
    get_artefact_pattern_internal "$artefact_type"
}

# Fonction utilitaire pour nettoyer une structure extraite
# Usage: clean_extracted_structure <structure>
# Retourne: structure nettoyée sur stdout
clean_extracted_structure() {
    local structure="$1"
    
    if [ -z "$structure" ]; then
        return 1
    fi
    
    # 1. Supprime la première ligne (le `###...`)
    # 2. Supprime la dernière ligne (le `## SECTION 3...`) (compatible macOS)
    # 3. Sur ce qui reste, extrait le contenu entre ```markdown et ```
    echo "$structure" | tail -n +2 | sed '$d' | sed -n '/```markdown/,/```/p' | sed '1d;$d'
}

# Extraire la structure d'artefact depuis un protocole
# Usage: extract_artefact_structure <protocol_file> <artefact_type>
# Retourne: structure extraite sur stdout, 0 si succès, 1 si erreur
extract_artefact_structure() {
    local protocol_file="$1"
    local artefact_type="$2"

    if [ -z "$protocol_file" ] || [ ! -f "$protocol_file" ] || [ -z "$artefact_type" ]; then
        return 1
    fi

    local start_pattern
    if ! start_pattern=$(get_artefact_pattern "$artefact_type"); then
        return 1
    fi

    local end_pattern="^## SECTION 3"
    
    # Extraire la section entre les patterns
    local structure
    structure=$(sed -n "/$start_pattern/,/$end_pattern/p" "$protocol_file")
    
    # Si aucune section trouvée, retourner erreur
    if [ -z "$structure" ]; then
        return 1
    fi
    
    # Nettoyer la structure extraite
    clean_extracted_structure "$structure"
}

# Fonction de validation avant mise en cache
# Usage: validate_cache_prerequisites <protocol_file> <artefact_type> <cache_file>
# Retourne: 0 si valide, 1 si invalide
validate_cache_prerequisites() {
    local protocol_file="$1"
    local artefact_type="$2"
    local cache_file="$3"
    
    # Validation des paramètres d'entrée
    if [ -z "$protocol_file" ] || [ -z "$artefact_type" ] || [ -z "$cache_file" ]; then
        return 1
    fi
    
    # Vérifier l'existence du fichier protocole
    if [ ! -f "$protocol_file" ]; then
        return 1
    fi
    
    # Vérifier que le type d'artefact est supporté
    if ! is_valid_artefact_type "$artefact_type"; then
        return 1
    fi
    
    # Vérifier que le répertoire parent du cache existe ou peut être créé
    local cache_dir
    cache_dir=$(dirname "$cache_file")
    if [ ! -d "$cache_dir" ]; then
        if ! mkdir -p "$cache_dir" 2>/dev/null; then
            return 1
        fi
    fi
    
    return 0
}

# Fonction principale : extraire et mettre en cache la structure d'un protocole
# Usage: extract_and_cache_structure <protocol_file> <artefact_type> <cache_file>
# Retourne: structure extraite sur stdout, 0 si succès, 1 si erreur
extract_and_cache_structure() {
    local protocol_file="$1"
    local artefact_type="$2"
    local cache_file="$3"
    
    # Validation préalable
    if ! validate_cache_prerequisites "$protocol_file" "$artefact_type" "$cache_file"; then
        return 1
    fi
    
    # Extraire la structure depuis le protocole
    local structure
    if ! structure=$(extract_artefact_structure "$protocol_file" "$artefact_type"); then
        return 1
    fi
    
    # Vérifier que la structure n'est pas vide
    if [ -z "$structure" ]; then
        return 1
    fi
    
    # Obtenir le timestamp du fichier protocole
    local protocol_mtime
    if ! protocol_mtime=$(get_file_mtime "$protocol_file"); then
        return 1
    fi
    
    # Initialiser le répertoire cache
    if ! init_cache_dir; then
        return 1
    fi
    
    # Écriture atomique : utiliser des fichiers temporaires
    local temp_cache_file="${cache_file}.tmp.$$"
    local temp_mtime_file="${cache_file}.mtime.tmp.$$"
    
    # Piège pour nettoyer en cas d'interruption
    trap 'rm -f "$temp_cache_file" "$temp_mtime_file" 2>/dev/null' EXIT
    
    # Écrire la structure dans le fichier temporaire
    if ! echo "$structure" > "$temp_cache_file"; then
        return 1
    fi
    
    # Écrire le timestamp dans le fichier temporaire
    if ! echo "$protocol_mtime" > "$temp_mtime_file"; then
        return 1
    fi
    
    # Déplacer atomiquement les fichiers temporaires vers les fichiers finaux
    if ! mv "$temp_cache_file" "$cache_file"; then
        return 1
    fi
    
    if ! mv "$temp_mtime_file" "${cache_file}.mtime"; then
        # Le fichier cache est déjà créé, on continue
        rm -f "$temp_mtime_file" 2>/dev/null
    fi
    
    # Désactiver le piège de nettoyage
    trap - EXIT
    
    # Retourner la structure extraite
    echo "$structure"
    return 0
}