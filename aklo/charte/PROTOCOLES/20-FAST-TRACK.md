---
created: 2025-06-28 14:14
modified: 2025-06-28 14:22
---
# PROTOCOLE SPÉCIFIQUE : FAST-TRACK (PROCÉDURE ACCÉLÉRÉE)

Ce protocole s'active à la discrétion du `Human_Developer` pour des modifications mineures, à faible risque, qui ne justifient pas le cycle complet `PBI -> TASK`.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Implémenter rapidement une modification mineure (ex: correction de faute de frappe, ajustement de style CSS, modification de configuration) tout en conservant une traçabilité complète.

### 1.2. Livrables Attendus

1.  **Artefact Fast-Track :** Un unique fichier `FAST-[ID].md` créé dans `/docs/backlog/17-fast-track/`.
2.  **Commit de Correction :** Un unique `commit` sémantique directement lié à l'artefact Fast-Track.

## SECTION 2 : ARTEFACT FAST-TRACK - GESTION ET STRUCTURE

### 2.1. Nommage

-   `FAST-[ID]-[Status].md`
    -   `[ID]` : Un identifiant unique généré à partir du titre et de la date (ex: `description-du-sujet-20250629`).
    -   `[Status]` : Le statut de la tâche.

### 2.2. Statuts

-   `TODO` : La tâche est définie et prête à être exécutée.
-   `DONE` : Le `diff` a été validé et le `commit` a été créé.

### 2.3. Structure Obligatoire du Fichier Fast-Track

````markdown
# RAPPORT FAST-TRACK : [ID]
---
**Responsable:** [Nom du Human_Developer]
**Statut:** [TODO | DONE]
**Commit Associé:** [Sera rempli à la fin avec le hash du commit]
---

## 1. Contexte et Justification

- **Origine de la demande :** (Ex: "Ticket utilisateur #512", "Observation lors de la revue du PBI-42", "Demande orale pour une démo")
- **Justification du Fast-Track :** (Pourquoi ce n'est pas une `Task` normale ? Ex: "Correction de texte sans impact sur la logique métier", "Ajustement de style visuel uniquement")

## 2. Description du Changement

*Description claire et concise de la modification à effectuer. Qu'est-ce qui doit être changé et quel est le résultat attendu ?*

## 3. Plan d'Action et Diff Proposé

*Diff complet de la solution proposée. Doit inclure tous les changements de code.*

```diff
--- a/src/components/Header.js
+++ b/src/components/Header.js
@@ -10,7 +10,7 @@
 function Header() {
   return (
     <header>
-      <h1>Bienvenue sur notre sit</h1>
+      <h1>Bienvenue sur notre site</h1>
     </header>
   );
 }
```

## 4. Checklist de Validation Minimale

  - [ ] Le changement a été testé manuellement dans un environnement de développement.
  - [ ] Le changement n'introduit aucune erreur de linter ou de compilation.
  - [ ] (Si applicable) Le test de non-régression le plus pertinent a été exécuté avec succès.
````

## SECTION 3 : PROCÉDURE FAST-TRACK

1.  **[PROCEDURE] Phase 1 : Initialisation par le Human\_Developer**
      - **Action Requise :**  Créer un fichier `FAST-[ID]-TODO.md` dans `/docs/backlog/17-fast-track/`.
      - **⚡ Automatisation `aklo` :** `aklo fast "<Titre de la tâche>"`
      - Remplir la section "Description du Besoin".
      - Créer une branche de travail (ex: `fast/fix-typo-homepage`).

2.  **[PROCEDURE] Phase 2 : Implémentation par l'AI\_Agent**

      - Implémenter la correction demandée.
      - Remplir la section "Plan d'Action et Diff Proposé" avec le `diff` complet des modifications.

3.  **[ATTENTE\_VALIDATION] Phase 3 : Validation**

      - Soumettre l'artefact `FAST-[ID]-TODO.md` complété pour validation au `Human_Developer`.

4.  **[CONCLUSION] Phase 4 : Finalisation**

      - Une fois le `diff` approuvé, le `Human_Developer` ou l'`AI_Agent` via un outil (`The Aklo Protocol`) crée le `commit` sémantique (ex: `fix(ui): correct typo in homepage title`).
      - Mettre à jour le statut de l'artefact à `DONE`.
      - Fusionner la branche.
