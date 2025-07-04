---
created: 2025-06-28 11:50
modified: 2025-06-28 11:54
---
# PROTOCOLE SPÉCIFIQUE : DÉPRÉCIATION DE FONCTIONNALITÉ

Ce protocole s'active lorsqu'une décision est prise de retirer une fonctionnalité, une API ou une portion de code significative de l'application.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Planifier et exécuter le retrait d'une fonctionnalité de manière sécurisée et contrôlée, en minimisant l'impact sur les utilisateurs et la stabilité de l'application.

### 1.2. Livrables Attendus

1.  **Plan de Dépréciation :** Un fichier `DEPRECATION-[ID].md` créé dans `/docs/backlog/12-deprecations/`.
2.  **Commit(s) de Suppression :** Un ou plusieurs `commits` qui retirent le code, les tests, la documentation et les configurations associés.
3.  **Communication Utilisateur (si applicable) :** Le contenu d'une communication destinée à informer les utilisateurs du retrait à venir.

## SECTION 2 : ARTEFACT DEPRECATION - GESTION ET STRUCTURE

### 2.1. Nommage

-   `DEPRECATION-[ID]-[Status].md`
    -   `[ID]` : Un identifiant unique généré à partir du titre et de la date (ex: `description-du-sujet-20250629`).
    -   `[Status]` : Le statut du processus.

### 2.2. Statuts

-   `ANALYSIS` : L'analyse d'impact et la planification sont en cours.
-   `AWAITING_EXECUTION` : Le plan est validé, en attente de l'implémentation technique.
-   `EXECUTED` : Le code a été retiré et la version est prête à être déployée.
-   `COMMUNICATED` : La suppression a été communiquée aux utilisateurs (si nécessaire).

### 2.3. Structure Obligatoire du Fichier de Dépréciation

```markdown
# PLAN DE DÉPRÉCIATION : [ID]
---
**Responsable:** [Nom du Human_Developer]
**Statut:** [ANALYSIS | AWAITING_EXECUTION | EXECUTED | COMMUNICATED]
**Fonctionnalité à Déprécier:** [Nom clair de la fonctionnalité]
**Date de Retrait Cible:** $(date +'%Y-%m-%d')
---

## 1. Justification

*Pourquoi cette fonctionnalité doit-elle être retirée ? (Ex: "Faible utilisation", "Remplacée par une nouvelle version", "Coût de maintenance trop élevé", "Risque de sécurité").*

## 2. Analyse d'Impact

- **Impact Utilisateur :** (Quels utilisateurs seront affectés et comment ?)
- **Impact Technique :** (Quelles autres parties du code dépendent de cette fonctionnalité ?)
- **Impact sur les Données :** (Faut-il migrer ou archiver des données ?)

## 3. Plan d'Action Technique

*Liste des `Tasks` à réaliser pour la suppression.*
- [ ] Retirer les routes d'API (`/api/v1/...`).
- [ ] Supprimer le module `src/features/old-billing/`.
- [ ] Retirer les tests correspondants.
- [ ] Nettoyer les variables de configuration.

## 4. Plan de Communication (si applicable)

- **Cible :** (Qui doit être informé ?)
- **Message :** (Contenu du message à envoyer.)
- **Canal et Date :** (Comment et quand la communication sera faite.)
```

## SECTION 3 : PROCÉDURE DE DÉPRÉCIATION

1.  **[ANALYSE] Phase 1 : Analyse et Planification**
      - **Action Requise :** Créer un nouveau fichier `DEPRECATION-[ID]-ANALYSIS.md` dans `/docs/backlog/12-deprecations/`.
      - **⚡ Automatisation `aklo` :** `aklo deprecate "<Titre de la dépréciation>"`
      - Remplir les sections "Justification" et "Analyse d'Impact".
      - Proposer un "Plan d'Action Technique" et un "Plan de Communication".
      - [ATTENTE\_VALIDATION] Soumettre le plan complet pour validation au `Human_Developer`.

2.  **[PROCEDURE] Phase 2 : Exécution de la Suppression**
      - Une fois le plan validé, passer le statut à `AWAITING_EXECUTION`.
      - **Activer le protocole [PLANIFICATION]** pour créer les `Tasks` techniques nécessaires.
      - Exécuter les `Tasks` en suivant le protocole [DEVELOPPEMENT].
      - Une fois le code retiré, passer le statut à `EXECUTED`.

3.  **[PROCEDURE] Phase 3 : Communication et Clôture**
      - Si un plan de communication a été défini, l'exécuter.
      - Une fois la communication effectuée (ou si elle n'était pas nécessaire), passer le statut final à `COMMUNICATED`.
      - **[CONCLUSION]** Informer le `Human_Developer` que le processus de dépréciation est terminé.
