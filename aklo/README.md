# The Aklo Protocol

*« Ce n'est pas ce qui est mort qui peut sommeiller à jamais, et au long des ères étranges la Mort même peut mourir. »*

---

## 1. Philosophie : Qu'est-ce que "The Aklo Protocol" ?

**The Aklo Protocol** n'est pas un simple outil, c'est un **système de gouvernance** pour le développement de logiciels. Il a pour but d'imposer un cadre de travail rigoureux, traçable et de haute qualité, en s'appuyant sur deux piliers :

1.  **La Charte IA (`./charte/`) :** C'est notre "Necronomicon", la source de vérité unique qui définit tous nos processus de travail. Elle est conçue pour être lue et comprise par les humains et les IA.
2.  **L'outil `aklo` (`./bin/aklo`) :** C'est le "Grand Prêtre", l'exécuteur des rituels décrits dans la Charte. C'est un outil en ligne de commande qui automatise les tâches répétitives pour garantir que les protocoles sont suivis à la lettre, sans erreur.

Ce système est intégré à ce dépôt `dotfiles` pour assurer que tout projet que vous entreprenez respecte les mêmes standards élevés de qualité.

## 2. Installation et Configuration

### 2.1 Installation Système (Une fois par machine)

L'outil `aklo` est installé en même temps que le reste de vos `dotfiles` via le script `install` à la racine. Celui-ci, grâce à `dotbot`, crée un lien symbolique qui rend la commande `aklo` disponible globalement dans votre terminal.

**Pour plus de détails sur la configuration PATH :** Voir [PATH-SETUP.md](PATH-SETUP.md)

### 2.2 Sécurité et Migration

⚠️ **Important :** Si vous avez des projets existants utilisant Aklo, consultez impérativement le guide de migration pour éviter les problèmes de sécurité Git.

**Pour migrer des projets existants :** Voir [MIGRATION-SECURITY.md](MIGRATION-SECURITY.md)

**Problèmes de sécurité résolus :**
- Prévention du commit accidentel des fichiers de configuration Aklo
- Gestion sécurisée des liens symboliques vers la Charte IA
- Patterns `.gitignore` optimisés pour tous les artefacts Aklo

## 3. Les Rituels Quotidiens (Commandes `aklo`)

Voici le grimoire complet des commandes disponibles.

### Commandes de Workflow Principal

| Commande | Arguments | Description |
| :--- | :--- | :--- |
| `aklo init` | - | **Initialise le projet.** Crée le lien vers la Charte, crée et pré-remplit le fichier .aklo.conf local, configure .gitignore avec protection sécurisée, et vérifie automatiquement la sécurité Git. **C'est la première et unique étape de configuration d'un projet.** |
| `aklo propose-pbi` | `"<titre>"` | Crée un nouvel artefact **Product Backlog Item** pour démarrer un travail. |
| `aklo plan` | `<PBI_ID>` | Lance une session interactive pour **décomposer un PBI** en tâches techniques. |
| `aklo start-task` | `<TASK_ID>` | Prépare l'environnement pour **commencer le développement** d'une tâche (crée la branche Git, etc.). |
| `aklo submit-task` | - | **Soumet une tâche terminée** pour revue (commit, push, mise à jour du statut). Détecte la tâche depuis la branche Git. |
| `aklo merge-task` | `<TASK_ID>` | **Fusionne une tâche validée** dans la branche de développement principale et nettoie la branche de feature. |

### Commandes de Cycle de Vie et d'Urgence

| Commande | Arguments | Description |
| :--- | :--- | :--- |
| `aklo release` | `<type>` | Orchestre le processus de **publication d'une nouvelle version**. `type` peut être `major`, `minor`, ou `patch`. |
| `aklo hotfix` | `"<description>"` | Démarre le processus d'urgence pour une **correction critique** en production depuis le dernier tag. |
| `aklo hotfix publish`| - | **Publie le hotfix** une fois la correction effectuée (merge, tag de patch, etc.). |

### Commande de Création d'Artefacts ("Scaffolding")

| Commande | Arguments | Description |
| :--- | :--- | :--- |
| `aklo new` | `<type> [args...]` | Crée rapidement un artefact de support. Le deuxième argument dépend du `type`. |

**Types disponibles pour `aklo new` :**
* **Basés sur un titre :** `debug`, `refactor`, `optim`, `experiment`, `competition`, `deprecation`, `fast-track`, `scratchpad`, `meta-improvement`.
    * *Exemple :* `aklo new debug "Erreur 500 lors du login"`
* **Basés sur un ID parent :** `tracking-plan`, `user-docs`.
    * *Exemple :* `aklo new tracking-plan 42-1`
* **Sans argument :** `security-audit` (utilise la date courante).
    * *Exemple :* `aklo new security-audit`

## 4. Un Cycle de Vie Complet (Exemple de Workflow)

1.  **Initialisation du projet :**
    ```bash
    git clone mon-super-projet.git
    cd mon-super-projet
    aklo init
    ```

2.  **Définition et Planification :**
    ```bash
    aklo propose-pbi "Ajouter un mode sombre à l'application"
    # -> Vous ou l'IA remplissez le PBI-1-PROPOSED.md...
    aklo plan 1
    # -> Session interactive pour créer les tâches TASK-1-1, TASK-1-2...
    ```

3.  **Développement d'une tâche :**
    ```bash
    aklo start-task 1-1
    # -> Vous ou l'IA écrivez le code et les tests sur la nouvelle branche...
    aklo submit-task
    ```

4.  **Revue et Fusion :**
    *La revue de code est faite sur la plateforme Git (GitHub, GitLab, etc.).*
    ```bash
    aklo merge-task 1-1
    ```

5.  **Publication :**
    *Une fois plusieurs tâches fusionnées...*
    ```bash
    aklo release minor
    ```

## 5. Configuration (`.aklo.conf`)

L'outil `aklo` est configurable pour s'adapter aux conventions de chaque projet. La configuration est gérée par un système à deux niveaux.

### a) Configuration Globale

Un fichier de configuration par défaut se trouve dans votre dépôt `dotfiles` à l'emplacement :
`aklo/config/.aklo.conf`

Ce fichier contient vos conventions par défaut (ex: `MAIN_BRANCH=develop`).

### b) Surcharge par Projet (Override)

Pour n'importe quel projet, vous pouvez surcharger un ou plusieurs paramètres en créant un fichier portant le même nom (`.aklo.conf`) à la racine de votre projet.

**Exemple :**
Pour un projet qui utilise `main` comme branche principale, votre fichier `.aklo.conf` à la racine de ce projet contiendra :

```sh
# Fichier : /chemin/vers/mon/projet/.aklo.conf
MAIN_BRANCH=main
```

### c) Clé de Configuration Essentielle (AJOUTÉ)

Il y a une clé de configuration qui est particulièrement importante pour le bon fonctionnement de l'IA :

  * **`PROJECT_WORKDIR`** : Définit le chemin absolu vers la racine du projet. L'IA lit cette clé au début de chaque session pour savoir où elle travaille.

Il est **fortement recommandé** de définir cette clé dans un fichier `.aklo.conf` local à la racine de chaque projet sur lequel vous travaillez.

**Exemple de fichier `.aklo.conf` local complet :**

```sh
# Fichier : /chemin/vers/mon/projet/.aklo.conf

# On surcharge la branche principale pour ce projet spécifique.
MAIN_BRANCH=main

# On définit le contexte de travail pour l'IA.
PROJECT_WORKDIR=/chemin/vers/mon/projet
```

Lorsque vous lancerez `aklo start-task` dans ce projet, il utilisera `main` comme branche de base, sans affecter vos autres projets. N'oubliez pas d'ajouter `.aklo.conf` à votre `.gitignore` si vous ne souhaitez pas versionner cette configuration spécifique au projet.

**Note :** Depuis la version améliorée, `aklo init` configure automatiquement `.gitignore` avec les patterns de sécurité appropriés. Pour les projets existants, consultez [MIGRATION-SECURITY.md](MIGRATION-SECURITY.md).

## 6. Faire évoluer le Protocole

Ce système est conçu pour être un document vivant. Toute proposition d'amélioration de la Charte ou de l'outil `aklo` lui-même doit suivre le **protocole [META-IMPROVEMENT]**, qui peut être initié via la commande :
`aklo new meta-improvement "Rendre la commande 'plan' non-interactive"`