---
created: 2025-06-28 11:24
modified: 2025-06-28 11:29
---

# PROTOCOLE SPÉCIFIQUE : ONBOARDING DE PROJET

Ce protocole s'active à la demande pour générer un résumé de haut niveau du projet, destiné à accélérer l'intégration d'un nouveau membre ou à rafraîchir le contexte global de l'agent.

## SECTION 1 : MISSION ET LIVRABLE

### 1.1. Mission

Synthétiser les informations critiques du projet (mission, architecture, concepts clés, procédure de démarrage) en un document unique et facile à lire.

### 1.2. Livrable Attendu

1.  **Résumé d'Onboarding :** Un fichier `ONBOARDING-SUMMARY-[DATE].md` créé dans le répertoire racine du projet ou dans `/docs/project/`.

## SECTION 2 : ARTEFACT ONBOARDING - GESTION ET STRUCTURE

### 2.1. Nommage

-   `ONBOARDING-SUMMARY-[DATE].md`
    -   `[DATE]` : La date de génération du rapport au format `AAAA-MM-DD`.

### 2.2. Statuts

-   Ce type de document n'a pas de cycle de vie avec plusieurs statuts. Il est généré en une seule fois et a un statut implicite de **`GENERATED`**.

### 2.3. : STRUCTURE DU RAPPORT D'ONBOARDING

```markdown
# RÉSUMÉ D'ONBOARDING DU PROJET : [Nom du Projet]
---
**Date de Génération:** AAAA-MM-DD
**Généré par:** [Nom du Human_Developer ou AI_Agent]
**Version du Projet à cette date:** [Tag Git de la version actuelle, ex: v1.2.0]
---

## 1. Mission et Objectif du Projet

*Synthèse de la "raison d'être" du projet, de sa cible et de la valeur qu'il apporte. S'inspire des PBI principaux et de la connaissance générale du `Human_Developer`.*

## 2. Concepts Métier Clés (Glossaire)

*Liste des termes spécifiques au domaine du projet que tout nouveau membre doit comprendre.*
- **Terme 1 :** Définition.
- **Terme 2 :** Définition.

## 3. Vue d'Ensemble de l'Architecture

*Description de haut niveau des choix technologiques et structurels. Ne détaille pas l'implémentation mais explique les décisions majeures.*
- **Stack Technologique Principale :** [Ex: React, Node.js, PostgreSQL, AWS]
- **Patterns d'Architecture :** [Ex: "Microservices communiquant via une API Gateway", "Monolithe modulaire"]
- **Documents d'Architecture de Référence :**
    - [ARCH-XX](../../docs/backlog/02-architecture/ARCH-XX.md) - Décision sur [sujet]
    - [ARCH-YY](../../docs/backlog/02-architecture/ARCH-YY.md) - Décision sur [autre sujet]

## 4. Démarrage Rapide (Quick Start)

*Instructions minimalistes pour lancer l'environnement de développement en local.*
1.  `git clone https://www.dudsdepot.com/`
2.  `npm install`
3.  `npm run dev`
4.  L'application est disponible à l'adresse `http://localhost:3000`.

## 5. Points d'Entrée du Code

*Pistes pour aider un nouveau développeur à commencer à explorer le code.*
- **Démarrage de l'application :** `src/index.js`
- **Feature principale A :** `src/features/featureA/`
- **Logique métier principale :** `src/core/`
```

## SECTION 3 : PROCÉDURE DE GÉNÉRATION DU RAPPORT

1.  **[ANALYSE] Phase 1 : Cadrage**
      - Sur demande du `Human_Developer`, confirmer l'intention de générer un rapport d'onboarding.

2.  **[PROCEDURE] Phase 2 : Collecte d'Informations**
      - Scanner les répertoires `/docs/backlog/00-pbi/` et `/docs/backlog/02-architecture/` pour identifier les PBI les plus importants et les décisions d'architecture clés.
      - Analyser le `package.json` pour identifier la stack technologique et les scripts de démarrage.
      - Identifier les concepts métier récurrents dans les artefacts du backlog.

3.  **[PROCEDURE] Phase 3 : Rédaction du Rapport**
      - Remplir chaque section du rapport en synthétisant les informations collectées.
      - Pour la section "Mission", s'appuyer sur la connaissance générale du projet et la valider avec le `Human_Developer`.

4.  **[CONCLUSION] Phase 4 : Livraison**
      - Créer le fichier `ONBOARDING-SUMMARY-[DATE].md`.
      - Présenter le rapport finalisé au `Human_Developer`. La mission de ce protocole se termine ici.
