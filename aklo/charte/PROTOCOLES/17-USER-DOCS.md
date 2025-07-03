---
created: 2025-06-28 12:09
modified: 2025-06-28 12:13
---
# PROTOCOLE SPÉCIFIQUE : DOCUMENTATION UTILISATEUR

Ce protocole s'active lorsqu'une nouvelle fonctionnalité ou une modification a un impact direct sur l'utilisateur final et nécessite la création ou la mise à jour de la documentation publique (guides, FAQ, etc.).

## SECTION 1 : MISSION ET LIVRABLE

### 1.1. Mission

Assurer que la documentation destinée aux utilisateurs finaux est claire, précise, et parfaitement synchronisée avec le comportement actuel de l'application.

### 1.2. Livrable Attendu

1.  **Plan de Documentation :** Un fichier `USER-DOCS-[ID].md` créé dans `/docs/backlog/14-user-docs/`.
2.  **Contenu Finalisé :** Le texte et les images prêts à être intégrés dans le système de gestion de la documentation (ex: Zendesk, GitBook, site web d'aide).

## SECTION 2 : ARTEFACT USER-DOCS - GESTION ET STRUCTURE

### 2.1. Nommage

-   `USER-DOCS-[ID]-[Status].md`
    -   `[ID]` : Un identifiant unique généré à partir du titre et de la date (ex: description-du-sujet-20250629).
    -   `[Status]` : Le statut du travail de documentation.

### 2.2. Statuts

-   `DRAFT` : La rédaction est en cours.
-   `AWAITING_REVIEW` : Le contenu est prêt pour la relecture et la validation par le `Human_Developer`.
-   `PUBLISHED` : La documentation a été mise en ligne.

### 2.3. Structure Obligatoire du Fichier de Documentation

```markdown
# PLAN DE DOCUMENTATION UTILISATEUR : %%ID%%
---
**Responsable:** [Nom du Human_Developer]
**Statut:** [DRAFT | AWAITING_REVIEW | PUBLISHED]
**Fonctionnalité Concernée:** [Lien vers le PBI ou la Release]
**Audience Cible:** [Ex: "Nouveaux utilisateurs", "Administrateurs", "Tous"]
**Plateforme de Publication:** [Ex: "Zendesk", "Blog", "GitBook"]
**Date de Publication Cible:** AAAA-MM-DD
---

## 1. Objectif de la Documentation

*Quel est le but de ce document ? (Ex: "Expliquer comment utiliser la nouvelle fonctionnalité de paiement", "Mettre à jour la FAQ avec les nouvelles limites de compte").*

## 2. Plan de Contenu

- **Titre de l'article :** [Titre clair et orienté utilisateur]
- **Audience Cible :** [Ex: "Tous les utilisateurs", "Administrateurs de compte"]
- **Structure / Sections :**
    1.  Introduction
    2.  Étape 1 : ...
    3.  Étape 2 : ...
    4.  Questions Fréquentes

## 3. Contenu Brut à Rédiger

*(Cette section contiendra le texte final, les descriptions d'images, etc.)*

### [Titre de l'article]

... (Texte complet de la documentation) ...
````

## SECTION 3 : PROCÉDURE DE GESTION DE LA DOCUMENTATION

1.  **[ANALYSE] Phase 1 : Identification du Besoin**
      - Lors de la phase de [PLANIFICATION] d'un `PBI` ou de [RELEASE], identifier si une documentation utilisateur est nécessaire.
      - **Action Requise :** Créer un fichier `USER-DOCS-[ID]-DRAFT.md`, où [ID] est celui du PBI ou de la Release concernée, dans `/docs/backlog/14-user-docs/`.
      - **⚡ Automatisation `aklo` :** `aklo docs <ID_du_PBI_ou_Release>`
      - Remplir l'en-tête et la section "Objectif de la Documentation".

2.  **[PROCEDURE] Phase 2 : Rédaction du Contenu**
      - Élaborer le "Plan de Contenu" en définissant la structure de l'article ou du guide.
      - Rédiger le "Contenu Brut" en se mettant à la place de l'utilisateur final (langage simple, clair, sans jargon technique).

3.  **[ATTENTE\_VALIDATION] Phase 3 : Relecture et Validation**
      - Une fois la rédaction terminée, passer le statut à `AWAITING_REVIEW`.
      - Soumettre le contenu complet pour relecture et approbation au `Human_Developer`.

4.  **[CONCLUSION] Phase 4 : Publication**
      - Une fois le contenu validé, passer le statut à `PUBLISHED`.
      - Le `Human_Developer` ou l' `AI_Agent` (si des outils le permettent) procède à la publication du contenu sur la plateforme de documentation.
      - Informer le `Human_Developer` que la documentation est en ligne.
