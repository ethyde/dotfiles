# PROTOCOLE SPÉCIFIQUE : PLANIFICATION ET DÉCOMPOSITION

Ce protocole s'active après la validation d'un `PBI` (`Status = AGREED`). Il a pour mission de transformer l'exigence fonctionnelle en un plan d'action technique initial.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Décomposer une exigence (`PBI`, plan de correction, etc.) en `Tasks` techniques, atomiques et logiques. 
**Note :** Ce protocole est le plus souvent activé par [PRODUCT OWNER], mais aussi par [DEPRECATION], [SECURITE-AUDIT] ou tout autre protocole nécessitant un plan d'action technique détaillé.

### 1.2. Livrables Attendus

1. **Artefacts de Tâches :** Un ou plusieurs fichiers `TASK-[PBI_ID]-[Task_ID]-TODO.md` créés dans le répertoire `/docs/backlog/01-tasks/`.
2. **Rapport de Planification :** Un message de `[CONCLUSION]` pour le `Human_Developer` qui résume le plan, liste les `Tasks` créées et identifie explicitement celles recommandées pour une revue architecturale.

## SECTION 2 : ARTEFACT TASK - GESTION ET STRUCTURE

### 2.1. Nommage

- `TASK-[PBI_ID]-[Task_ID]-[Status].md`
  - `[PBI_ID]` : L'ID du `PBI` parent, assurant la traçabilité.
  - `[Task_ID]` : Identifiant séquentiel de la tâche dans le scope du `PBI`.
  - `[Status]` : Le statut de la tâche dans son cycle de vie.

### 2.2. Statuts

- `TODO` : Prête à être prise en charge.
- `IN_PROGRESS` : Prise en charge par un `Human_Developer` pour exécution.
- `AWAITING_REVIEW` : Développement terminé, `diff` en attente de validation par le `Human_Developer`.
- `DONE` : Le `commit` a été effectué.
- `MERGED` : La branche a été fusionnée dans la branche principale.

### 2.3. Structure Obligatoire Du Fichier Task

```markdown
# TASK-[PBI_ID]-[Task_ID] : [Titre technique de la tâche]

---

## DO NOT EDIT THIS SECTION MANUALLY

**PBI Parent:** [PBI-[PBI_ID]](path/to/pbi)
**Revue Architecturale Requise:** [Oui / Non]
**Document d'Architecture (si applicable):** [ARCH-[PBI_ID]-1.md](../arch/ARCH-PBI_ID-1.md)
**Assigné à:** `[Nom du Human_Developer]`
**Branche Git:** `feature/task-[PBI_ID]-[Task_ID]`

---

## 1. Objectif Technique

_Description claire et sans ambiguïté du travail à réaliser, des fichiers à modifier/créer et du résultat attendu._

## 2. Contexte et Fichiers Pertinents

_Section cruciale pour l'IA. Contient les extraits de code, les chemins de fichiers, les structures de données et toute information nécessaire pour la réalisation de la tâche._

## 3. Instructions Détaillées pour l'AI_Agent (Prompt)

_Liste séquentielle et précise des actions que le protocole [DEVELOPPEMENT] devra exécuter. Chaque instruction doit être petite et vérifiable._

1.  **Instruction 1...**
2.  **Instruction 2...**

## 4. Définition de "Terminé" (Definition of Done)

- [ ] Le code est implémenté conformément aux instructions.
- [ ] Le code respecte la `PEP 8`.
- [ ] Les tests unitaires sont écrits et passent avec succès.
- [ ] La documentation (docstring) est complète.
- [ ] Le code a été revu et approuvé.
```

## SECTION 3 : PROCÉDURE DE PLANIFICATION

1. **[ANALYSE] Phase 1 : Appropriation du PBI**
   - Prendre en entrée un `PBI` avec le statut `AGREED`.
   - Analyser en profondeur les critères d'acceptation et les contraintes. Poser des questions de clarification au `Human_Developer` si nécessaire.

**🛫 PLAN DE VOL PLANIFICATION (Obligatoire avant Phase 2)**

Avant la décomposition et création des Tasks, l'agent **doit** présenter un plan détaillé :

**[PLAN_DE_VOL_PLANIFICATION]**
**Objectif :** Décomposer un PBI en Tasks techniques atomiques et traçables
**Actions prévues :**
1. Analyse approfondie du PBI parent et de ses critères d'acceptation
2. Identification des composants techniques à modifier/créer
3. Décomposition en Tasks SMART (Spécifique, Mesurable, Atteignable, Réaliste, Temporellement défini)
4. Génération des IDs séquentiels pour chaque Task du PBI
5. Création des fichiers `TASK-[PBI_ID]-[Task_ID]-TODO.md` dans `/docs/backlog/01-tasks/`
6. Évaluation du besoin de revue architecturale pour chaque Task

**Fichiers affectés :**
- `/docs/backlog/01-tasks/TASK-[PBI_ID]-[Task_ID]-TODO.md` : création (multiple)
- `/docs/backlog/00-pbi/PBI-[PBI_ID]-AGREED.md` : mise à jour section "Tasks Associées"

**Commandes système :**
- `aklo plan [PBI_ID]` : automatisation de planification (optionnel)
- Vérification des IDs Task existants pour ce PBI

**Outils MCP utilisés :**
- `mcp_desktop-commander_list_directory` : vérifier Tasks existantes
- `mcp_desktop-commander_read_file` : lire le PBI parent
- `mcp_desktop-commander_write_file` : créer les fichiers Task
- `mcp_aklo-terminal_aklo_execute` : commande aklo (si utilisée)

**Validation requise :** ✅ OUI - Attente approbation explicite avant création

2. **[PROCEDURE] Phase 2 : Décomposition en Tâches**
   - Décomposer le `PBI` en une liste de `Tasks` techniques. Chaque `Task` doit être petite, indépendante et testable par rapport aux critères **SMART** :
     - **S - Spécifique :** L'objectif de la `Task` doit être clair et sans ambiguïté. On doit savoir exactement ce qui doit être fait.
     - **M - Mesurable :** Il doit y avoir un ou plusieurs critères objectifs (la "Definition of Done") pour savoir quand la `Task` est terminée.
     - **A - Atteignable (Achievable) :** La `Task` doit être réalisable avec les compétences et les ressources disponibles.
     - **R - Réaliste (Relevant) :** La `Task` doit contribuer directement à l'accomplissement du `PBI` parent. Elle ne doit pas inclure de travail non pertinent.
     - **T - Temporellement défini (Time-boxed) :** Bien que nous n'assignions pas de durée stricte, la `Task` doit être suffisamment petite pour être considérée comme une unité de travail gérable et ne pas s'étaler indéfiniment.
   - **Action Requise :** Pour chaque `Task` identifiée, créer manuellement le fichier `TASK-[…]-TODO.md` correspondant dans `/docs/backlog/01-tasks/`.
   - **⚡ Automatisation `aklo` :** La commande `aklo plan <PBI_ID>` est prévue pour automatiser cette étape.

3. **[ANALYSE] Phase 3 : Triage et Identification des Risques (Aiguillage)**
   - Pour chaque `Task` créée, évaluer sa complexité et son impact.
   - **Identifier formellement** toute `Task` qui présente un risque architectural (ex: touche à la sécurité, introduit un nouveau pattern, forte contrainte de performance).
   - Si une `Task` présente un risque architectural (ex: touche à la sécurité, introduit un nouveau pattern, forte contrainte de performance), **mettre la valeur du champ `Revue Architecturale Requise` à `Oui`** dans le fichier de la `Task`. Pour les autres, mettre `Non`.

4. **[CONCLUSION] Phase 4 : Présentation du Plan**
   - Préparer le **Rapport de Planification** qui liste toutes les `Tasks` créées et met en évidence celles qui requièrent une revue architecturale.
   - [ATTENTE_VALIDATION] Soumettre ce rapport au `Human_Developer` avec une recommandation claire :
     - **Cas 1 (Trivial) :** Si la demande initiale est mineure et ne justifie pas une `Task`, recommander d'utiliser le protocole [FAST-TRACK].
     - **Cas 2 (Simple) :** Si aucune `Task` ne requiert de revue, recommander de passer directement au protocole [DEVELOPPEMENT].
     - **Cas 3 (Complexe) :** Si des `Tasks` requièrent une revue, recommander d'activer le protocole [ARCHITECTURE].

## SECTION 4 : COMMIT ATOMIQUE DE PLANIFICATION

### 4.1. Principe du Commit Unique

**Règle Fondamentale :** La planification d'un PBI produit un unique commit atomique qui inclut :

1. **Toutes les TASK créées** : Tous les fichiers `TASK-[PBI_ID]-[Task_ID]-TODO.md`
2. **Mise à jour du PBI parent** : Section "Tasks Associées" complétée
3. **Mise à jour du journal** : Documentation du processus de planification

### 4.2. Contenu du Commit

**Message de commit type :**
```
feat(planning): Décomposition PBI-[ID] en [N] tasks

- Création de [N] tasks techniques SMART
- [X] tasks nécessitent une revue architecturale
- PBI-[ID] mis à jour avec la liste des tasks associées
- Journal mis à jour avec le processus de planification

Tasks créées:
- TASK-[PBI_ID]-01: [Titre]
- TASK-[PBI_ID]-02: [Titre]
- [...]

Prochaine étape: [ARCHITECTURE|DEVELOPPEMENT|FAST-TRACK]
```

### 4.3. Validation Avant Commit

**[ATTENTE_VALIDATION] Présentation du Diff Complet**

Avant le commit, présenter au `Human_Developer` :
1. **Diff de tous les fichiers TASK** créés
2. **Diff du PBI parent** modifié
3. **Diff du journal** mis à jour
4. **Recommandation** pour la suite du workflow

**Validation requise :** Le `Human_Developer` doit approuver explicitement le commit atomique complet.

### 4.4. Gestion des Modifications Post-Planification

**Règle :** Les modifications ultérieures des TASK (changements de statut, mises à jour de contenu) font partie d'autres protocoles et génèrent leurs propres commits atomiques.

**Exemples :**
- Changement `TASK-TODO` → `TASK-DONE` : commit du protocole DÉVELOPPEMENT
- Modification des critères d'une TASK : commit du protocole META-IMPROVEMENT
- Ajout de TASK supplémentaires : nouveau cycle de protocole PLANIFICATION
