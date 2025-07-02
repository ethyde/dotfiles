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

**🛫 PLAN DE VOL RELEASE (Obligatoire avant Phase 1)**

Avant toute procédure de release, l'agent **doit** présenter un plan détaillé :

**[PLAN_DE_VOL_RELEASE]**
**Objectif :** Créer une version stable et déployable de l'application
**Actions prévues :**
1. Lecture de la configuration `.aklo.conf` pour conventions de versioning
2. Détermination du prochain numéro de version (major/minor/patch)
3. Création du rapport `RELEASE-[version]-PREPARING.md` dans `/docs/backlog/07-releases/`
4. Création de branche de release (si configuré) ou travail sur branche principale
5. Mise à jour des fichiers de version (package.json, etc.)
6. Génération du CHANGELOG.md basé sur les PBI complétés
7. Exécution complète de la suite de tests
8. Build de production et validation
9. Création du tag Git annoté et déploiement

**Fichiers affectés :**
- `/docs/backlog/07-releases/RELEASE-[version]-PREPARING.md` → `AWAITING_DEPLOYMENT` → `SHIPPED`
- `CHANGELOG.md` : mise à jour avec nouvelles fonctionnalités
- `package.json` (ou équivalent) : mise à jour version
- Possibles fichiers de configuration de build
- Artefacts de build de production

**Commandes système :**
- `aklo release <major|minor|patch>` : automatisation release (optionnel)
- `git checkout -b release/[version]` : création branche release (si configuré)
- Exécution suite complète de tests (unitaires, intégration, e2e)
- Scripts de build de production selon stack technique
- `git tag -a v[version]` : création tag annoté
- Commandes de déploiement selon infrastructure

**Outils MCP utilisés :**
- `mcp_desktop-commander_read_file` : lire configuration .aklo.conf
- `mcp_desktop-commander_write_file` : créer rapport et CHANGELOG
- `mcp_desktop-commander_edit_block` : mettre à jour fichiers de version
- `mcp_desktop-commander_execute_command` : tests, build, git, déploiement
- `mcp_aklo-terminal_aklo_execute` : commandes aklo (si utilisées)

**Validation requise :** ✅ OUI - Attente approbation explicite avant release

1.  **[ANALYSE] Phase 1 : Lecture de la Configuration**
    -   Lire et charger en mémoire les conventions depuis `.aklo.conf`.
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

5.  **[PROCEDURE] Phase 5 : Préparation du Commit Atomique**
    -   Finaliser le rapport de release au statut `AWAITING_DEPLOYMENT`.
    -   Mettre à jour le journal avec le processus de release.
    -   Préparer tous les fichiers pour le commit atomique final.

6.  **[ATTENTE_VALIDATION] Phase 6 : Validation du Commit Atomique**
    -   Présenter le diff complet de la release au `Human_Developer`.
    -   Attendre validation explicite avant le commit final.

7.  **[CONCLUSION] Phase 7 : Finalisation et Tagging**
    -   Créer le commit atomique de release.
    -   Si configuré, fusionner dans la **Branche de production**.
    -   Créer un tag Git annoté en respectant le **Format du tag Git** défini.
    -   Pousser le tag et les branches sur le dépôt distant.

## SECTION 4 : COMMIT ATOMIQUE DE RELEASE

### 4.1. Principe du Commit Unique

**Règle Fondamentale :** Une release produit un unique commit atomique qui inclut :

1. **Rapport de release finalisé** : `RELEASE-[version]-AWAITING_DEPLOYMENT.md`
2. **CHANGELOG.md mis à jour** : Avec toutes les nouvelles fonctionnalités
3. **Version mise à jour** : Dans `package.json` ou fichiers équivalents
4. **Mise à jour du journal** : Documentation du processus de release

### 4.2. Workflow Séquentiel Sans Commits Intermédiaires

**Principe :** Toutes les modifications sont préparées en local, validées ensemble, puis commitées atomiquement.

**Séquence :**
1. **Préparation locale :** Rapport + CHANGELOG + version (pas de commit)
2. **Validation technique :** Tests + build (pas de commit)
3. **Validation humaine :** Diff complet présenté au `Human_Developer`
4. **Commit atomique :** Après validation explicite
5. **Tagging :** Tag Git créé sur le commit atomique

### 4.3. Contenu du Commit

**Message de commit type :**
```
release: Version [version]

[Résumé des principales fonctionnalités de cette version]

- Rapport RELEASE-[version] finalisé
- CHANGELOG.md mis à jour avec [N] nouvelles fonctionnalités
- Version mise à jour : [ancienne] → [nouvelle]
- Journal mis à jour avec le processus de release
- Tous les tests passent, build de production validé

Features included:
- [Feature 1]
- [Feature 2]
- [...]

Breaking changes: [None|Liste des breaking changes]
```

### 4.4. Gestion des Rollbacks

**Règle :** En cas de problème détecté après release, utiliser le protocole HOTFIX plutôt que de modifier le commit de release.

**Traçabilité :** Le commit de release reste inchangé pour préserver l'historique, les corrections sont apportées par des commits séparés.