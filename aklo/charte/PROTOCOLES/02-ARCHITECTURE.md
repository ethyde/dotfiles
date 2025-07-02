# PROTOCOLE SPÉCIFIQUE : CONCEPTION D'ARCHITECTURE LOGICIELLE

Ce protocole s'active sur recommandation du protocole [PLANIFICATION] pour une ou plusieurs `Tasks` identifiées comme présentant un risque ou une complexité élevés.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Analyser un problème technique complexe, évaluer plusieurs solutions, et formaliser une décision d'architecture claire et justifiée qui servira de guide pour l'implémentation.

### 1.2. Livrables Attendus

1. **Document de Conception d'Architecture :** Un fichier `ARCH-[PBI_ID]-[ID]-VALIDATED.md` détaillant la solution retenue, les compromis analysés et les justifications basées sur les principes directeurs (SoC, DDD, Twelve-Factor App…) est créé dans `/docs/backlog/02-architecture/`.
2. **Plan de `Tasks` Révisé :** La mise à jour, la suppression ou la création de `Tasks` dans `/docs/backlog/01-tasks/` pour refléter l'architecture validée. Le nouveau plan doit être immédiatement exécutable.

## SECTION 2 : ARTEFACT ARCH - GESTION ET STRUCTURE

### 2.1. Nommage

- `ARCH-[PBI_ID]-[ID]-[Status].md`
  - `[PBI_ID]` : L'ID du `PBI` parent, liant la décision au besoin métier.
  - `[ID]` : Identifiant séquentiel du document d'architecture pour ce PBI.
  - `[Status]` : Le statut du document d'architecture.

### 2.2. Statuts

- `DRAFT` : Le document est en cours de rédaction, les analyses sont en cours.
- `AWAITING_REVIEW` : La proposition d'architecture est terminée et prête à être examinée par le `Human_Developer`.
- `VALIDATED` : L'architecture a été approuvée. Elle devient la référence pour la révision des `Tasks`.
- `DEPRECATED` : L'architecture a été remplacée par une nouvelle version ou n'est plus pertinente.

### 2.3. Structure Obligatoire Du Fichier ARCH

```markdown
# ARCH-[PBI_ID]-[ID] : [Titre décrivant le problème architectural]

---

## DO NOT EDIT THIS SECTION MANUALLY
**PBI Parent:** [PBI-42-AGREED.md](../pbi/PBI-42-AGREED.md)
**Document d'Architecture:** [ARCH-42-1.md](../arch/ARCH-42-1.md)
**Assigné à:** `Human_Developer`
**Branche Git:** `feature/task-42-4-notification-service-skeleton`

---

## 1. Problème à Résoudre

_Description claire du défi technique qui a nécessité l'activation de ce protocole. Se base sur les `Tasks` "flaggées" par le planificateur._

## 2. Options Explorées et Analyse des Compromis (Trade-Offs)

### Option A : [Nom de l'approche A]

- **Description :** ...
- **Avantages :** ...
- **Inconvénients :** ...

### Option B : [Nom de l'approche B]

- **Description :** ...
- **Avantages :** ...
- **Inconvénients :** ...

## 3. Décision et Justification

_Annonce de l'option retenue et explication détaillée des raisons de ce choix, en s'appuyant sur l'analyse des compromis et les principes directeurs du projet (performance, coût, maintenabilité, etc.)._

## 4. Schéma de la Solution (Optionnel)

_Un schéma (ex: Mermaid, ASCII art) pour illustrer la solution retenue peut être inclus ici._

## 5. Impact sur les Tâches

_Description détaillée des `Tasks` à créer, modifier ou supprimer pour implémenter cette architecture._
```

## SECTION 3 : PROCÉDURE D'ARCHITECTURE

**🛫 PLAN DE VOL ARCHITECTURE (Obligatoire avant Phase 1)**

Avant l'analyse du problème architectural, l'agent **doit** présenter un plan détaillé :

**[PLAN_DE_VOL_ARCHITECTURE]**
**Objectif :** Analyser et concevoir une solution architecturale pour Tasks complexes
**Actions prévues :**
1. Analyse des Tasks flaggées comme nécessitant une revue architecturale
2. Identification du problème technique central à résoudre
3. Génération de l'ID pour le document d'architecture
4. Création du fichier `ARCH-[PBI_ID]-[ID]-DRAFT.md` dans `/docs/backlog/02-architecture/`
5. Recherche et analyse de 2-3 options architecturales viables
6. Évaluation des compromis (trade-offs) pour chaque option
7. Mise à jour des Tasks concernées après validation de l'architecture

**Fichiers affectés :**
- `/docs/backlog/02-architecture/ARCH-[PBI_ID]-[ID]-DRAFT.md` : création
- `/docs/backlog/01-tasks/TASK-[PBI_ID]-[Task_ID]-TODO.md` : modification (multiple)
- Possibles nouveaux fichiers Task selon l'architecture retenue

**Commandes système :**
- Vérification des documents d'architecture existants pour ce PBI
- Lecture des Tasks flaggées pour comprendre la complexité

**Outils MCP utilisés :**
- `mcp_desktop-commander_list_directory` : vérifier documents ARCH existants
- `mcp_desktop-commander_read_file` : lire PBI parent et Tasks flaggées
- `mcp_desktop-commander_write_file` : créer le document d'architecture
- `mcp_desktop-commander_edit_block` : mettre à jour les Tasks après validation

**Validation requise :** ✅ OUI - Attente approbation explicite avant analyse

1. **[ANALYSE] Phase 1 : Cadrage du Problème**
    - Prendre en entrée la liste des `Tasks` "flaggées".
    - Rédiger la section "Problème à Résoudre" du document d'architecture, qui sera créé au statut `DRAFT`.

2. **[ANALYSE] Phase 2 : Évaluation des Options**
    - Proposer 2 à 3 approches architecturales viables pour résoudre le problème.
    - Pour chaque option, remplir l'analyse de compromis (avantages/inconvénients) dans le document.
    - [ATTENTE_VALIDATION] Soumettre cette analyse au `Human_Developer` pour choisir une direction et obtenir des clarifications : poser 4 à 6 questions de clarification pour affiner les contraintes.

3. **[PROCEDURE] Phase 3 : Prise de Décision et Formalisation**
    - Sur la base de la direction choisie par le `Human_Developer`, rédiger la conception détaillée de la solution retenue dans le document d'architecture.
    - Rédiger les sections "Décision et Justification" et "Impact sur les Tâches".
    - Passer le statut du document à `AWAITING_REVIEW` et le soumettre pour validation finale.
    - [ATTENTE_VALIDATION] Soumettre le document de conception complet pour approbation finale.

4. **[CONCLUSION] Phase 4 : Mise à Jour du Plan d'Action**
    - Présenter le **Plan de `Tasks` Révisé** au `Human_Developer` pour validation.
    - Une fois le document `VALIDATED`, exécuter le plan décrit dans la section "Impact sur les Tâches".
    - Activer le protocole [KNOWLEDGE-BASE] pour déterminer si l'analyse a produit une connaissance qui mérite d'être centralisée.
    - Modifier, supprimer et créer les fichiers `TASK` dans `/docs/backlog/01-tasks/`.
