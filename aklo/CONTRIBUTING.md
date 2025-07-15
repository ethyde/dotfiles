# Contribuer à Aklo 🤖

Merci de votre intérêt pour Aklo ! Ce guide a pour but de vous fournir toutes les informations nécessaires pour comprendre le projet, le faire évoluer et y contribuer de manière cohérente et efficace.

## Table des Matières
1.  [Philosophie du Projet](#philosophie-du-projet)
2.  [Architecture Générale](#architecture-générale)
3.  [Mise en Place de l'Environnement](#mise-en-place-de-lenvironnement)
4.  [Le Workflow de Développement (TDD)](#le-workflow-de-développement-tdd)
5.  [Comment Ajouter une Nouvelle Commande](#comment-ajouter-une-nouvelle-commande)
6.  [Les Tests : Notre Filet de Sécurité](#les-tests--notre-filet-de-sécurité)
7.  [Conventions de Code](#conventions-de-code)

---

## Philosophie du Projet

Aklo est plus qu'un simple outil ; c'est un **système de gouvernance de développement** qui impose un cadre de travail rigoureux. Sa mission est d'apporter de la structure, de la traçabilité et de l'automatisation à des projets logiciels.

L'outil en ligne de commande (`aklo`) est l'exécuteur de cette gouvernance, en s'appuyant sur les protocoles définis dans la **Charte IA** (`aklo/charte/`).

---

## Architecture Générale

L'architecture d'Aklo est conçue pour être **modulaire, robuste et testable**.

### Le Dispatcher Central

Le cœur de l'outil est le script `aklo/bin/aklo`. Il a deux responsabilités majeures :
1.  **Définir le Contexte :** Il initialise deux variables d'environnement cruciales :
    * `AKLO_TOOL_DIR` : Le chemin absolu vers l'installation d'Aklo, utilisé pour charger les modules internes.
    * `AKLO_PROJECT_ROOT` : Le chemin absolu du projet sur lequel la commande est exécutée (`pwd`).
2.  **Router les Commandes :** Il utilise une structure `case` pour diriger la commande entrée par l'utilisateur (ex: `new`, `plan`) vers la fonction `cmd_*` correspondante.

### Les Modules

Le code est organisé en modules spécialisés dans `aklo/modules/` :
-   **`core/`** : Fonctions transverses comme le parser (`parser.sh`) et la gestion de la configuration (`config.sh`).
-   **`cache/`** : Tout ce qui concerne la gestion du cache.
-   **`commands/`** : La logique métier de chaque commande. C'est ici que la majorité des contributions se feront.

---

## Mise en Place de l'Environnement

1.  **Prérequis :** Assurez-vous d'avoir `bash` (v4+), `git`, et `jq` installés. `jq` est utilisé pour la manipulation robuste du JSON dans certains modules.
2.  **Installation :** Lancez le script `./install` à la racine des `dotfiles` pour créer les liens symboliques nécessaires.
3.  **Permissions :** Exécutez `./bin/fix-permissions.sh` pour vous assurer que tous les scripts sont exécutables.

---

## Le Workflow de Développement (TDD)

Toute modification ou ajout de fonctionnalité doit suivre un cycle TDD (Test-Driven Development) :

1.  **RED** : Écrire un test qui échoue parce que la fonctionnalité n'existe pas encore.
2.  **GREEN** : Écrire le code minimal pour faire passer le test.
3.  **BLUE (Refactor)** : Améliorer la qualité du code sans en changer le comportement.

---

## Comment Ajouter une Nouvelle Commande

Voici la procédure standard pour ajouter une commande, par exemple `aklo validate`.

1.  **Créer le Module de Commande**
    Créez le fichier `aklo/modules/commands/validate_command.sh`.

2.  **Implémenter la Logique Métier**
    Dans ce nouveau fichier, écrivez la fonction `cmd_validate` :
    ```bash
    #!/usr/bin/env bash
    #======================================
    # AKLO VALIDATE COMMAND MODULE
    #======================================
    
    cmd_validate() {
        echo "Validation du projet en cours dans ${AKLO_PROJECT_ROOT}..."
        # ... votre logique ici ...
        return 0
    }
    ```

3.  **Créer le Fichier de Test**
    Créez `aklo/tests/test_validate.sh` et écrivez un test simple qui vérifie que la commande s'exécute avec succès.
    ```bash
    #!/usr/bin/env bash
    source "${AKLO_PROJECT_ROOT}/aklo/tests/test_framework.sh"
    source "${AKLO_PROJECT_ROOT}/aklo/modules/commands/validate_command.sh"

    test_validate_runs_successfully() {
        test_suite "Command: aklo validate"
        local output
        output=$(cmd_validate)
        assert_contains "$output" "Validation du projet" "La commande doit afficher un message de succès"
    }

    main() {
        test_validate_runs_successfully
        test_summary
    }

    main
    ```

4.  **Intégrer dans le Dispatcher**
    Ouvrez `aklo/bin/aklo` :
    * **Sourcez** votre nouveau module :
        ```bash
        source "${AKLO_TOOL_DIR}/modules/commands/validate_command.sh"
        ```
    * **Ajoutez** la commande au `case` dans la fonction `main` :
        ```bash
        case "$command" in
            # ... autres commandes
            validate) cmd_validate "$@" ;;
        esac
        ```

5.  **Valider**
    Lancez la suite de tests complète. Votre nouveau test doit passer, et aucun autre test ne doit avoir régressé.
    ```bash
    ./aklo/tests/run_tests.sh
    ```

---

## Les Tests : Notre Filet de Sécurité

Les tests sont au cœur de la stabilité d'Aklo et sont situés dans `aklo/tests/`.

* **`test_framework.sh`** : Contient toutes les fonctions d'assertion (`assert_equals`, `assert_file_exists`, etc.) et la logique de création d'environnements de test isolés (`setup_artefact_test_env`).
* **`run_tests.sh`** : Le lanceur de tests principal. Il découvre et exécute tous les scripts `test_*.sh` (sauf ceux dans `deprecated/`).

---

## Conventions de Code

* **Shebang :** Toujours utiliser `#!/usr/bin/env bash` pour garantir la portabilité.
* **Nommage des fonctions :**
    * Les fonctions appelées par le dispatcher principal sont préfixées par `cmd_` (ex: `cmd_plan`).
    * Les fonctions de création d'artefacts sont préfixées par `create_artefact_` (ex: `create_artefact_pbi`).
* **Gestion des Erreurs :** Toute fonction doit retourner un code de sortie non-nul (`return 1`) en cas d'échec et afficher un message d'erreur explicite sur `stderr` (`>&2`).
* **Variables de Chemin :**
    * `AKLO_TOOL_DIR` **doit** être utilisé pour sourcer les modules internes.
    * `AKLO_PROJECT_ROOT` **doit** être utilisé pour toutes les opérations sur les fichiers du projet cible (création d'artefacts, etc.).