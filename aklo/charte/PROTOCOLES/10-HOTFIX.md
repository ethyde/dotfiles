---
created: 2025-06-28 10:15
modified: 2025-06-28 11:17
---
# PROTOCOLE SPÉCIFIQUE : GESTION DE HOTFIX (CORRECTION D'URGENCE)

Ce protocole s'active **uniquement** pour corriger un bug critique en production qui bloque les utilisateurs ou cause une perte de revenus immédiate. Il court-circuite le flux de travail standard pour une rapidité maximale.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Restaurer le service en production le plus rapidement possible en appliquant un correctif minimaliste et ciblé, tout en documentant la procédure pour assurer la traçabilité.

### 1.2. Livrables Attendus

1.  **Rapport de Hotfix :** Un fichier `HOTFIX-[ID].md` créé dans `/docs/backlog/08-hotfixes/`, documentant le problème et la solution.
2.  **Commit de Hotfix :** Un `commit` contenant **uniquement** la correction minimale.
3.  **Tag Git de Patch :** Un nouveau tag de version de patch (ex: `v1.2.1`).

## SECTION 2 : ARTEFACT HOTFIX - GESTION ET STRUCTURE

### 2.1. Nommage

-   `HOTFIX-[ID].md`
    -   `[ID]` : Un identifiant unique pour le hotfix (ex: `bug-login-prod-20250628`).

### 2.2. Statuts

-   `INVESTIGATING` : L'analyse de la cause racine est en cours.
-   `AWAITING_FIX` : Le diagnostic est posé et un plan de correction attend la validation du `Human_Developer`.
-   `DEPLOYING` : Le correctif a été validé, buildé, et est en cours de déploiement.
-   `RESOLVED` : Le hotfix est en production, et les actions de suivi (post-mortem) sont planifiées.

### 2.3. Structure Obligatoire du Fichier Hotfix

```markdown
# RAPPORT DE HOTFIX : [ID]

---
**Responsable:** [Nom du Human_Developer]
**Statut:** [INVESTIGATING | AWAITING_FIX | DEPLOYING | RESOLVED]
**Date de Détection:** AAAA-MM-JJ HH:MM
**Version Affectée:** vX.X.X
**Impact Critique:** [Description concise de l'impact métier. Ex: "Les nouveaux utilisateurs ne peuvent pas s'inscrire", "Le panier d'achat est inaccessible"]
---

## 1. Problème Critique

*Description du bug, son impact sur les utilisateurs/revenus, et la preuve de son existence en production.*

## 2. Analyse de Cause Racine (Rapide)

*Diagnostic rapide pour identifier la source immédiate du problème.*

## 3. Solution de Contournement Minimale Appliquée

*Description du changement de code minimaliste appliqué. Il faut ici justifier pourquoi c'est la plus petite modification possible pour résoudre le problème.*

## 4. Plan de Post-Mortem

- [ ] Un `PBI` ou une `Task` de `DEBOGAGE` a été créé pour analyser la cause racine en profondeur et appliquer une solution définitive.
- [ ] Le correctif du hotfix a été reporté sur la branche de développement principale.
```

## SECTION 3 : PROCÉDURE DE HOTFIX

1.  **[ANALYSE] Phase 1 : Lecture de la Configuration et Validation de l'Urgence**
      - Lire et charger les conventions depuis `CONFIG-PROJET.md`.
      - **[ATTENTE\_VALIDATION]** Confirmer avec le `Human_Developer` que la situation justifie bien un `HOTFIX` et non un cycle de [DEBOGAGE] normal.

2.  **[PROCEDURE] Phase 2 : Création de la Branche d'Urgence**
      - **Action Requise :** 
            - Créer un fichier `HOTFIX-[ID].md`.
            - Identifier le tag de la version actuellement en production.
            - Créer une branche de hotfix (ex: `hotfix/fix-login-bug`) directement depuis ce **tag de production**.
      - **⚡ Automatisation `aklo` :** `aklo hotfix "<description du bug>"`

3.  **[PROCEDURE] Phase 3 : Correction Minimale**
      - **Activer le protocole [DEVELOPPEMENT]** avec une contrainte stricte : le changement de code doit être le plus petit et le plus ciblé possible. **Aucun refactoring ou amélioration n'est autorisé.**
      - L'objectif est de faire passer les tests les plus critiques et de valider manuellement que le bug a disparu.

4.  **[ATTENTE\_VALIDATION] Phase 4 : Validation du Correctif**
      - Soumettre le `diff` minimaliste pour approbation au `Human_Developer`. C'est une validation critique.

5.  **[PROCEDURE] Phase 5 : Déploiement d'Urgence et Planification du Suivi**
      - **Action Requise :** 
            -   Une fois le correctif validé, fusionner la branche de hotfix directement dans la **Branche de production**.
            -   Créer un nouveau **tag de patch** sur cette branche.
            -   Lancer le build et déployer cette nouvelle version patchée immédiatement.
            -   **Immédiatement après la confirmation du déploiement réussi**, remplir la section "Plan de Post-Mortem" dans le rapport `HOTFIX-[ID].md`. Cela implique de créer une nouvelle `Task` ou un nouveau `PBI` pour la correction définitive via le protocole [DEBOGAGE].
      - **⚡ Automatisation `aklo` :** `aklo hotfix publish`

6.  **[CONCLUSION] Phase 6 : Synchronisation et Clôture**
    -   Après le déploiement et la planification du suivi, fusionner la **Branche de production** dans la **Branche de développement principale** pour s'assurer que le correctif est bien présent pour les futurs développements.
    -   Informer le `Human_Developer` que :
        1. La production est stabilisée.
        2. La procédure de suivi (post-mortem) a été créée et est traçable via le rapport de hotfix.
