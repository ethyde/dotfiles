---
created: 2025-06-28 11:08
modified: 2025-06-28 11:17
---
# PROTOCOLE SPÉCIFIQUE : ANALYSE DE LA CONCURRENCE

Ce protocole s'active à la demande du `Human_Developer` pour analyser de manière structurée les produits, fonctionnalités ou approches techniques de concurrents.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Collecter, synthétiser et analyser des informations sur la concurrence pour identifier des opportunités, des menaces, et générer des idées actionnables pour notre propre produit.

### 1.2. Livrables Attendus

1.  **Rapport d'Analyse Concurrentielle :** Un fichier `COMPETITION-[ID].md` créé dans `/docs/backlog/10-competition/`.
2.  **Propositions de PBI :** Une ou plusieurs propositions de `PBI` (fichiers `PBI-[ID]-PROPOSED.md`) découlant des conclusions de l'analyse.

## SECTION 2 : ARTEFACT ANALYSE - GESTION ET STRUCTURE

### 2.1. Nommage

-   `COMPETITION-[ID]-[Status].md`
    -   `[ID]` : Un identifiant unique généré à partir du titre et de la date (ex: `description-du-sujet-20250629`).
    -   `[Status]` : Le statut de l'analyse.

### 2.2. Statuts

-   `ANALYSIS` : La recherche et la rédaction du rapport sont en cours.
-   `CONCLUDED` : L'analyse est terminée, et les actions de suivi ont été créées.

### 2.3. Structure Obligatoire du Fichier d'Analyse

```markdown
# RAPPORT D'ANALYSE CONCURRENTIELLE : [ID]
---
**Responsable:** [Nom du Human_Developer]
**Statut:** [ANALYSIS | CONCLUDED]
**Date de l'Analyse:** $(date +'%Y-%m-%d')
**Sujet de l'Analyse:** [Ex: "Méthodes d'authentification concurrentes"]
**Concurrents Analysés:** [Liste des concurrents]
---

## 1. Synthèse des Observations (Executive Summary)

*Résumé en quelques points des découvertes principales et des conclusions clés. C'est la partie la plus importante pour une lecture rapide.*

## 2. Analyse Détaillée par Concurrent

### Concurrent A : [Nom du Concurrent A]
- **Approche / Fonctionnalité :** (Description de ce qu'ils font)
- **Points Forts (Forces) :** (Ce qu'ils font bien)
- **Points Faibles (Faiblesses) :** (Ce qui pourrait être amélioré)
- **Opportunité pour nous :** (Comment on peut s'en inspirer ou faire mieux)

### Concurrent B : [Nom du Concurrent B]
- ...

## 3. Recommandations et Plan d'Action

*Liste des actions concrètes recommandées suite à cette analyse.*
- **Action 1 :** Créer un PBI pour [décrire la fonctionnalité X].
- **Action 2 :** Lancer une phase d'[EXPERIMENTATION] sur [décrire l'hypothèse Y].
- **Action 3 :** Ne rien faire, car [justification].

## 4. PBI Proposés

*Liste des liens vers les PBI qui ont été créés suite à cette analyse.*
- [PBI-XX](../../00-pbi/PBI-XX-PROPOSED.md)
```

## SECTION 3 : PROCÉDURE D'ANALYSE

1.  **[ANALYSE] Phase 1 : Cadrage de l'Analyse**
      - **Action Requise :** Créer un nouveau fichier `COMPETITION-[ID]-ANALYSIS.md` dans `/docs/backlog/10-competition/`.
      - **⚡ Automatisation `aklo` :** `aklo analyze "<Titre de l'analyse>"`
      - Remplir complètement l'en-tête (Responsable, Statut, Sujet, etc.).
      - Définir clairement le "Sujet de l'Analyse" et la liste des "Concurrents Analysés".

2.  **[PROCEDURE] Phase 2 : Recherche et Synthèse**
      - Mener la recherche sur les concurrents identifiés, en se concentrant sur le sujet défini.
      - Remplir la section "Analyse Détaillée par Concurrent" du rapport.
      - Rédiger la "Synthèse des Observations".

3.  **[ANALYSE] Phase 3 : Recommandations**
      - Sur la base de l'analyse, formuler des recommandations claires et un plan d'action dans la section dédiée.

4.  **[ATTENTE\_VALIDATION] Phase 4 : Validation et Création des PBI**
      - Soumettre le rapport complet et les recommandations pour validation au `Human_Developer`.

5.  **[CONCLUSION] Phase 5 : Clôture**
      - Une fois le plan d'action validé, **activer le protocole [PRODUCT OWNER]** pour chaque PBI à créer.
      - Lier les PBI créés dans la section "PBI Proposés" du rapport d'analyse.
      - Passer le statut du rapport à `CONCLUDED`.
