# 🤖 The Aklo Protocol

*« Ce n'est pas ce qui est mort qui peut sommeiller à jamais, et au long des ères étranges la Mort même peut mourir. »*

-----

## 1. Philosophie : Qu'est-ce que "The Aklo Protocol" ?

**The Aklo Protocol** est un système de gouvernance pour le développement de logiciels. Il impose un cadre de travail rigoureux et traçable en s'appuyant sur deux piliers :

1.  **La Charte IA (`./charte/`) :** La source de vérité qui définit tous nos processus de travail.
2.  **L'outil `aklo` (`./bin/aklo`) :** L'exécuteur des rituels décrits dans la Charte. C'est un outil en ligne de commande qui s'appuie sur une **architecture modulaire et robuste** située dans `./modules/`.

Cette architecture utilise un **chargement intelligent** pour n'activer que les modules strictement nécessaires à chaque commande, garantissant ainsi des performances optimales.

## 2\. Installation et Configuration

L'outil `aklo` est installé via le script `install` à la racine, qui crée un lien symbolique rendant la commande disponible globalement. Pour la configuration, `aklo` utilise le fichier `.aklo.conf` à la racine de votre projet pour surcharger les valeurs par défaut.

**Pour plus de détails :**

  * **Installation :** [`aklo/PATH-SETUP.md`](https://www.google.com/search?q=aklo/PATH-SETUP.md)
  * **Sécurité et Migration :** [`aklo/MIGRATION-SECURITY.md`](https://www.google.com/search?q=aklo/MIGRATION-SECURITY.md)
  * **Architecture Modulaire :** [`aklo/MIGRATION-MODULES.md`](https://www.google.com/search?q=aklo/MIGRATION-MODULES.md)

## 3. Le Grimoire des Commandes

Toutes les commandes supportent l'option universelle `--dry-run` pour simuler une exécution sans effectuer de modifications.

### Workflow Principal

| Commande | Arguments | Description |
|:---|:---|:---|
| `aklo init` | - | **Initialise le projet** (crée `.aklo.conf`, `.gitignore`, etc.). |
| `aklo new pbi` | `"<titre>"` | Crée un nouvel artefact **Product Backlog Item**. |
| `aklo plan` | `<PBI_ID>` | **Décompose un PBI** en tâches techniques de manière interactive. |
| `aklo start-task` | `<TASK_ID>` | **Commence une tâche** : crée la branche Git et met à jour le statut. |
| `aklo submit-task`| - | **Soumet une tâche** : crée un commit standardisé et pousse la branche. |
| `aklo merge-task` | `<TASK_ID>` | **Fusionne une tâche** validée et nettoie la branche. |

### Cycle de Vie & Publication

| Commande | Arguments | Description |
|:---|:---|:---|
| `aklo release` | `<type>` | Orchestre la **publication d'une nouvelle version** (`major`, `minor`, `patch`). |
| `aklo hotfix` | `start "<desc>"` | Démarre une **correction critique** en production. |
| `aklo hotfix` | `publish` | Publie le hotfix terminé. |

### Création d'Artefacts Spécialisés

| Commande | Arguments | Description |
|:---|:---|:---|
| `aklo new debug` | `"<titre>"` | Crée un rapport de débogage. |
| `aklo new refactor` | `"<titre>"` | Crée un plan de refactoring. |
| `aklo new optimize`| `"<titre>"` | Crée un plan d'optimisation. |
| `aklo new ...` | | `experiment`, `security`, `docs`, `scratchpad`, `meta`, `kb`... |

### Commandes Utilitaires

| Commande | Arguments | Description |
|:---|:---|:---|
| `aklo status` | `[--brief]` | **Tableau de bord** complet de l'état du projet. |
| `aklo cache` | `<action>` | **Gestion du cache** (`status`, `clear`, `benchmark`). |
| `aklo config` | `<action>` | **Configuration de la performance** (`diagnose`, `tune`). |
| `aklo monitor` | `<action>` | **Monitoring I/O et performance** (`dashboard`). |

## 4. Exemple de Workflow Complet avec `--dry-run`

1.  **Planification :**

    ```bash
    # Simuler la création d'un PBI
    aklo new pbi "Mon Super PBI" --dry-run

    # Simuler la planification des tâches
    aklo plan 1 --dry-run 
    ```

2.  **Développement :**

    ```bash
    # Simuler le démarrage d'une tâche
    aklo start-task 1-1 --dry-run

    # Simuler la soumission pour revue
    aklo submit-task --dry-run

    # Simuler la fusion
    aklo merge-task 1-1 --dry-run
    ```

3.  **Monitoring :**

    ```bash
    # Consulter le statut du cache
    aklo cache status

    # Lancer le dashboard de monitoring I/O
    aklo monitor dashboard
    ```

## 5. Un Cycle de Vie Complet (Exemple de Workflow)

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

## 6. Configuration (`.aklo.conf`)

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
aklo new meta "Rendre la commande 'plan' non-interactive"
```

**Autres exemples d'amélioration :**
```bash
aklo new meta "Ajouter support pour les templates personnalisés"
aklo new meta "Intégration avec les webhooks Git"
```