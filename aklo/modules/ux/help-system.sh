#!/usr/bin/env bash
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
    1. Crée le fichier PBI-<ID>-<TITLE>.xml
    2. Remplit avec le template approprié
    3. Ouvre l'éditeur pour finalisation
    4. Commit automatique si configuré

FICHIERS CRÉÉS:
    docs/backlog/00-pbi/PBI-<ID>-<TITLE>.xml

Voir aussi: aklo plan --help, aklo status
EOF
}

# Export des fonctions pour utilisation dans le script principal

# Fonction cmd_help pour la commande 'help'
cmd_help() {
    local subcommand="$1"
    
    case "$subcommand" in
        "propose-pbi"|"pbi")
            show_help_propose_pbi
            ;;
        "new")
            show_help_new
            ;;
        "plan")
            show_help_plan
            ;;
        "start-task")
            show_help_start_task
            ;;
        "submit-task")
            show_help_submit_task
            ;;
        "merge-task")
            show_help_merge_task
            ;;
        "release")
            show_help_release
            ;;
        "hotfix")
            show_help_hotfix
            ;;
        "status")
            show_help_status
            ;;
        "init")
            show_help_init
            ;;
        "")
            show_help
            ;;
        *)
            echo "Aide non disponible pour la commande: $subcommand"
            echo "Utilisez 'aklo help' pour voir toutes les commandes disponibles."
            return 1
            ;;
    esac
}

# Fonctions d'aide pour les autres commandes (à compléter selon les besoins)
show_help_new() {
    cat << 'EOF'
🆕 aklo new - Créer un nouvel artefact de support

USAGE:
    aklo new <type> [arguments...]

DESCRIPTION:
    Crée un nouvel artefact de support selon le type spécifié.
    Chaque type suit un template spécifique et des conventions.

TYPES DISPONIBLES:
    pbi         Product Backlog Item (alias: propose-pbi)
    task        Tâche de développement
    arch        Document d'architecture
    debug       Rapport de debug
    review      Demande de review
    journal     Entrée de journal
    kb          Article de base de connaissances
    meta        Amélioration du système Aklo
    experiment  Expérimentation
    security    Audit de sécurité
    docs        Documentation utilisateur

EXEMPLES:
    aklo new pbi "Authentification"
    aklo new task "Implémenter login"
    aklo new arch "Architecture API"
    aklo new debug "Problème performance"
    aklo new meta "Améliorer système d'aide"

Voir aussi: aklo help <type> pour l'aide spécifique à chaque type
EOF
}

show_help_plan() {
    cat << 'EOF'
📋 aklo plan - Planifier les tâches d'un PBI

USAGE:
    aklo plan <PBI_ID>
    aklo plan --interactive

DESCRIPTION:
    Planifie interactivement les tâches nécessaires pour réaliser un PBI.
    Crée les tâches avec estimation et assignation.

ARGUMENTS:
    <PBI_ID>              ID du PBI à planifier

OPTIONS:
    --interactive, -i      Mode interactif pour sélectionner le PBI
    --help, -h            Affiche cette aide

WORKFLOW:
    1. Lit le PBI spécifié
    2. Analyse les critères d'acceptation
    3. Propose des tâches interactivement
    4. Crée les fichiers TASK-*.xml
    5. Met à jour le PBI avec les tâches

EXEMPLES:
    aklo plan 1
    aklo plan --interactive

Voir aussi: aklo propose-pbi --help, aklo start-task --help
EOF
}

show_help_start_task() {
    cat << 'EOF'
▶️  aklo start-task - Commencer une tâche

USAGE:
    aklo start-task <TASK_ID>
    aklo start-task --interactive

DESCRIPTION:
    Prépare l'environnement pour travailler sur une tâche spécifique.
    Crée une branche Git, charge le contexte et ouvre l'éditeur.

ARGUMENTS:
    <TASK_ID>             ID de la tâche à commencer

OPTIONS:
    --interactive, -i      Mode interactif pour sélectionner la tâche
    --help, -h            Affiche cette aide

WORKFLOW:
    1. Vérifie que la tâche existe et est disponible
    2. Crée une branche Git: task/<TASK_ID>
    3. Charge le contexte de la tâche
    4. Ouvre l'éditeur sur les fichiers concernés
    5. Met à jour le statut de la tâche

EXEMPLES:
    aklo start-task 1
    aklo start-task --interactive

Voir aussi: aklo plan --help, aklo submit-task --help
EOF
}

show_help_submit_task() {
    cat << 'EOF'
📤 aklo submit-task - Soumettre une tâche pour review

USAGE:
    aklo submit-task [options]

DESCRIPTION:
    Commit les changements de la tâche courante et la soumet pour review.
    Crée une pull request si configuré.

OPTIONS:
    --message <msg>        Message de commit personnalisé
    --no-commit           Ne pas faire le commit automatiquement
    --help, -h            Affiche cette aide

WORKFLOW:
    1. Vérifie qu'une tâche est en cours
    2. Ajoute tous les fichiers modifiés
    3. Crée un commit avec le message de la tâche
    4. Push la branche
    5. Met à jour le statut de la tâche
    6. Crée une PR si configuré

EXEMPLES:
    aklo submit-task
    aklo submit-task --message "Fix typo in README"

Voir aussi: aklo start-task --help, aklo merge-task --help
EOF
}

show_help_merge_task() {
    cat << 'EOF'
🔀 aklo merge-task - Merger une tâche validée

USAGE:
    aklo merge-task <TASK_ID>
    aklo merge-task --interactive

DESCRIPTION:
    Merge une tâche validée dans la branche principale.
    Nettoie les branches temporaires.

ARGUMENTS:
    <TASK_ID>             ID de la tâche à merger

OPTIONS:
    --interactive, -i      Mode interactif pour sélectionner la tâche
    --help, -h            Affiche cette aide

WORKFLOW:
    1. Vérifie que la tâche est validée
    2. Merge la branche task/<TASK_ID> dans main
    3. Supprime la branche temporaire
    4. Met à jour le statut de la tâche
    5. Met à jour le PBI parent

EXEMPLES:
    aklo merge-task 1
    aklo merge-task --interactive

Voir aussi: aklo submit-task --help, aklo status --help
EOF
}

show_help_release() {
    cat << 'EOF'
🚀 aklo release - Gérer les releases

USAGE:
    aklo release <type>
    aklo release --interactive

DESCRIPTION:
    Démarre le processus de release selon le type spécifié.
    Met à jour les versions et crée les tags Git.

ARGUMENTS:
    <type>                Type de release (major|minor|patch)

OPTIONS:
    --interactive, -i      Mode interactif pour choisir le type
    --help, -h            Affiche cette aide

TYPES DE RELEASE:
    major                  Version majeure (breaking changes)
    minor                  Version mineure (nouvelles fonctionnalités)
    patch                  Version patch (corrections)

WORKFLOW:
    1. Vérifie l'état du projet
    2. Met à jour la version dans package.json
    3. Crée un commit de release
    4. Crée un tag Git
    5. Push les changements

EXEMPLES:
    aklo release patch
    aklo release --interactive

Voir aussi: aklo hotfix --help, aklo status --help
EOF
}

show_help_hotfix() {
    cat << 'EOF'
🔥 aklo hotfix - Gérer les hotfixes

USAGE:
    aklo hotfix <description>
    aklo hotfix publish

DESCRIPTION:
    Gère les hotfixes pour corriger des problèmes critiques en production.

COMMANDES:
    hotfix <description>   Démarre un nouveau hotfix
    hotfix publish         Publie un hotfix terminé

ARGUMENTS:
    <description>          Description du problème à corriger

WORKFLOW:
    1. Crée une branche hotfix depuis main
    2. Permet de corriger le problème
    3. hotfix publish: merge dans main et production

EXEMPLES:
    aklo hotfix "Fix critical login bug"
    aklo hotfix publish

Voir aussi: aklo release --help
EOF
}

show_help_status() {
    cat << 'EOF'
📊 aklo status - État du projet

USAGE:
    aklo status [options]

DESCRIPTION:
    Affiche l'état complet du projet Aklo.

OPTIONS:
    --verbose, -v         Affichage détaillé
    --help, -h            Affiche cette aide

INFORMATIONS AFFICHÉES:
    - Configuration du projet
    - PBI en cours et terminés
    - Tâches en cours et terminées
    - Branches Git actives
    - État des releases

EXEMPLES:
    aklo status
    aklo status --verbose

Voir aussi: aklo init --help
EOF
}

show_help_init() {
    cat << 'EOF'
🚀 aklo init - Initialiser un projet Aklo

USAGE:
    aklo init [options]

DESCRIPTION:
    Initialise un projet avec la Charte Aklo.
    Crée la configuration et lie les protocoles.

OPTIONS:
    --force               Force l'initialisation même si déjà configuré
    --help, -h            Affiche cette aide

WORKFLOW:
    1. Vérifie l'environnement
    2. Crée le fichier .aklo.conf
    3. Lie la Charte IA au projet
    4. Initialise la structure de dossiers
    5. Configure Git hooks si nécessaire

EXEMPLES:
    aklo init
    aklo init --force

Voir aussi: aklo status --help
EOF
}