#!/bin/bash
#==============================================================================
# Amélioration UX : Système d'aide avancé pour Aklo
# Support de --help et <command> --help
#==============================================================================

# Fonction d'aide générale améliorée
show_help() {
    cat << 'EOF'
🤖 The Aklo Protocol - Charte Automation Tool (v2.0)

USAGE:
    aklo <command> [arguments]
    aklo <command> --help        # Aide spécifique à une commande
    aklo --help                  # Cette aide

WORKFLOW PRINCIPAL:
    1. aklo init                 # Initialiser le projet
    2. aklo propose-pbi "titre"  # Créer un PBI
    3. aklo plan <PBI_ID>        # Planifier les tâches
    4. aklo start-task <TASK_ID> # Commencer une tâche
    5. aklo submit-task          # Soumettre pour review
    6. aklo merge-task <TASK_ID> # Merger après validation

COMMANDES PRINCIPALES:
    init                    Lie la Charte Aklo au projet actuel
    propose-pbi <title>     Crée un nouveau Product Backlog Item
    plan <PBI_ID>          Planifie interactivement les tâches d'un PBI
    start-task <TASK_ID>   Prépare l'environnement pour travailler sur une tâche
    submit-task            Commit et soumet la tâche courante pour review
    merge-task <TASK_ID>   Merge une tâche validée dans la branche principale
    
COMMANDES DE RELEASE:
    release <type>         Démarre le processus de release (major|minor|patch)
    hotfix <description>   Démarre un hotfix depuis la production
    hotfix publish         Publie un hotfix terminé

COMMANDES UTILITAIRES:
    status                 Affiche l'état complet du projet
    new <type> [args...]   Crée un nouvel artefact de support
    quickstart             Mode guidé pour débutants
    validate               Valide la configuration du projet

COMMANDES D'AIDE:
    help                   Affiche cette aide
    --help                 Alias pour help
    <command> --help       Aide spécifique à une commande

EXEMPLES:
    aklo init                              # Initialiser un nouveau projet
    aklo propose-pbi "Authentification"   # Créer un PBI
    aklo plan 1                           # Planifier le PBI #1
    aklo start-task 1                     # Commencer la tâche #1
    aklo status                           # Voir l'état du projet
    aklo propose-pbi --help               # Aide pour propose-pbi

CONFIGURATION:
    Le fichier .aklo.conf contient la configuration du projet.
    Les protocoles sont dans le répertoire charte/.

DOCUMENTATION:
    Voir les protocoles dans charte/PROTOCOLES/ pour plus de détails.
    
Pour une aide spécifique : aklo <command> --help
EOF
}

# Aide spécifique pour propose-pbi
show_help_propose_pbi() {
    cat << 'EOF'
📋 aklo propose-pbi - Créer un Product Backlog Item

USAGE:
    aklo propose-pbi <title>
    aklo propose-pbi --interactive
    aklo propose-pbi --template <type>

DESCRIPTION:
    Crée un nouveau PBI selon le protocole 01-PLANIFICATION.
    Le PBI est créé avec un ID auto-incrémenté et suit le template standard.

ARGUMENTS:
    <title>                Titre du PBI (obligatoire si pas --interactive)

OPTIONS:
    --interactive, -i      Mode interactif avec questions guidées
    --template <type>      Utilise un template prédéfini (feature|bug|epic)
    --priority <level>     Définit la priorité (high|medium|low)
    --help, -h            Affiche cette aide

EXEMPLES:
    aklo propose-pbi "Authentification utilisateur"
    aklo propose-pbi --interactive
    aklo propose-pbi --template feature "API REST"
    aklo propose-pbi --priority high "Bug critique"

TEMPLATES DISPONIBLES:
    feature     Template pour nouvelle fonctionnalité
    bug         Template pour correction de bug
    epic        Template pour epic (grande fonctionnalité)
    research    Template pour recherche/investigation

WORKFLOW:
    1. Crée le fichier PBI-<ID>-<TITLE>.md
    2. Remplit avec le template approprié
    3. Ouvre l'éditeur pour finalisation
    4. Commit automatique si configuré

FICHIERS CRÉÉS:
    docs/backlog/00-pbi/PBI-<ID>-<TITLE>.md

Voir aussi: aklo plan --help, aklo status
EOF
}

# Export des fonctions pour utilisation dans le script principal
EOF