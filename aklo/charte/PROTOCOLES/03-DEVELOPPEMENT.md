---
created: 2025-06-27 15:33
modified: 2025-06-28 12:30
---

# PROTOCOLE SPÉCIFIQUE : DÉVELOPPEMENT ET IMPLÉMENTATION

Ce protocole s'active pour chaque `Task` individuelle (`Status = TODO`). Il régit la manière dont le code est écrit, testé et documenté. C'est la source de vérité unique pour toutes les normes de qualité du code.

## SECTION 1 : MISSION ET LIVRABLE

### 1.1. Mission

Implémenter le code d'une `Task` de manière propre, robuste et testable, en respectant un cycle de développement itératif et en adhérant strictement aux normes de qualité. **Note :** Ce protocole est le moteur d'exécution principal, activé par [PLANIFICATION] pour les nouvelles fonctionnalités, mais aussi par [DEBOGAGE], [REFACTORING], [OPTIMISATION] et [HOTFIX] pour leurs besoins d'implémentation respectifs.

### 1.2. Livrable Attendu

- Un unique `commit` sémantique et atomique sur la branche `feature/task-[PBI_ID]-[Task_ID]`. Ce `commit` n'est créé **qu'après validation explicite** du `diff` par le `Human_Developer`.

## SECTION 2 : RÈGLES DE QUALITÉ DU CODE (NON-NÉGOCIABLES)

Toutes les règles suivantes doivent être respectées.

### 2.1. Respect Des Principes S.O.L.I.D.

- **(S) Responsabilité Unique :** Chaque fonction, classe ou module ne doit avoir qu'une seule raison de changer.
- **(O) Ouvert/Fermé :** Les entités doivent être ouvertes à l'extension, mais fermées à la modification.
- **(L) Substitution de Liskov :** Les sous-classes doivent être substituables à leurs classes de base.
- **(I) Ségrégation des Interfaces :** Privilégier les interfaces petites et spécifiques au besoin.
- **(D) Inversion des Dépendances :** Dépendre d'abstractions, pas d'implémentations concrètes.

### 2.2. Qualité Et Propreté Du Code

- **Typage Strict et Explicite (TypeScript) :** Le typage strict doit être rigoureusement appliqué. Aucune utilisation de `any` n'est tolérée.
- **Conformité au Linter :** Le code doit être parfaitement conforme aux règles de `linting` configurées dans le projet. Aucune erreur de linter ne doit subsister.
- **Limites de Longueur :**
    - **Fichiers :** Ne doivent idéalement pas dépasser **300 lignes**.
    - **Fonctions :** Ne doivent idéalement pas dépasser **25 lignes**.
- **Code Complet et Intégral :** Toujours écrire le code complet pour un fichier. Pas d'extraits, de commentaires de substitution (`// …`) ou de blocs multiples pour un même fichier.

### 2.3. Documentation Systématique

- **Format JSDoc/TSDoc :** Chaque fonction, méthode, classe, type ou interface exporté doit être précédé d'un bloc de commentaires complet.
- **Contenu :** La documentation doit expliquer le **rôle** de l'élément (`@description`), chaque **paramètre** (`@param`) et la **valeur de retour** (`@returns`).

## SECTION 3 : PROCÉDURE D'IMPLÉMENTATION (CYCLE TDD)

L'implémentation de toute fonctionnalité doit suivre ce micro-cycle itératif.

**Prérequis : Préparation de l'environnement**
    - **Action Requise :** Avant de commencer, créer une branche Git qui respecte le format défini dans l'en-tête de la `TASK`, puis renommer le fichier de l'artefact `TASK` pour changer son statut de `TODO` à `IN_PROGRESS`.
    - **⚡ Automatisation `aklo` :** `aklo start-task [ID_de_la_tache]`

1. **[PROCEDURE] Étape 1 : Écrire un Test qui Échoue (Rouge)**
    - Identifier une petite partie de la fonctionnalité requise par la `Task`.
    - Écrire un unique test unitaire qui décrit ce comportement.
    - Exécuter le test et s'assurer qu'il échoue (`RED`).

2. **[PROCEDURE] Étape 2 : Écrire le Code Minimum pour Réussir (Vert)**
    - Écrire le **strict minimum** de code de production nécessaire pour que le test précédent passe (`GREEN`).
    - À ce stade, l'élégance du code est secondaire. L'objectif est uniquement la fonctionnalité.
    - Relancer le test pour confirmer qu'il passe.

3. **[PROCEDURE] Étape 3 : Refactoriser et Valider la Qualité (Bleu)**
    - Maintenant que le comportement est sécurisé par un test, exécuter la checklist de qualité suivante :
        1. **Refactoriser le code :** Améliorer la structure (clarté, renommage, application des principes SOLID de la Section 2).
        2. **Valider le Linter :** Lancer l'outil de `linting` et corriger **toutes** les erreurs et tous les avertissements.
        3. **Valider le Typage :** Lancer le vérificateur de types (ex: `tsc --noEmit`) et corriger **toutes** les erreurs de typage.
        4. **Valider la Non-Régression :** Relancer **toute la suite de tests** pour s'assurer que les refactorisations et corrections n'ont rien cassé.
4. **[PROGRESSION] Étape 4 : Itérer ou Finaliser**
    - Si la `Task` n'est pas terminée, retourner à l'étape 1 pour la partie suivante de la fonctionnalité.
    - Si la `Task` est terminée, passer à l'étape de finalisation.

5. **[PROCEDURE] Étape 5 : Validation de la "Definition of Done"**
    - Avant de soumettre le travail pour revue, ouvrir le fichier de la `Task` en relation.
    - Valider et cocher (`[x]`) un par un **tous les points** de la checklist "Definition of Done".
    - Si un point ne peut pas être coché, le travail n'est pas terminé. Retourner aux étapes précédentes.

6. **[ATTENTE_VALIDATION] Étape 6 : Revue Avant Commit**
    - **Action Requise :**
        - Une fois la "Definition of Done" entièrement validée, préparer un `diff` complet de toutes les modifications.
        - Présenter ce `diff` au `Human_Developer` pour une revue finale.
        - Mettre à jour le statut de la `TASK` à `AWAITING_REVIEW`
    - **⚡ Automatisation `aklo` :** `aklo submit-task`
    - **Note :** La commande `aklo` vous demandera de confirmer le message de commit avant de l'exécuter.

7. **[CONCLUSION] Étape 7 : Finalisation**
    - Mettre à jour le statut de la `Task` à `DONE`.
    - Une fois le `diff` approuvé, créer le `commit` atomique et sémantique.
