---
created: 2025-06-28 12:57
modified: 2025-06-28 13:00
---
# PROTOCOLE SPÉCIFIQUE : SCRATCHPAD (BROUILLON DE RÉFLEXION)

Ce protocole s'active pour les explorations temporaires qui nécessitent une phase de brainstorming ou de pseudo-codage, en restant complètement hors du système de versioning.

## SECTION 1 : MISSION ET STATUT HORS VERSIONING

### 1.1. Mission

Fournir un espace de travail temporaire et non structuré pour explorer des solutions, comparer des approches et clarifier des idées complexes avant de les formaliser dans un artefact officiel (`Task`, `ARCH`, etc.).

### 1.2. Statut Hors Versioning

**Principe Fondamental :** Les scratchpads sont **exclus du versioning Git** pour éviter la pollution du dépôt avec des fichiers temporaires.

**Implémentation :**
- Ajout automatique au `.gitignore` : `docs/backlog/16-scratchpads/`
- Aucun commit ne doit inclure des fichiers scratchpad
- Stockage local uniquement pendant la durée d'exploration

### 1.3. Livrable

**Fichier Brouillon Temporaire :** Un fichier `SCRATCHPAD-[ID].md` créé dans `/docs/backlog/16-scratchpads/`, considéré comme jetable et non versionné.

## SECTION 2 : ARTEFACT SCRATCHPAD - GESTION ET STRUCTURE

### 2.1. Nommage

-   `SCRATCHPAD-[ID].md`
    -   `[ID]` : Un identifiant unique généré à partir du titre et de la date (ex: `description-du-sujet-20250629`).

### 2.2. Statuts et Cycle de Vie

-   `ACTIVE` : Le brouillon est en cours d'utilisation pour une réflexion active.
-   `ARCHIVED` : La réflexion a abouti à une solution formalisée dans un autre artefact. Le brouillon est conservé pour référence historique.
-   `DISCARDED` : L'exploration n'a pas abouti ou n'est plus pertinente.

### 2.3. Gestion de la Rétention

**Règles de rétention :**
- **Durée minimale :** 6 mois de conservation obligatoire
- **Suppression :** Uniquement sur validation explicite du `Human_Developer`
- **Nettoyage automatique :** Aucun - la suppression est toujours manuelle
- **Archivage :** Possibilité de déplacer vers un dossier d'archive local (hors Git)

### 2.3. Structure Recommandée (Flexible)

Un `Scratchpad` est libre par nature. La structure suivante est une suggestion, pas une obligation.

```markdown
# SCRATCHPAD : [ID]
---
**Responsable:** [Nom du Human_Developer / AI_Agent]
**Statut:** [ACTIVE | ARCHIVED | DISCARDED]
**Contexte:** Exploration pour la [TASK-XX] / Réflexion du [JOURNAL-AAAA-MM-DD]
---

## 1. Problème à Résoudre

*Reformulation du problème avec mes propres mots pour m'assurer que je l'ai bien compris.*

## 2. Brainstorming / Exploration

*(Contenu libre : listes à puces, pseudo-code, schémas en ASCII, comparaison d'options, etc.)*

### Approche A : ...
- **Avantages :** ...
- **Inconvénients :** ...

### Approche B : ...
- **Avantages :** ...
- **Inconvénients :** ...

## 3. Conclusion de l'Exploration

*Quelle est la solution retenue suite à cette réflexion ? Quelle est la prochaine étape concrète ?*
- **Décision :** L'approche B est la plus prometteuse.
- **Action Suivante :** Mettre à jour la [TASK-XX] avec un plan d'action détaillé basé sur cette approche.
````

## SECTION 3 : PROCÉDURE D'UTILISATION DU SCRATCHPAD

1.  **[PROCEDURE] Phase 1 : Initialisation**
      - Lorsqu'une `Task` ou une réflexion dans le [JOURNAL] s'avère complexe
      - **Action Requise :** Créer un nouveau fichier `SCRATCHPAD-[ID]-ACTIVE.md` dans `/docs/backlog/16-scratchpads/`.
      - **⚡ Automatisation `aklo` :** `aklo new scratchpad "<Titre de la dépréciation>"`
      - Créer une entrée dans le [JOURNAL] pour indiquer le début de l'exploration et lier le `Scratchpad`.
      - Remplir l'en-tête du `Scratchpad` et la section "Problème à Résoudre".

2.  **[PROCEDURE] Phase 2 : Exploration Libre**
      - Utiliser le fichier comme un espace de travail pour itérer sur des idées, du pseudo-code, et des analyses comparatives. Le contenu est libre et doit servir la réflexion.

3.  **[CONCLUSION] Phase 3 : Clôture**
      - Une fois qu'une solution claire émerge de l'exploration, la documenter dans la "Conclusion de l'Exploration".
      - **Formaliser le résultat :** Mettre à jour la `Task` concernée, créer un nouveau document [ARCHITECTURE], ou toute autre action formelle nécessaire.
      - Créer une entrée dans le [JOURNAL] pour résumer la décision et lier la conclusion du `Scratchpad`.
      - Passer le statut du `Scratchpad` à `ARCHIVED` ou, avec l'accord du `Human_Developer`, à `DISCARDED`.
