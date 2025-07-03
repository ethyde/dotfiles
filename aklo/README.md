# The Aklo Protocol

*« Ce n'est pas ce qui est mort qui peut sommeiller à jamais, et au long des ères étranges la Mort même peut mourir. »*

---

## 1. Philosophie : Qu'est-ce que "The Aklo Protocol" ?

**The Aklo Protocol** n'est pas un simple outil, c'est un **système de gouvernance** pour le développement de logiciels. Il a pour but d'imposer un cadre de travail rigoureux, traçable et de haute qualité, en s'appuyant sur deux piliers :

1.  **La Charte IA (`./charte/`) :** C'est notre "Necronomicon", la source de vérité unique qui définit tous nos processus de travail. Elle est conçue pour être lue et comprise par les humains et les IA.
2.  **L'outil `aklo` (`./bin/aklo`) :** C'est le "Grand Prêtre", l'exécuteur des rituels décrits dans la Charte. C'est un outil en ligne de commande qui automatise les tâches répétitives pour garantir que les protocoles sont suivis à la lettre, sans erreur. L'outil s'appuie sur une architecture modulaire organisée dans `./modules/` pour la cache, I/O, performance, parsing, MCP et UX.

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

### Commandes Système et Diagnostic

| Commande | Arguments | Description |
| :--- | :--- | :--- |
| `aklo status` | `[--brief\|--detailed\|--json]` | **Tableau de bord du projet** avec état des PBI, tâches et configuration. Inclut métriques de performance et monitoring. |
| `aklo get_config` | `[<clé>] [--all]` | **Affiche la configuration** effective (debugging, scripts, validation). |
| `aklo config` | `tune\|profile\|diagnose\|validate` | **Configuration de performance.** Auto-tuning, profils d'environnement, diagnostic mémoire. |
| `aklo validate` | `[path]` | **Validation du projet** (linter, tests, build selon configuration). |

### Commandes Cache et Performance

| Commande | Arguments | Description |
| :--- | :--- | :--- |
| `aklo cache` | `status\|clear\|benchmark\|dashboard` | **Gestion du cache intelligent.** Statistiques, nettoyage, tests de performance, dashboard I/O. |
| `aklo monitor` | `dashboard\|memory\|performance\|cleanup` | **Monitoring et métriques.** Dashboard I/O temps réel, diagnostic mémoire, vue complète. |

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

### Commandes de Création d'Artefacts Spécialisés

| Commande | Arguments | Description |
| :--- | :--- | :--- |
| `aklo debug` | `"<titre>"` | Crée un rapport de débogage pour diagnostiquer un problème. |
| `aklo refactor` | `"<description>"` | Planifie une session de refactoring sécurisé. |
| `aklo optimize` | `"<objectif>"` | Lance une optimisation de performance ciblée. |
| `aklo experiment` | `"<hypothèse>"` | Démarre une expérimentation A/B ou test d'hypothèse. |
| `aklo analyze` | `"<sujet>"` | Analyse concurrentielle ou étude de marché. |
| `aklo deprecate` | `"<fonctionnalité>"` | Planifie la dépréciation d'une fonctionnalité. |
| `aklo fast` | `"<tâche>"` | Procédure accélérée pour petites modifications. |
| `aklo scratch` | `"<sujet>"` | Brainstorming et scratchpad temporaire. |
| `aklo meta` | `"<amélioration>"` | Amélioration du protocole Aklo lui-même. |
| `aklo track` | `<PBI_ID>` | Plan de tracking et analytics pour une fonctionnalité. |
| `aklo docs` | `"<sujet>"` | Documentation utilisateur ou développeur. |
| `aklo security` | `[<périmètre>]` | Audit de sécurité (utilise la date courante si sans argument). |

## 4. Un Cycle de Vie Complet (Exemple de Workflow)

1.  **Initialisation du projet :**
    ```bash
    git clone mon-super-projet.git
    cd mon-super-projet
    aklo init
    aklo status                    # Vérifier l'état du projet
    aklo get_config --all          # Vérifier la configuration
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

6.  **Maintenance et Support :**
    ```bash
    # Débogage d'un problème
    aklo debug "Erreur 500 lors du login"
    
    # Optimisation de performance
    aklo optimize "Temps de chargement page d'accueil"
    
    # Audit de sécurité
    aklo security
    
    # Refactoring du code
    aklo refactor "Simplification de l'architecture auth"
    ```

7.  **Monitoring et Performance :**
    ```bash
    # Dashboard I/O en temps réel
    aklo monitor dashboard
    
    # Diagnostic mémoire et caches
    aklo monitor memory
    
    # Vue complète performance
    aklo monitor performance
    
    # Configuration auto-tuning
    aklo config tune
    
    # Appliquer profil production
    aklo config profile prod
    
    # Statistiques cache
    aklo cache status
    
    # Tests de performance cache
    aklo cache benchmark
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

### c) Clés de Configuration Essentielles

Il y a plusieurs clés de configuration importantes pour le bon fonctionnement :

  * **`PROJECT_WORKDIR`** : Définit le chemin absolu vers la racine du projet. L'IA lit cette clé au début de chaque session pour savoir où elle travaille.
  * **`cache_enabled`** : Active/désactive le système de cache intelligent (défaut: true).
  * **`cache_max_size_mb`** : Taille maximale du cache en MB (défaut: configurable selon environnement).
  * **`auto_tune_enabled`** : Active l'auto-tuning des performances selon l'environnement (défaut: true).

Il est **fortement recommandé** de définir cette clé dans un fichier `.aklo.conf` local à la racine de chaque projet sur lequel vous travaillez.

**Exemple de fichier `.aklo.conf` local complet :**

```sh
# Fichier : /chemin/vers/mon/projet/.aklo.conf

# Configuration Git
MAIN_BRANCH=main
PROJECT_WORKDIR=/chemin/vers/mon/projet

# Configuration Cache et Performance
[cache]
enabled=true
cache_dir=.aklo/cache
ttl_days=7

[performance]
cache_max_size_mb=100
auto_tune_enabled=true
environment=auto
monitoring_level=normal
```

Lorsque vous lancerez `aklo start-task` dans ce projet, il utilisera `main` comme branche de base, sans affecter vos autres projets. N'oubliez pas d'ajouter `.aklo.conf` à votre `.gitignore` si vous ne souhaitez pas versionner cette configuration spécifique au projet.

**Note :** Depuis la version améliorée, `aklo init` configure automatiquement `.gitignore` avec les patterns de sécurité appropriés. Pour les projets existants, consultez [MIGRATION-SECURITY.md](MIGRATION-SECURITY.md).

## 6. Faire évoluer le Protocole

Ce système est conçu pour être un document vivant. Toute proposition d'amélioration de la Charte ou de l'outil `aklo` lui-même doit suivre le **protocole [META-IMPROVEMENT]**, qui peut être initié via la commande :
```bash
aklo meta "Rendre la commande 'plan' non-interactive"
```

**Autres exemples d'amélioration :**
```bash
aklo meta "Ajouter support pour les templates personnalisés"
aklo meta "Intégration avec les webhooks Git"
```