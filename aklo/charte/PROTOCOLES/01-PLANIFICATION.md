---
created: 2025-06-27 15:23
modified: 2025-06-28 14:45
---

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
