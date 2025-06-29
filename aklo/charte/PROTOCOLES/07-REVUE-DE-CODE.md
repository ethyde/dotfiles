---
created: 2025-06-27 15:39
modified: 2025-06-27 18:13
---

# PROTOCOLE SPÉCIFIQUE : REVUE DE CODE ASSISTÉE

Ce protocole s'active à la demande du `Human_Developer` pour analyser de manière critique un `diff` de code, typiquement celui présenté lors de l'étape [ATTENTE_VALIDATION] du protocole [DEVELOPPEMENT].

## SECTION 1 : MISSION ET LIVRABLE

### 1.1. Mission

Agir en tant que relecteur de code assistant pour fournir un premier niveau de feedback structuré, en vérifiant la conformité du code avec les normes de la Charte et en identifiant les améliorations potentielles.

### 1.2. Livrable Attendu

- Un unique rapport `REVIEW-[ID].md` créé dans le répertoire `/docs/backlog/03-reviews/`. L'`ID` peut correspondre à celui de la `Task` ou de la PR si elle existe.

## SECTION 2 : ARTEFACT REVIEW - GESTION ET STRUCTURE

### 2.1. Nommage

- `REVIEW-[ID].md`
    - `[ID]` : Un identifiant unique pour la revue (ex: `task-42-1`).

### 2.2. Structure Obligatoire Du Fichier Review

```markdown
# RAPPORT DE REVUE DE CODE : REVIEW-[ID]
---
**Task / Diff concerné:** [Lien vers la Task ou description du diff]
---

## 1. Checklist de Conformité

- **[ ] Respect total du protocole `03-DEVELOPPEMENT.md` :** Oui / Non
- **[ ] Principes S.O.L.I.D. respectés :** Oui / Partiellement / Non
- **[ ] Qualité (Typage, Linting) parfaite :** Oui / Non
- **[ ] Clarté et Lisibilité :** Bonne / Moyenne / Faible
- **[ ] Documentation (JSDoc) complète :** Oui / Partielle / Manquante
- **[ ] Couverture de Tests suffisante :** Oui / Non

## 2. Observations et Suggestions

### [CRITICAL] - Doit être corrigé avant la fusion
- *(Aucun)*

### [MAJOR] - Fortement recommandé de corriger
- **Fichier `src/utils/auth.ts`, Ligne 42 :** La fonction `generateToken` ne gère pas le cas où l'objet `user` est `null`, ce qui pourrait lever une exception non contrôlée.

### [MINOR] - Suggestion d'amélioration
- **Fichier `src/components/Button.tsx`, Ligne 15 :** Le nom de la variable `d` pourrait être renommé en `data` pour plus de clarté.
```

## SECTION 3 : PROCÉDURE DE REVUE

1. **[ANALYSE] Phase 1 : Prise de Contexte**
      - Prendre en entrée le `diff` de code à analyser.
      - Lire la `Task` associée pour comprendre l'objectif métier et technique du changement.

2. **[PROCEDURE] Phase 2 : Évaluation Systématique**
      - Analyser l'ensemble du code modifié (`diff`).
      - Remplir méthodiquement la **Section 1 (Checklist)** du rapport en se référant explicitement aux règles du protocole `03-DEVELOPPEMENT.md`.
      - Remplir la **Section 2 (Observations)** en classant chaque point par niveau de criticité. Chaque observation doit inclure une référence précise au fichier et à la ligne concernée.

3. **[CONCLUSION] Phase 3 : Production du Rapport**
      - Créer et finaliser le rapport `REVIEW-[ID].md` dans `/docs/backlog/03-reviews/`.
      - Présenter le rapport complété au `Human_Developer`.
      - **Étape Suivante :** Une fois la revue de code approuvée par le `Human_Developer`, la tâche est prête à être fusionnée.
        - **Action Requise :** Fusionner la branche de la tâche dans la branche principale, supprimer la branche de tâche, et mettre à jour le statut de l'artefact `TASK` à `DONE`.
        - **⚡ Automatisation `aklo` :** `aklo merge-task <ID_de_la_tache>`
      - **Note :** La mission de ce protocole se termine ici. Il n'y a pas d'étape [ATTENTE_VALIDATION] car l'action attendue est celle du `Human_Developer` sur la base de ce rapport.
