#!/usr/bin/env bash
#==============================================================================
# Amélioration UX : Mode Quick Start pour Aklo
# Guide interactif pour débutants
#==============================================================================

# Configuration des couleurs et styles
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

# Fonction de bannière d'accueil
show_quickstart_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════════════════════╗
    ║              🚀 AKLO QUICK START                     ║
    ║         Guide interactif pour débutants              ║
    ║                                                      ║
    ║   Apprenez Aklo étape par étape en 10-15 minutes    ║
    ╚══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Fonction de progression
show_progress() {
    local step=$1
    local total=$2
    local description="$3"
    
    echo -e "\n${BLUE}┌─ Étape $step/$total ─────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC} ${BOLD}$description${NC}"
    echo -e "${BLUE}└──────────────────────────────────────────────────────────┘${NC}\n"
}

# Fonction de pause interactive
wait_for_user() {
    local message="${1:-Appuyez sur Entrée pour continuer...}"
    echo -e "\n${YELLOW}$message${NC}"
    read -r
}

# Étape 1: Introduction au protocole Aklo
introduce_aklo() {
    show_progress 1 7 "Introduction au Protocole Aklo"
    
    cat << 'EOF'
🤖 Qu'est-ce qu'Aklo ?

Aklo est un protocole de développement qui structure votre workflow :

📋 PBI (Product Backlog Items)
   → Les fonctionnalités à développer

🔧 Tâches 
   → Décomposition technique des PBI

🌿 Git Workflow
   → Branches et commits structurés

📚 Charte IA
   → 22 protocoles qui guident chaque étape

L'objectif : Transformer le chaos en processus maîtrisé !
EOF
    
    wait_for_user
}

# Étape 2: Vérification de l'environnement
check_environment() {
    show_progress 2 7 "Vérification de l'environnement"
    
    echo "🔍 Vérification des prérequis..."
    
    # Vérifier Git
    if command -v git >/dev/null 2>&1; then
        echo -e "✅ Git: $(git --version | cut -d' ' -f3)"
    else
        echo -e "❌ Git non installé"
        echo "💡 Installez Git avant de continuer"
        exit 1
    fi
    
    # Vérifier si on est dans un projet
    local project_name=$(basename "$(pwd)")
    echo -e "📁 Projet actuel: ${BOLD}$project_name${NC}"
    
    # Vérifier si Aklo est déjà configuré
    if [ -f ".aklo.conf" ]; then
        echo -e "⚠️  Aklo déjà configuré dans ce projet"
        echo "Voulez-vous continuer quand même ? (y/N)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Configuration annulée."
            exit 0
        fi
    else
        echo -e "🆕 Nouveau projet Aklo"
    fi
    
    wait_for_user
}

# Étape 3: Configuration du projet
configure_project() {
    show_progress 3 7 "Configuration du projet"
    
    echo "🔧 Configuration d'Aklo pour votre projet..."
    
    # Demander le workdir
    echo -e "\n${YELLOW}Où souhaitez-vous créer les artefacts Aklo ?${NC}"
    echo "1) docs/ (recommandé)"
    echo "2) aklo/"
    echo "3) Personnalisé"
    echo -n "Votre choix (1-3) [1]: "
    read -r workdir_choice
    
    local workdir
    case "$workdir_choice" in
        2) workdir="aklo" ;;
        3) 
            echo -n "Chemin personnalisé: "
            read -r workdir
            ;;
        *) workdir="docs" ;;
    esac
    
    echo -e "📂 Répertoire de travail: ${BOLD}$workdir${NC}"
    
    # Exécuter aklo init (simulé ici)
    echo "🚀 Initialisation d'Aklo..."
    
    # Créer la structure de base
    mkdir -p "$workdir/backlog/00-pbi"
    mkdir -p "$workdir/backlog/01-tasks"
    
    # Créer le fichier de configuration
    cat > .aklo.conf << EOF
# Configuration Aklo
PROJECT_WORKDIR=$workdir
PROJECT_NAME=$(basename "$(pwd)")
CREATED_DATE=$(date +%Y-%m-%d)
EOF
    
    echo -e "✅ Projet Aklo configuré !"
    
    wait_for_user
}

# Étape 4: Création du premier PBI
create_first_pbi() {
    show_progress 4 7 "Création de votre premier PBI"
    
    cat << 'EOF'
📋 Créons votre premier Product Backlog Item (PBI)

Un PBI décrit une fonctionnalité du point de vue utilisateur.

Exemples de bons PBI :
• "Authentification utilisateur"
• "Système de commentaires"  
• "Export PDF des rapports"
• "API de gestion des produits"
EOF
    
    echo -e "\n${YELLOW}Quel est le titre de votre premier PBI ?${NC}"
    echo -n "Titre: "
    read -r pbi_title
    
    if [ -z "$pbi_title" ]; then
        pbi_title="Ma première fonctionnalité"
        echo -e "Utilisation du titre par défaut: ${BOLD}$pbi_title${NC}"
    fi
    
    # Créer le PBI
    local workdir=$(grep "PROJECT_WORKDIR=" .aklo.conf | cut -d'=' -f2)
    local pbi_file="$workdir/backlog/00-pbi/PBI-1-$(echo "$pbi_title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]').xml"
    
    cat > "$pbi_file" << EOF
# $pbi_title

**Status:** PROPOSED  
**Priority:** MEDIUM  
**Created:** $(date +%Y-%m-%d)

## Description

Décrivez ici la fonctionnalité souhaitée du point de vue utilisateur.

## Critères d'acceptation

- [ ] Critère 1
- [ ] Critère 2  
- [ ] Critère 3

## Notes techniques

Ajoutez ici les considérations techniques importantes.

## Définition de "Terminé"

- [ ] Code développé et testé
- [ ] Documentation mise à jour
- [ ] Tests automatisés ajoutés
- [ ] Review de code effectuée
EOF
    
    echo -e "✅ PBI créé: ${BOLD}$(basename "$pbi_file")${NC}"
    echo -e "📄 Fichier: $pbi_file"
    
    wait_for_user
}

# Étape 5: Planification des tâches
plan_first_tasks() {
    show_progress 5 7 "Planification des tâches"
    
    cat << 'EOF'
🔧 Décomposons votre PBI en tâches techniques

Les tâches sont les étapes concrètes pour réaliser le PBI.

Exemples pour "Authentification utilisateur" :
• Créer le modèle User
• Implémenter l'endpoint /login
• Ajouter le middleware d'authentification
• Créer la page de connexion
• Écrire les tests
EOF
    
    echo -e "\n${YELLOW}Combien de tâches voulez-vous créer ? (1-5) [3]:${NC}"
    read -r task_count
    
    if [[ ! "$task_count" =~ ^[1-5]$ ]]; then
        task_count=3
    fi
    
    local workdir=$(grep "PROJECT_WORKDIR=" .aklo.conf | cut -d'=' -f2)
    
    for i in $(seq 1 "$task_count"); do
        echo -e "\n${CYAN}Tâche $i/$task_count${NC}"
        echo -n "Titre de la tâche: "
        read -r task_title
        
        if [ -z "$task_title" ]; then
            task_title="Tâche $i"
        fi
        
        # Créer le fichier de tâche
        local task_file="$workdir/backlog/01-tasks/TASK-$i-1-$(echo "$task_title" | tr ' ' '-' | tr '[:upper:]' '[:lower:]').xml"
        
        cat > "$task_file" << EOF
# $task_title

**PBI:** 1  
**Status:** TODO  
**Estimate:** 2h  
**Created:** $(date +%Y-%m-%d)

## Description

Description technique de la tâche.

## Checklist

- [ ] Analyser les exigences
- [ ] Implémenter la solution
- [ ] Écrire les tests
- [ ] Tester manuellement
- [ ] Mettre à jour la documentation

## Notes

Notes techniques et considérations importantes.
EOF
        
        echo -e "✅ Tâche créée: ${BOLD}$(basename "$task_file")${NC}"
    done
    
    wait_for_user
}

# Étape 6: Workflow Git
demonstrate_git_workflow() {
    show_progress 6 7 "Workflow Git avec Aklo"
    
    cat << 'EOF'
🌿 Workflow Git structuré

Aklo organise votre travail Git :

1. 📋 Branche main/master
   → Code stable et testé

2. 🔧 Branches de tâches  
   → task/1-nom-de-la-tache

3. 🚀 Branches de feature
   → feature/pbi-1-nom-du-pbi

4. 🔥 Branches de hotfix
   → hotfix/description-du-fix

Chaque tâche = une branche = une PR/MR
EOF
    
    echo -e "\n${YELLOW}Voulez-vous initialiser Git dans ce projet ? (y/N):${NC}"
    read -r git_init
    
    if [[ "$git_init" =~ ^[Yy]$ ]]; then
        if [ ! -d ".git" ]; then
            git init
            echo -e "✅ Dépôt Git initialisé"
            
            # Premier commit
            git add .
            git commit -m "🚀 Initial Aklo setup

- Configuration Aklo
- Premier PBI créé
- Tâches planifiées

Generated by: aklo quickstart"
            
            echo -e "✅ Premier commit créé"
        else
            echo -e "ℹ️  Git déjà initialisé"
        fi
    fi
    
    wait_for_user
}

# Étape 7: Prochaines étapes
show_next_steps() {
    show_progress 7 7 "Prochaines étapes"
    
    cat << 'EOF'
🎉 Félicitations ! Votre projet Aklo est configuré !

🔧 Commandes essentielles à retenir :

   aklo status                    # État du projet
   aklo start-task 1              # Commencer la tâche #1
   aklo submit-task               # Soumettre pour review
   aklo propose-pbi "Titre"       # Créer un nouveau PBI
   aklo plan 2                    # Planifier le PBI #2

📚 Pour approfondir :

   aklo --help                    # Aide complète
   aklo <command> --help          # Aide spécifique
   charte/PROTOCOLES/             # Documentation détaillée

🚀 Workflow recommandé :

   1. aklo start-task 1           # Commencer
   2. [Développer la fonctionnalité]
   3. aklo submit-task            # Soumettre
   4. [Review et validation]
   5. aklo merge-task 1           # Merger
   6. Répéter avec la tâche suivante !
EOF
    
    # Afficher le statut final
    echo -e "\n${CYAN}📊 État final de votre projet :${NC}"
    
    local workdir=$(grep "PROJECT_WORKDIR=" .aklo.conf | cut -d'=' -f2)
    local pbi_count=$(find "$workdir/backlog/00-pbi" -name "PBI-*.xml" 2>/dev/null | wc -l | tr -d ' ')
    local task_count=$(find "$workdir/backlog/01-tasks" -name "TASK-*.xml" 2>/dev/null | wc -l | tr -d ' ')
    
    echo -e "📋 PBI créés: $pbi_count"
    echo -e "🔧 Tâches planifiées: $task_count"
    echo -e "🌿 Git: $(if [ -d ".git" ]; then echo "✅ Initialisé"; else echo "❌ Non initialisé"; fi)"
    echo -e "📁 Workdir: $workdir"
    
    wait_for_user "Appuyez sur Entrée pour terminer le Quick Start..."
}

# Fonction principale du quickstart
aklo_quickstart() {
    local skip_tutorial=false
    local template=""
    
    # Parser les options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-tutorial)
                skip_tutorial=true
                shift
                ;;
            --template)
                template="$2"
                shift 2
                ;;
            --help|-h)
                show_quickstart_help
                return 0
                ;;
            *)
                echo "Option inconnue: $1"
                return 1
                ;;
        esac
    done
    
    # Bannière d'accueil
    show_quickstart_banner
    
    if [ "$skip_tutorial" = true ]; then
        echo -e "${YELLOW}Mode rapide activé - tutorial ignoré${NC}"
        configure_project
        create_first_pbi
        plan_first_tasks
        demonstrate_git_workflow
    else
        # Workflow complet
        introduce_aklo
        check_environment
        configure_project
        create_first_pbi
        plan_first_tasks
        demonstrate_git_workflow
        show_next_steps
    fi
    
    echo -e "\n${GREEN}🎉 Quick Start terminé ! Bon développement avec Aklo !${NC}"
}

# Aide pour quickstart
show_quickstart_help() {
    cat << 'EOF'
🚀 aklo quickstart - Mode guidé pour débutants

USAGE:
    aklo quickstart
    aklo quickstart --template <type>
    aklo quickstart --skip-tutorial

DESCRIPTION:
    Guide interactif pour découvrir et configurer Aklo.
    Parfait pour les nouveaux utilisateurs.

OPTIONS:
    --template <type>     Utilise un template prédéfini
    --skip-tutorial      Ignore le tutorial et va à l'essentiel
    --help, -h          Affiche cette aide

TEMPLATES:
    webapp      Application web complète
    api         API REST
    library     Bibliothèque/package
    mobile      Application mobile
    desktop     Application desktop

DURÉE:
    • Mode complet : 10-15 minutes
    • Avec --skip-tutorial : 3-5 minutes

Ce mode vous guide pour :
• Comprendre les concepts Aklo
• Configurer votre premier projet
• Créer votre premier PBI
• Planifier vos premières tâches
• Initialiser Git avec Aklo
EOF
}

# Point d'entrée si exécuté directement
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    aklo_quickstart "$@"
fi