# PROPOSITION D'AMÉLIORATION : command-coverage-20250102
---
**Responsable:** AI_Agent
**Statut:** ACCEPTED
**Date de Proposition:** 2025-01-02
---

## 1. Diagnostic et Contexte

- **Protocole(s) Concerné(s) :** 
  - Interface utilisateur globale aklo
  - 22 protocoles sans commandes dédiées
  - 7 fonctionnalités système non exposées

- **Friction Observée (Le Problème) :** 
  Audit complet révélant **4 incohérences majeures** dans l'interface aklo :
  
  **1. INTERFACE FRAGMENTÉE :**
  - ✅ **2 commandes aklo disponibles** : `plan`, `release`
  - ❌ **27 fonctionnalités cachées** nécessitant la connaissance de scripts spécifiques
  
  **2. NOMMAGE INCOHÉRENT :**
  - ❌ **Références v2 inutiles** : `command_plan_v2()`, `command_release_v2()`, "COMMANDE RELEASE V2.0"
  - ❌ **Utilisateur unique** : Pas besoin de versioning complexe
  - ❌ **Convention de nommage mixte** : `aklo propose-pbi` (action+objet) vs `aklo dev`/`aklo debug` (action simple)
    - **Incohérence documentée** : `aklo propose-pbi` vs `aklo dev`, `aklo arch`, `aklo debug`
    - **Question** : Normaliser vers `aklo pbi` ou garder `aklo propose-pbi` pour la clarté ?
    - **Impact** : Confusion utilisateur sur la convention à suivre
  
  **3. CONFIGURATION INUTILISÉE :**
  - ❌ **20+ paramètres .aklo.conf définis mais seulement 3 utilisés** (PROJECT_WORKDIR, agent_assistance, auto_journal)
  - ❌ **Casse incohérente** : `agent_assistance` (minuscule) vs `MAIN_BRANCH` (majuscule)
  - ❌ **Paramètres orphelins** : MAIN_BRANCH, PRODUCTION_BRANCH, PBI_DIR, TASKS_DIR, VALIDATE_LINTER, TEST_COMMAND, BUILD_COMMAND, MCP_TERMINAL_SERVER, etc.
  
  **4. DÉPENDANCES NON DOCUMENTÉES :**
  - ❌ **Node.js optionnel non spécifié** : Version minimale et fallback bash/sh non documentés
  
  **FONCTIONNALITÉS SYSTÈME SANS COMMANDES (7) :**
  1. `restart-mcp.sh` (226 lignes) → **manque `aklo mcp restart`**
  2. `setup-mcp.sh` (307 lignes) → **manque `aklo mcp setup`**
  3. `watch-mcp.sh` (233 lignes) → **manque `aklo mcp watch`**
  4. `status-command.sh` (306 lignes) → **manque `aklo status`**
  5. `validation.sh` (485 lignes) → **manque `aklo validate`**
  6. `templates.sh` (733 lignes) → **manque `aklo template`**
  7. `install-ux.sh` (408 lignes) → **manque `aklo install-ux`**
  
  **PROTOCOLES SANS COMMANDES (20) :**
  1. `00-PRODUCT-OWNER.md` → **manque `aklo propose-pbi`**
  2. `02-ARCHITECTURE.md` → **manque `aklo arch`**
  3. `03-DEVELOPPEMENT.md` → **manque `aklo dev`**
  4. `04-DEBOGAGE.md` → **manque `aklo debug`**
  5. `05-REFACTORING.md` → **manque `aklo refactor`**
  6. `06-OPTIMISATION.md` → **manque `aklo optimize`**
  7. `07-REVUE-DE-CODE.md` → **manque `aklo review`**
  8. `08-DIAGNOSTIC-ENV.md` → **manque `aklo diagnose`**
  9. `10-HOTFIX.md` → **manque `aklo hotfix`**
  10. `11-EXPERIMENTATION.md` → **manque `aklo experiment`**
  11. `12-ANALYSE-CONCURRENCE.md` → **manque `aklo analyze`**
  12. `13-SECURITE-AUDIT.md` → **manque `aklo security`**
  13. `14-ONBOARDING.md` → **manque `aklo onboard`**
  14. `15-DEPRECATION.md` → **manque `aklo deprecate`**
  15. `16-TRACKING-PLAN.md` → **manque `aklo track`**
  16. `17-USER-DOCS.md` → **manque `aklo docs`**
  17. `20-FAST-TRACK.md` → **manque `aklo fast`**
  18. `21-META-IMPROVEMENT.md` → **manque `aklo meta`**
  19. `22-KNOWLEDGE-BASE.md` → **manque `aklo kb`**
  20. `18-JOURNAL.md` et `19-SCRATCHPAD.md` → intégrés aux autres commandes

- **Impact Actuel :** 
  - **Interface fragmentée** : utilisateurs doivent connaître 27 scripts cachés
  - **Violation du principe d'interface unifiée** : aklo ne couvre que 7% des fonctionnalités
  - **Expérience utilisateur dégradée** : courbe d'apprentissage énorme
  - **Incohérence avec la charte** : les protocoles ne sont pas directement accessibles
  - **Maintenance difficile** : logique dispersée dans de nombreux scripts
  - **Adoption freinée** : complexité cachée décourage l'utilisation
  - **Configuration inutile** : 85% des paramètres .aklo.conf ne servent à rien
  - **Code legacy** : références v2 polluent la base de code
  - **Dépendances floues** : utilisateurs ne savent pas si Node.js est requis

## 2. Analyse de la Proposition d'Amélioration

- **Solution Proposée :** 
  **Interface aklo complète et unifiée** couvrant 100% des fonctionnalités :
  
  **ARCHITECTURE DE COMMANDES PROPOSÉE :**
  
  ```bash
  # CATÉGORIE SYSTÈME (P1 - Priorité maximale)
  aklo status [--brief|--detailed|--json]     # Tableau de bord projet
  aklo validate [path]                        # Validation projet/artefacts
  aklo mcp setup                              # Configuration MCP initiale
  aklo mcp restart                            # Redémarrage serveurs MCP
  aklo mcp watch                              # Surveillance serveurs MCP
  aklo template list|create|apply             # Gestion templates
  aklo install-ux                             # Installation améliorations UX
  
  # CATÉGORIE DÉVELOPPEMENT (P2 - Protocoles principaux)
  aklo propose-pbi "titre" [--template=X]     # Création PBI (PRODUCT-OWNER)
  aklo plan <PBI_ID> [--no-agent]             # Planification (existant)
  aklo arch <PBI_ID> [--review]               # Architecture (ARCHITECTURE)
  aklo dev <TASK_ID> [--test]                 # Développement (DÉVELOPPEMENT)
  aklo debug <issue> [--trace]                # Débogage (DEBOGAGE)
  aklo review <commit|PR> [--checklist]       # Revue code (REVUE-DE-CODE)
  aklo refactor <scope> [--safe]              # Refactoring (REFACTORING)
  aklo release <type> [--dry-run]             # Release (existant)
  aklo hotfix <issue> [--emergency]           # Hotfix (HOTFIX)
  
  # CATÉGORIE QUALITÉ (P2 - Protocoles qualité)
  aklo optimize <scope> [--profile]           # Optimisation (OPTIMISATION)
  aklo security [--audit|--scan]              # Audit sécurité (SECURITE-AUDIT)
  aklo diagnose [--env|--deps]                # Diagnostic env (DIAGNOSTIC-ENV)
  aklo experiment <name> [--hypothesis]       # Expérimentation (EXPERIMENTATION)
  aklo docs <type> [--user|--dev]             # Documentation (USER-DOCS)
  
  # CATÉGORIE ANALYSE (P3 - Protocoles spécialisés)
  aklo analyze <competitor> [--features]      # Analyse concurrence (ANALYSE-CONCURRENCE)
  aklo track <event> [--plan]                 # Tracking plan (TRACKING-PLAN)
  aklo onboard <user> [--role]                # Onboarding (ONBOARDING)
  aklo deprecate <feature> [--timeline]       # Dépréciation (DEPRECATION)
  aklo kb search|add|update <query>           # Knowledge base (KNOWLEDGE-BASE)
  aklo fast <task> [--skip-validation]        # Fast track (FAST-TRACK)
  aklo meta <improvement> [--analyze]         # Meta improvement (META-IMPROVEMENT)
  ```
  
  **PRINCIPE D'IMPLÉMENTATION :**
  - **Commits atomiques** : Chaque commande suit le principe établi
  - **Niveaux d'assistance** : full/skeleton/minimal pour toutes les commandes
  - **Interface cohérente** : Arguments et options standardisés
  - **Aide contextuelle** : `aklo <cmd> --help` pour chaque commande
  - **Catégorisation logique** : Groupement par domaine fonctionnel

- **Avantages Attendus :**
  - **Interface unifiée à 100%** : une seule commande pour tout aklo
  - **Courbe d'apprentissage réduite** : découverte progressive via `aklo help`
  - **Cohérence avec la charte** : accès direct à tous les protocoles
  - **Productivité améliorée** : pas besoin de chercher les scripts cachés
  - **Maintenance centralisée** : logique unifiée dans un seul script
  - **Adoption facilitée** : expérience utilisateur professionnelle
  - **Extensibilité** : architecture modulaire pour futurs protocoles

- **Inconvénients ou Risques Potentiels :**
  - **Taille du script aklo** : va passer de 590 à ~2000+ lignes
  - **Complexité de maintenance** : plus de commandes à maintenir
  - **Temps d'implémentation** : développement de 27 nouvelles commandes + nettoyage legacy
  - **Compatibilité** : migration des scripts existants vers l'interface unifiée
  - **Tests** : validation de 27 nouvelles commandes + régression sur l'existant
  - **Configuration breaking change** : standardisation de la casse peut casser les configs existantes

## 3. Plan d'Action pour l'Implémentation

- **Modifications à Apporter :**

  **PHASE 0 : NETTOYAGE ET COHÉRENCE (Prérequis obligatoire)**
  - **Supprimer les références v2** : `command_plan_v2()` → `command_plan()`, `command_release_v2()` → `command_release()`
  - **Standardiser la casse de configuration** : `agent_assistance` → `AGENT_ASSISTANCE`, `auto_journal` → `AUTO_JOURNAL`
  - **Résoudre l'incohérence de nommage** : Décision sur `aklo propose-pbi` vs `aklo pbi`
  - **Documenter les dépendances Node.js** : Version minimale 16+, LTS supportées (18, 20, 22), fallback bash/sh obligatoire
  - **Nettoyer les commentaires et sections** : Supprimer "V2.0", "Commits Atomiques" redondants
  - **Paramètres .aklo.conf** : Aucun nouveau paramètre (juste standardisation casse)

  **PHASE 1 : COMMANDES CRITIQUES MANQUANTES (P0 - Urgence)**
  - `aklo propose-pbi` : **Priorité absolue** - Déjà documentée, testée, autocomplétion mais n'existe pas !
  - `aklo status` : Intégration du tableau de bord complet
  - `aklo mcp restart|setup|watch` : Gestion complète des serveurs MCP
  - `aklo validate` : Validation de projets et artefacts
  - `aklo template` : Gestion des templates de projet
  - `aklo install-ux` : Installation des améliorations UX
  - **Paramètres .aklo.conf ajoutés** :
    - `PBI_DIR` (pour propose-pbi et status)
    - `TASKS_DIR`, `ARCH_DIR`, `RELEASES_DIR`, `JOURNAL_DIR` (pour status)
    - `MCP_TERMINAL_SERVER`, `MCP_DOCUMENTATION_SERVER`, `MCP_TIMEOUT` (pour mcp)
    - `VALIDATE_LINTER`, `TEST_COMMAND`, `BUILD_COMMAND`, `LINTER_COMMAND` (pour validate)
  
  **PHASE 2 : PROTOCOLES DÉVELOPPEMENT (P2) - Workflow principal**
  - `aklo arch` : Architecture avec validation et commits atomiques
  - `aklo dev` : Développement avec tests et commits atomiques
  - `aklo debug` : Débogage structuré avec traçabilité
  - `aklo review` : Revue de code avec checklists
  - `aklo refactor` : Refactoring sécurisé avec validation
  - `aklo hotfix` : Correction d'urgence avec workflow accéléré
  - **Paramètres .aklo.conf ajoutés** :
    - `ARCH_DIR` (pour arch - si pas déjà ajouté en PHASE 1)
    - `VALIDATE_TESTS` (pour dev)
    - `MAIN_BRANCH`, `PRODUCTION_BRANCH`, `USE_RELEASE_BRANCHES` (pour hotfix)
    - `GIT_TAG_FORMAT` (pour release et hotfix)
  
  **PHASE 3 : PROTOCOLES QUALITÉ (P2) - Assurance qualité**
  - `aklo optimize` : Optimisation avec profiling
  - `aklo security` : Audit sécurité automatisé
  - `aklo diagnose` : Diagnostic environnement et dépendances
  - `aklo experiment` : Expérimentation avec hypothèses
  - `aklo docs` : Documentation utilisateur et développeur
  - **Paramètres .aklo.conf ajoutés** :
    - `PROFILING_TOOL`, `PERFORMANCE_BASELINE` (pour optimize)
    - `SECURITY_SCANNER`, `SECURITY_RULES` (pour security)
    - `DOCS_DIR`, `DOCS_FORMAT` (pour docs)
  
  **PHASE 4 : PROTOCOLES SPÉCIALISÉS (P3) - Fonctionnalités avancées**
  - `aklo analyze` : Analyse concurrence avec comparaisons
  - `aklo track` : Tracking plan avec événements
  - `aklo onboard` : Onboarding avec rôles
  - `aklo deprecate` : Dépréciation avec timeline
  - `aklo kb` : Knowledge base avec recherche
  - `aklo fast` : Fast track avec validation optionnelle
  - `aklo meta` : Meta improvement avec analyse d'impact
  - **Paramètres .aklo.conf ajoutés** :
    - `TRACKING_ANALYTICS`, `TRACKING_EVENTS` (pour track)
    - `ONBOARDING_TEMPLATES`, `USER_ROLES` (pour onboard)
    - `KB_INDEX`, `KB_SEARCH_ENGINE` (pour kb)
    - `DEPRECATION_TIMELINE`, `DEPRECATION_NOTICES` (pour deprecate)

  **RÉSOLUTION INCOHÉRENCE DE NOMMAGE :**
  
  **Problème identifié** : `aklo propose-pbi` (action+objet) vs `aklo dev`/`aklo debug` (action simple)
  
  **Options analysées** :
  1. **Normaliser vers action simple** : `aklo propose-pbi` → `aklo pbi`
     - ✅ Cohérent avec `aklo dev`, `aklo debug`
     - ❌ Ambigu : "pbi" pourrait signifier lister, créer, modifier
  
  2. **Garder action+objet pour la clarté** : `aklo propose-pbi` 
     - ✅ Action claire et explicite
     - ❌ Incohérent avec les autres commandes
  
  3. **Solution hybride** : `aklo pbi` comme alias de `aklo propose-pbi`
     - ✅ Compatibilité ascendante
     - ✅ Choix utilisateur
     - ❌ Complexité supplémentaire
  
  **Décision recommandée** : **Garder `aklo propose-pbi`** pour la clarté et ajouter `aklo pbi` comme alias
  - La création de PBI est une action critique qui mérite d'être explicite
  - L'alias `aklo pbi` satisfait les utilisateurs préférant la concision
  - Cohérent avec `aklo start-task`, `aklo submit-task`, `aklo merge-task` existants

  **ARCHITECTURE TECHNIQUE :**
  - **Système modulaire** : Une fonction par commande
  - **Dispatch centralisé** : Logique de routage dans main()
  - **Système d'alias** : `aklo pbi` → `command_propose_pbi()`
  - **Aide contextuelle** : Système d'aide intégré pour chaque commande
  - **Validation d'arguments** : Contrôles cohérents pour toutes les commandes
  - **Gestion d'erreurs** : Messages d'erreur standardisés
  - **Logging unifié** : Journal intégré pour toutes les opérations

- **Effort d'Implémentation Estimé :** 
  **Très Élevé** - Nettoyage legacy + développement de 27 nouvelles commandes + implémentation de 20+ paramètres de configuration + documentation Node.js, mais impact transformationnel sur l'expérience utilisateur et cohérence du système.

## 4. Checklist de Validation

**NETTOYAGE ET COHÉRENCE :**
- [ ] Les références v2 inutiles sont supprimées (command_plan_v2, command_release_v2).
- [ ] La casse de configuration est standardisée (AGENT_ASSISTANCE, AUTO_JOURNAL).
- [ ] Les 20+ paramètres .aklo.conf inutilisés sont implémentés et fonctionnels.
- [ ] Les dépendances Node.js sont documentées (version 16+, fallback bash/sh).
- [ ] La compatibilité descendante de configuration est préservée ou migration documentée.

**INTERFACE UNIFIÉE :**
- [ ] L'impact de cette modification sur l'expérience utilisateur a été évalué.
- [ ] La proposition couvre 100% des fonctionnalités aklo existantes.
- [ ] L'architecture modulaire permet l'extensibilité future.
- [ ] Les principes des commits atomiques sont respectés pour toutes les commandes.
- [ ] Les 3 niveaux d'assistance sont implémentés de manière cohérente.
- [ ] Le système d'aide contextuelle est complet et utile.
- [ ] La compatibilité avec les scripts existants est assurée.

**QUALITÉ ET TESTS :**
- [ ] Les tests de validation couvrent toutes les nouvelles commandes.
- [ ] Les tests de régression valident que l'existant fonctionne toujours.
- [ ] La migration depuis l'état actuel est planifiée et réalisable.
- [ ] L'impact sur la maintenance future est acceptable.
- [ ] La commande `aklo propose-pbi` fonctionne (priorité absolue car déjà documentée). 