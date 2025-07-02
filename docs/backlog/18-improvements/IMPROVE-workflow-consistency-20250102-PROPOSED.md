# PROPOSITION D'AMÉLIORATION : workflow-consistency-20250102
---
**Responsable:** AI_Agent
**Statut:** IMPLEMENTED
**Date de Proposition:** 2025-01-02
---

## 1. Diagnostic et Contexte

- **Protocole(s) Concerné(s) :** 
  - `00-CADRE-GLOBAL.md` (principes fondamentaux)
  - `18-JOURNAL.md` (incohérence majeure)
  - `01-PLANIFICATION.md` (incohérence mineure)
  - `02-ARCHITECTURE.md` (incohérence mineure)
  - `09-RELEASE.md` (incohérence modérée)
  - `19-SCRATCHPAD.md` (zone grise)

- **Friction Observée (Le Problème) :** 
  Lors de l'audit complet des protocoles Aklo, plusieurs incohérences majeures ont été identifiées concernant l'application des principes fondamentaux du CADRE-GLOBAL, notamment :
  
  1. **JOURNAL** : Modifications continues de fichiers sans workflow de diff/validation/commit, violant le Principe 4 (Revue Systématique Avant Commit)
  2. **PLANIFICATION** : Création d'artefacts TASK sans workflow de commit défini
  3. **ARCHITECTURE** : Modification d'artefacts sans mention de validation/commit
  4. **RELEASE** : Workflow de commits multiples mal défini avec validations partielles
  5. **SCRATCHPAD** : Statut des fichiers temporaires ambigu (versionnés ou non)
  6. **Commandes aklo** : Mentions d'automatisation sans définir le respect des règles de validation ni les niveaux d'assistance

- **Impact Actuel :** 
  - Violation des principes fondamentaux de traçabilité et de validation
  - Confusion sur ce qui doit être commité vs ce qui reste "vivant"
  - Risque de commits non validés via les commandes d'automatisation
  - Pollution de l'état Git avec des modifications non trackées
  - Absence de flexibilité dans l'automatisation (pas d'adaptation au contexte)
  - Perte de confiance dans la cohérence de la charte## 2. Analyse de la Proposition d'Amélioration

- **Solution Proposée :** 
  Adoption du principe unifié **"Un protocole = Un commit atomique"** avec automatisation intelligente et configurable :
  
  **PRINCIPE FONDAMENTAL :**
  Chaque protocole produit un commit atomique incluant :
  - L'artefact principal du protocole
  - Toutes les modifications d'artefacts connexes (TASK, etc.)
  - La mise à jour du journal correspondante
  
  **EXEMPLES D'APPLICATION :**
  - PLANIFICATION : commit(toutes-TASK-créées + journal-update)
  - ARCHITECTURE : commit(ARCH-VALIDATED + TASK-modifiées + journal-update)
  - Finalisation TASK : commit(code + TASK-DONE + journal-update)
  - PBI status change : commit(PBI-AGREED + journal-update)
  
  **AUTOMATISATION INTELLIGENTE DES COMMANDES AKLO :**
  
  Trois niveaux d'assistance configurables :
  1. **`full`** : Contenu complet généré par l'IA + journal détaillé
  2. **`skeleton`** : Structure et sections vides + journal complet ou minimal
  3. **`minimal`** : Fichiers avec IDs/nommage uniquement + journal minimal
  
  **Logique des arguments CLI :**
  ```bash
  # Défaut (sans config)
  aklo plan <PBI_ID>  
  # = agent_assistance=full + auto_journal=true
  
  # Override vers skeleton + journal complet
  aklo plan <PBI_ID> --no-agent
  # = agent_assistance=skeleton + auto_journal=true  
  
  # Override vers skeleton + journal minimal
  aklo plan <PBI_ID> --no-agent --no-journal
  # = agent_assistance=skeleton + auto_journal=false
  ```
  
  **Configuration .aklo.conf (seule façon d'avoir minimal) :**
  ```ini
  [automation]
  agent_assistance=full|skeleton|minimal
  auto_journal=true|false
  ```
  
  **GESTION DES CAS PARTICULIERS :**
  - **Protocoles abandonnés** : Mise à jour journal obligatoire avec raison de l'échec
  - **SCRATCHPAD** : Hors versioning (.gitignore), rétention 6 mois, suppression sur validation explicite
  - **RELEASE** : Workflow séquentiel (Rapport → CHANGELOG → version → commit atomique final)

- **Avantages Attendus :**
  - Cohérence totale avec les principes fondamentaux du CADRE-GLOBAL
  - Principe unifié simple à comprendre et appliquer
  - Automatisation flexible s'adaptant aux préférences utilisateur
  - Élimination des zones grises et des workflows ambigus
  - Meilleure traçabilité avec commits atomiques
  - Indépendance totale vis-à-vis des outils (charte fonctionnelle sans commandes aklo)

- **Inconvénients ou Risques Potentiels :**
  - Complexification temporaire pendant la transition
  - Nécessité de réviser plusieurs protocoles simultanément
  - Risque de commits plus volumineux (mais plus atomiques)
  - Courbe d'apprentissage pour les nouveaux niveaux d'automatisation
  - Responsabilité utilisateur assumée pour les configurations minimal/skeleton## 3. Plan d'Action pour l'Implémentation

- **Modifications à Apporter :**

  **1. CADRE-GLOBAL.md :**
  - Ajouter section "Principe des Commits Atomiques par Protocole"
  - Clarifier l'application du Principe 4 selon cette nouvelle logique
  - Définir les niveaux d'automatisation des commandes `aklo`
  - Préciser l'indépendance de la charte vis-à-vis des outils

  **2. JOURNAL.md :**
  - Réviser la procédure : journal intégré dans le commit du protocole en cours
  - Clarifier que chaque protocole termine par une mise à jour journal
  - Ajouter gestion des protocoles abandonnés (documentation obligatoire)
  - Supprimer les références à des commits séparés pour le journal

  **3. PLANIFICATION.md :**
  - Ajouter étape finale : validation et commit atomique (TASK + journal)
  - Définir le comportement des niveaux d'automatisation `aklo plan`
  - Clarifier que les changements de statut TASK font partie d'autres protocoles

  **4. ARCHITECTURE.md :**
  - Réviser Phase 4 : commit atomique (ARCH + TASK-modifiées + journal)
  - Ajouter validation explicite avant commit final
  - Définir les niveaux d'automatisation pour la génération d'architecture

  **5. RELEASE.md :**
  - Clarifier le workflow séquentiel avec validations multiples
  - Définir l'ordre précis : Rapport → CHANGELOG → version → commit + tag
  - Intégrer les mises à jour journal dans le processus
  - Définir le comportement de `aklo release`

  **6. SCRATCHPAD.md :**
  - Clarifier statut hors versioning (ajout automatique au .gitignore)
  - Définir procédure de rétention (6 mois minimum)
  - Ajouter procédure de suppression sur validation explicite
  - Supprimer toute référence à des commits pour les scratchpads

  **7. Tous les protocoles avec automatisation :**
  - Ajouter section "Automatisation Aklo" avec les 3 niveaux
  - Clarifier que l'automatisation respecte le principe des commits atomiques
  - Préciser que la validation humaine reste obligatoire

- **Effort d'Implémentation Estimé :** 
  Élevé - Nécessite la révision coordonnée de 6+ protocoles avec validation de cohérence globale et test des niveaux d'automatisation.

## 4. Checklist de Validation

- [ ] L'impact de cette modification sur les autres protocoles a été évalué.
- [ ] La proposition est alignée avec les principes fondamentaux de la charte (Traçabilité, Qualité, etc.).
- [ ] Les risques potentiels ont été identifiés et sont jugés acceptables.
- [ ] Le principe des commits atomiques par protocole couvre tous les cas d'usage.
- [ ] Les 3 niveaux d'automatisation sont clairement définis et cohérents.
- [ ] L'indépendance de la charte vis-à-vis des outils aklo est préservée.
- [ ] La gestion des protocoles abandonnés est définie.
- [ ] La transition depuis l'état actuel est planifiée et réalisable.
- [ ] Les cas particuliers (SCRATCHPAD, RELEASE) sont correctement traités.