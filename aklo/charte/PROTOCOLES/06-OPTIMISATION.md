---
created: 2025-06-27 15:57
modified: 2025-06-28 14:43
---

# PROTOCOLE SPÉCIFIQUE : OPTIMISATION DE PERFORMANCE

Ce protocole s'active lorsqu'une fonctionnalité ne respecte pas ses exigences de performance (temps de réponse, consommation mémoire/CPU). La règle d'or est : **Mesurer d'abord, optimiser ensuite.**

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Identifier scientifiquement les goulets d'étranglement de performance, implémenter une solution ciblée, et prouver son efficacité par des mesures comparatives.

### 1.2. Livrables Attendus

1. **Rapport d'Optimisation :** Un fichier `OPTIM-[ID]-DONE.md` complet, créé dans `/docs/backlog/06-optim/`.
2. **Commit d'Optimisation :** Un `commit` contenant le code optimisé.

## SECTION 2 : ARTEFACT OPTIM - GESTION ET STRUCTURE

### 2.1. Nommage

- `OPTIM-[ID]-[Status].md`
    - `[ID]` : Un identifiant unique généré à partir du titre et de la date (ex: `description-du-sujet-20250629`).
    - `[Status]` : Le statut du processus d'optimisation.

### 2.2. Statuts

- `BENCHMARKING` : L'analyse initiale et la mesure de performance sont en cours.
- `AWAITING_FIX` : Le goulet d'étranglement est identifié et une solution attend la validation du `Human_Developer`.
- `DONE` : L'optimisation a été implémentée, validée par une nouvelle mesure, et le `commit` a été créé.

### 2.3. Structure Obligatoire Du Fichier Optim

```markdown
# RAPPORT D'OPTIMISATION : OPTIM-[ID]
---
**Task Associée (si applicable):** [TASK-ID](../../01-tasks/TASK-ID.md)
---

## 1. Objectif de Performance
- **Métrique ciblée :** (Ex: "Temps de réponse de l'API GET /users".)
- **Objectif chiffré :** (Ex: "Doit être inférieur à 100ms au 95ème percentile.")

## 2. Protocole de Benchmark
- **Outil utilisé :** (Ex: `k6`, `JMeter`, `console.time`.)
- **Scénario de test :** (Description précise et reproductible de la manière dont la mesure est effectuée.)

## 3. Mesures Initiales (Avant Optimisation)
- **Résultats bruts :** (Copier/coller des résultats du benchmark.)
- **Analyse du goulet d'étranglement :** (Identifier la ligne, la requête ou la fonction exacte qui cause la lenteur.)

## 4. Stratégie d'Optimisation
- **Solution proposée :** (Ex: "Mise en cache du résultat avec Redis pendant 5 minutes", "Ajout d'un index sur la colonne X de la table Y".)

## 5. Preuve de Non-Régression 
- **Couverture de tests fonctionnels :** (Confirmer que le comportement métier est couvert par des tests **avant** de commencer l'optimisation.) 
- **Résultat des tests finaux :** (Affirmer que 100% des tests de la suite passent après l'optimisation.)

## 6. Mesures Finales (Après Optimisation)
- **Résultats bruts :** (Copier/coller des résultats du nouveau benchmark, exécuté dans des conditions identiques.)
- **Conclusion :** (Comparaison avant/après et confirmation que l'objectif est atteint.)
```

## SECTION 3 : PROCÉDURE D'OPTIMISATION

1. **[PROCEDURE] Phase 1 : Mesurer (Non négociable)**
    - **Action Requise :** Créer un fichier `OPTIM-[ID]-BENCHMARKING.md` dans `/docs/backlog/06-optim/`.
    - **⚡ Automatisation `aklo` :** `aklo new debug "<Titre d'optimisation'>"`
    - Remplir les sections "Objectif de Performance" et "Protocole de Benchmark".
    - Exécuter le benchmark sur le code **actuel** et remplir la section "Mesures Initiales".

2. **[ANALYSE] Phase 2 : Analyser et Proposer**
    - Analyser les résultats pour identifier le goulet d'étranglement avec certitude.
    - Remplir la section "Stratégie d'Optimisation" avec une proposition de correction ciblée.
    - Passer le statut à `AWAITING_FIX`.
    - [ATTENTE_VALIDATION] Soumettre le rapport et la proposition de solution pour validation au `Human_Developer`.

3. **[PROCEDURE] Phase 3 : Implémenter et Valider**
    - Une fois le plan approuvé, **activer le protocole [DEVELOPPEMENT] (`03-DEVELOPPEMENT.md`)** pour implémenter la solution.
    - Après l'implémentation, relancer **exactement le même benchmark** que dans la phase 1.
    - Remplir la section "Mesures Finales" du rapport pour prouver l'amélioration.

4. **[CONCLUSION] Phase 4 : Finalisation**
    - Une fois le refactoring terminé et tous les tests au vert, remplir la section "Preuve de Non-Régression".
    - Suivre l'étapes 6 (Revue avant commit) du protocole [DEVELOPPEMENT]
    - Mettre à jour le rapport de refactoring au statut `DONE`.
    - Activer le protocole [KNOWLEDGE-BASE] pour déterminer si l'analyse a produit une connaissance qui mérite d'être centralisée.
    - Suivre l'étapes 7 (Finalisation) du protocole [DEVELOPPEMENT] pour créer le `commit`.
