#!/bin/bash
#==============================================================================
# Amélioration UX : Validation des inputs utilisateur pour Aklo
# Validation robuste et messages d'erreur utiles
#==============================================================================

# Configuration des couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fonction de validation générique
validate_input() {
    local input="$1"
    local type="$2"
    local context="$3"
    
    case "$type" in
        "pbi_title")
            validate_pbi_title "$input"
            ;;
        "pbi_id")
            validate_pbi_id "$input"
            ;;
        "task_id")
            validate_task_id "$input"
            ;;
        "task_title")
            validate_task_title "$input"
            ;;
        "release_type")
            validate_release_type "$input"
            ;;
        "priority")
            validate_priority "$input"
            ;;
        "branch_name")
            validate_branch_name "$input"
            ;;
        "commit_message")
            validate_commit_message "$input"
            ;;
        *)
            echo -e "${RED}❌ Type de validation inconnu: $type${NC}"
            return 1
            ;;
    esac
}

# Validation du titre de PBI
validate_pbi_title() {
    local title="$1"
    local errors=()
    
    # Vérifier que le titre n'est pas vide
    if [ -z "$title" ]; then
        errors+=("Le titre ne peut pas être vide")
    fi
    
    # Vérifier la longueur minimale
    if [ ${#title} -lt 5 ]; then
        errors+=("Le titre doit contenir au moins 5 caractères")
    fi
    
    # Vérifier la longueur maximale
    if [ ${#title} -gt 100 ]; then
        errors+=("Le titre ne peut pas dépasser 100 caractères (actuellement: ${#title})")
    fi
    
    # Vérifier les caractères interdits pour les noms de fichiers
    if [[ "$title" =~ [/\\:*?\"<>|] ]]; then
        errors+=("Le titre contient des caractères interdits: / \\ : * ? \" < > |")
    fi
    
    # Vérifier qu'il ne commence/finit pas par des espaces
    if [[ "$title" =~ ^[[:space:]] ]] || [[ "$title" =~ [[:space:]]$ ]]; then
        errors+=("Le titre ne peut pas commencer ou finir par des espaces")
    fi
    
    # Suggestions pour améliorer le titre
    local suggestions=()
    
    if [[ ! "$title" =~ [A-Z] ]]; then
        suggestions+=("💡 Conseil: Commencez par une majuscule")
    fi
    
    if [[ "$title" =~ ^(TODO|FIXME|WIP) ]]; then
        suggestions+=("💡 Conseil: Évitez les préfixes comme TODO, FIXME, WIP")
    fi
    
    if [ ${#title} -lt 15 ]; then
        suggestions+=("💡 Conseil: Un titre plus descriptif serait plus clair")
    fi
    
    # Afficher les résultats
    if [ ${#errors[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ Titre valide${NC}"
        
        # Afficher les suggestions s'il y en a
        for suggestion in "${suggestions[@]}"; do
            echo -e "${YELLOW}$suggestion${NC}"
        done
        
        return 0
    else
        echo -e "${RED}❌ Titre invalide:${NC}"
        for error in "${errors[@]}"; do
            echo -e "${RED}   • $error${NC}"
        done
        
        echo -e "\n${BLUE}📝 Exemples de bons titres:${NC}"
        echo "   • Authentification utilisateur"
        echo "   • API de gestion des produits"
        echo "   • Interface de recherche avancée"
        echo "   • Système de notifications en temps réel"
        
        return 1
    fi
}

# Validation de l'ID de PBI
validate_pbi_id() {
    local pbi_id="$1"
    local errors=()
    
    # Vérifier que l'ID n'est pas vide
    if [ -z "$pbi_id" ]; then
        errors+=("L'ID PBI ne peut pas être vide")
    fi
    
    # Vérifier que c'est un nombre
    if ! [[ "$pbi_id" =~ ^[0-9]+$ ]]; then
        errors+=("L'ID PBI doit être un nombre entier positif")
    fi
    
    # Vérifier que l'ID est dans une plage raisonnable
    if [ "$pbi_id" -lt 1 ] || [ "$pbi_id" -gt 9999 ]; then
        errors+=("L'ID PBI doit être entre 1 et 9999")
    fi
    
    # Vérifier que le PBI existe
    local workdir=$(get_project_workdir)
    if [ -n "$workdir" ] && [ ! -f "$workdir/backlog/00-pbi/PBI-$pbi_id-"*.xml ]; then
        errors+=("Le PBI #$pbi_id n'existe pas")
        
        # Suggérer les PBI existants
        local existing_pbis=$(find "$workdir/backlog/00-pbi" -name "PBI-*.xml" 2>/dev/null | \
            sed 's/.*PBI-\([0-9]*\)-.*/\1/' | sort -n | tr '\n' ' ')
        
        if [ -n "$existing_pbis" ]; then
            echo -e "${BLUE}📋 PBI existants: $existing_pbis${NC}"
        else
            echo -e "${BLUE}💡 Aucun PBI créé. Utilisez: aklo propose-pbi \"Titre\"${NC}"
        fi
    fi
    
    # Afficher les résultats
    if [ ${#errors[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ ID PBI valide${NC}"
        return 0
    else
        echo -e "${RED}❌ ID PBI invalide:${NC}"
        for error in "${errors[@]}"; do
            echo -e "${RED}   • $error${NC}"
        done
        return 1
    fi
}

# Validation de l'ID de tâche
validate_task_id() {
    local task_id="$1"
    local errors=()
    
    # Vérifier que l'ID n'est pas vide
    if [ -z "$task_id" ]; then
        errors+=("L'ID de tâche ne peut pas être vide")
    fi
    
    # Vérifier que c'est un nombre
    if ! [[ "$task_id" =~ ^[0-9]+$ ]]; then
        errors+=("L'ID de tâche doit être un nombre entier positif")
    fi
    
    # Vérifier que l'ID est dans une plage raisonnable
    if [ "$task_id" -lt 1 ] || [ "$task_id" -gt 9999 ]; then
        errors+=("L'ID de tâche doit être entre 1 et 9999")
    fi
    
    # Vérifier que la tâche existe
    local workdir=$(get_project_workdir)
    if [ -n "$workdir" ] && [ ! -f "$workdir/backlog/01-tasks/TASK-$task_id-"*.xml ]; then
        errors+=("La tâche #$task_id n'existe pas")
        
        # Suggérer les tâches existantes
        local existing_tasks=$(find "$workdir/backlog/01-tasks" -name "TASK-*.xml" 2>/dev/null | \
            sed 's/.*TASK-\([0-9]*\)-.*/\1/' | sort -n | tr '\n' ' ')
        
        if [ -n "$existing_tasks" ]; then
            echo -e "${BLUE}🔧 Tâches existantes: $existing_tasks${NC}"
        else
            echo -e "${BLUE}💡 Aucune tâche créée. Utilisez: aklo plan <PBI_ID>${NC}"
        fi
    fi
    
    # Afficher les résultats
    if [ ${#errors[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ ID de tâche valide${NC}"
        return 0
    else
        echo -e "${RED}❌ ID de tâche invalide:${NC}"
        for error in "${errors[@]}"; do
            echo -e "${RED}   • $error${NC}"
        done
        return 1
    fi
}

# Validation du type de release
validate_release_type() {
    local release_type="$1"
    local valid_types=("major" "minor" "patch")
    
    if [ -z "$release_type" ]; then
        echo -e "${RED}❌ Type de release requis${NC}"
        echo -e "${BLUE}📝 Types valides: ${valid_types[*]}${NC}"
        return 1
    fi
    
    # Vérifier si le type est valide
    local is_valid=false
    for valid_type in "${valid_types[@]}"; do
        if [ "$release_type" = "$valid_type" ]; then
            is_valid=true
            break
        fi
    done
    
    if [ "$is_valid" = false ]; then
        echo -e "${RED}❌ Type de release invalide: $release_type${NC}"
        echo -e "${BLUE}📝 Types valides: ${valid_types[*]}${NC}"
        echo -e "\n${BLUE}📖 Explications:${NC}"
        echo "   • major: Changements incompatibles (v1.0.0 → v2.0.0)"
        echo "   • minor: Nouvelles fonctionnalités (v1.0.0 → v1.1.0)"
        echo "   • patch: Corrections de bugs (v1.0.0 → v1.0.1)"
        return 1
    fi
    
    echo -e "${GREEN}✅ Type de release valide${NC}"
    return 0
}

# Validation de la priorité
validate_priority() {
    local priority="$1"
    local valid_priorities=("LOW" "MEDIUM" "HIGH" "CRITICAL")
    
    if [ -z "$priority" ]; then
        echo -e "${YELLOW}⚠️  Priorité non spécifiée, utilisation de MEDIUM par défaut${NC}"
        return 0
    fi
    
    # Convertir en majuscules
    priority=$(echo "$priority" | tr '[:lower:]' '[:upper:]')
    
    # Vérifier si la priorité est valide
    local is_valid=false
    for valid_priority in "${valid_priorities[@]}"; do
        if [ "$priority" = "$valid_priority" ]; then
            is_valid=true
            break
        fi
    done
    
    if [ "$is_valid" = false ]; then
        echo -e "${RED}❌ Priorité invalide: $priority${NC}"
        echo -e "${BLUE}📝 Priorités valides: ${valid_priorities[*]}${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Priorité valide: $priority${NC}"
    return 0
}

# Validation du nom de branche
validate_branch_name() {
    local branch_name="$1"
    local errors=()
    
    if [ -z "$branch_name" ]; then
        errors+=("Le nom de branche ne peut pas être vide")
    fi
    
    # Vérifier les caractères interdits
    if [[ "$branch_name" =~ [[:space:]~^:?*\[\]\\] ]]; then
        errors+=("Le nom de branche contient des caractères interdits")
    fi
    
    # Vérifier qu'elle ne commence/finit pas par un point ou slash
    if [[ "$branch_name" =~ ^[./] ]] || [[ "$branch_name" =~ [./]$ ]]; then
        errors+=("Le nom de branche ne peut pas commencer/finir par . ou /")
    fi
    
    # Vérifier la longueur
    if [ ${#branch_name} -gt 100 ]; then
        errors+=("Le nom de branche est trop long (max 100 caractères)")
    fi
    
    # Vérifier que la branche n'existe pas déjà
    if git show-ref --verify --quiet "refs/heads/$branch_name" 2>/dev/null; then
        errors+=("La branche '$branch_name' existe déjà")
    fi
    
    # Afficher les résultats
    if [ ${#errors[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ Nom de branche valide${NC}"
        return 0
    else
        echo -e "${RED}❌ Nom de branche invalide:${NC}"
        for error in "${errors[@]}"; do
            echo -e "${RED}   • $error${NC}"
        done
        
        echo -e "\n${BLUE}📝 Exemples de bons noms:${NC}"
        echo "   • task/1-authentication"
        echo "   • feature/user-dashboard"
        echo "   • bugfix/login-validation"
        
        return 1
    fi
}

# Validation du message de commit
validate_commit_message() {
    local message="$1"
    local errors=()
    local warnings=()
    
    if [ -z "$message" ]; then
        errors+=("Le message de commit ne peut pas être vide")
    fi
    
    # Vérifier la longueur de la première ligne
    local first_line=$(echo "$message" | head -1)
    if [ ${#first_line} -gt 72 ]; then
        warnings+=("La première ligne est longue (${#first_line} chars, recommandé: ≤50)")
    fi
    
    if [ ${#first_line} -lt 10 ]; then
        warnings+=("La première ligne est courte (${#first_line} chars, recommandé: ≥10)")
    fi
    
    # Vérifier le format conventionnel (optionnel)
    if [[ ! "$first_line" =~ ^(feat|fix|docs|style|refactor|test|chore|perf)(\(.+\))?: ]]; then
        warnings+=("Le message ne suit pas le format conventionnel (feat:, fix:, etc.)")
    fi
    
    # Vérifier qu'il ne finit pas par un point
    if [[ "$first_line" =~ \.$ ]]; then
        warnings+=("La première ligne ne devrait pas finir par un point")
    fi
    
    # Afficher les résultats
    if [ ${#errors[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ Message de commit valide${NC}"
        
        # Afficher les warnings
        for warning in "${warnings[@]}"; do
            echo -e "${YELLOW}⚠️  $warning${NC}"
        done
        
        return 0
    else
        echo -e "${RED}❌ Message de commit invalide:${NC}"
        for error in "${errors[@]}"; do
            echo -e "${RED}   • $error${NC}"
        done
        
        echo -e "\n${BLUE}📝 Exemples de bons messages:${NC}"
        echo "   • feat: add user authentication"
        echo "   • fix: resolve login validation bug"
        echo "   • docs: update API documentation"
        echo "   • refactor: improve error handling"
        
        return 1
    fi
}

# Fonction utilitaire pour récupérer le workdir du projet
get_project_workdir() {
    if [ -f ".aklo.conf" ]; then
        grep "PROJECT_WORKDIR=" .aklo.conf | cut -d'=' -f2
    else
        echo ""
    fi
}

# Fonction de validation interactive
interactive_validation() {
    local input_type="$1"
    local prompt="$2"
    local max_attempts="${3:-3}"
    
    local attempts=0
    local input=""
    
    while [ $attempts -lt $max_attempts ]; do
        echo -e "\n${BLUE}$prompt${NC}"
        read -r input
        
        if validate_input "$input" "$input_type"; then
            echo "$input"
            return 0
        fi
        
        attempts=$((attempts + 1))
        if [ $attempts -lt $max_attempts ]; then
            echo -e "\n${YELLOW}Tentative $attempts/$max_attempts. Essayez à nouveau:${NC}"
        fi
    done
    
    echo -e "\n${RED}❌ Nombre maximum de tentatives atteint${NC}"
    return 1
}

# Fonction de validation en lot
batch_validation() {
    local validation_file="$1"
    local errors=0
    
    if [ ! -f "$validation_file" ]; then
        echo -e "${RED}❌ Fichier de validation non trouvé: $validation_file${NC}"
        return 1
    fi
    
    echo -e "${BLUE}🔍 Validation en lot depuis: $validation_file${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    while IFS='|' read -r type value description; do
        # Ignorer les lignes vides et commentaires
        [[ -z "$type" || "$type" =~ ^#.*$ ]] && continue
        
        echo -e "\n📋 $description"
        if validate_input "$value" "$type"; then
            echo -e "${GREEN}   ✅ Valide${NC}"
        else
            echo -e "${RED}   ❌ Invalide${NC}"
            errors=$((errors + 1))
        fi
    done < "$validation_file"
    
    echo -e "\n$(printf '%.0s─' {1..50})"
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}🎉 Toutes les validations ont réussi !${NC}"
        return 0
    else
        echo -e "${RED}❌ $errors erreur(s) de validation${NC}"
        return 1
    fi
}

# Fonction principale pour les tests
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    echo "🧪 Tests de validation Aklo"
    echo "=========================="
    
    # Tests de titre PBI
    echo -e "\n📋 Test validation titre PBI:"
    validate_input "Authentification utilisateur" "pbi_title"
    validate_input "A" "pbi_title"  # Trop court
    validate_input "" "pbi_title"   # Vide
    
    # Tests d'ID
    echo -e "\n🔢 Test validation ID:"
    validate_input "1" "pbi_id"
    validate_input "abc" "pbi_id"   # Non numérique
    validate_input "0" "pbi_id"     # Invalide
    
    # Tests de type de release
    echo -e "\n🚀 Test validation release:"
    validate_input "major" "release_type"
    validate_input "invalid" "release_type"
fi