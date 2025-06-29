---
created: 2025-06-28 09:57
modified: 2025-06-28 10:09
---
# PROTOCOLE SPÉCIFIQUE : GESTION DE RELEASE

Ce protocole s'active lorsque le `Human_Developer` décide qu'un ensemble de fonctionnalités est prêt à être publié en tant que nouvelle version stable de l'application.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Coordonner et automatiser les étapes nécessaires pour transformer une série de `commits` validés en une version logicielle officielle, documentée et prête pour le déploiement.

### 1.2. Livrables Attendus

1.  **Rapport de Release :** Un fichier `RELEASE-[version].md` créé dans `/docs/backlog/07-releases/`.
2.  **Journal des Modifications :** Le fichier `CHANGELOG.md` à la racine du projet, mis à jour avec les changements de la nouvelle version.
3.  **Tag Git :** Un tag Git sémantique et annoté (ex: `v1.2.0`).
4.  **Build de Production :** Un artefact de build prêt pour le déploiement (ex: un conteneur Docker, une archive `.zip`).

## SECTION 2 : ARTEFACT RELEASE - GESTION ET STRUCTURE

### 2.1. Nommage

-   `RELEASE-[version]-[Status].md`
    -   `[version]` : Le numéro de version sémantique (ex: `1.2.0`).
    -   `[Status]` : Le statut du processus de release.

### 2.2. Statuts

-   `PREPARING` : La collecte des informations et la création de la branche de release sont en cours.
-   `AWAITING_DEPLOYMENT` : La version a été buildée, tagguée et est prête pour le déploiement final.
-   `SHIPPED` : La version a été déployée en production.

### 2.3. Structure Obligatoire du Fichier Release

```markdown
# RAPPORT DE RELEASE : v[version]
---
**Date de Début:** YYYY-MM-DD
**Date de Fin:** YYYY-MM-DD
---

## 1. Objectif de la Release

*Brève description du but de cette version. Ex: "Livrer la fonctionnalité de paiement par carte et corriger les bugs de performance sur le dashboard."*

## 2. PBI Inclus dans cette Version

*Liste des PBI (avec liens) qui ont été complétés depuis la dernière release et qui sont inclus ici. Cette liste sert de base pour générer le CHANGELOG.*
- [PBI-42](../../00-pbi/PBI-42-DONE.md): Paiement par carte
- [PBI-45](../../00-pbi/PBI-45-DONE.md): Optimisation du dashboard

## 3. Checklist de Pré-déploiement

- [ ] La branche `release/vX.X.X` a été créée depuis `main` (ou `develop`).
- [ ] Le `CHANGELOG.md` a été généré et validé.
- [ ] La version dans `package.json` a été mise à jour.
- [ ] Tous les tests (unitaires, intégration, end-to-end) passent sur la branche de release.
- [ ] Le build de production a été créé avec succès.
- [ ] Le tag Git `vX.X.X` a été créé et poussé.
```

## SECTION 3 : PROCÉDURE DE RELEASE

1.  **[ANALYSE] Phase 1 : Lecture de la Configuration**
    -   Lire et charger en mémoire les conventions depuis `CONFIG-PROJET.md`.
    -   Déterminer le prochain numéro de version en se basant sur le **Schéma de version** défini.
    -   [ATTENTE_VALIDATION] Proposer le numéro de version au `Human_Developer` pour approbation.

2.  **[PROCEDURE] Phase 2 : Préparation**
    - **Action Requise :**
        -   Sur décision du `Human_Developer`, créer le rapport `RELEASE-[version]-PREPARING.md`.
        -   **Si** `Utilisation de branches de release: Oui`, créer une branche en utilisant le **Format des branches de release** (ex: `release/1.2.0`) depuis la **Branche de développement principale**.
        -   **Sinon**, toutes les actions se feront directement sur la **Branche de développement principale**.
        -   Mettre à jour la version dans les fichiers projet (`package.json`, etc.).
        -   Générer une proposition de `CHANGELOG.md`.
    - **⚡ Automatisation `aklo` :** `aklo release <major|minor|patch>`

3.  **[ATTENTE_VALIDATION] Phase 3 : Validation du Contenu**
    -   Soumettre le `CHANGELOG.md` proposé pour validation au `Human_Developer`.

4.  **[PROCEDURE] Phase 4 : Validation Technique et Build**
    -   Lancer l'intégralité de la suite de tests sur la branche de travail.
    -   Si tous les tests sont au vert, lancer le script de build de production.

5.  **[PROCEDURE] Phase 5 : Finalisation et Tagging**
    -   Si le build réussit, fusionner la branche de travail dans la **Branche de production**.
    -   Créer un tag Git annoté en respectant le **Format du tag Git** défini (ex: `v1.2.0`).
    -   Pousser le tag et les branches sur le dépôt distant.
    -   Fusionner la **Branche de production** dans la **Branche de développement principale** pour synchroniser.

6.  **[CONCLUSION] Phase 6 : Prêt pour Déploiement**
    -   Mettre à jour le rapport de release au statut `AWAITING_DEPLOYMENT`.
    -   Informer le `Human_Developer` que la version est prête à être déployée.