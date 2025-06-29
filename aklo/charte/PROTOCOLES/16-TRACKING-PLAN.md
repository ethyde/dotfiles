---
created: 2025-06-28 11:57
modified: 2025-06-28 12:05
---
# PROTOCOLE SPÉCIFIQUE : PLAN DE TRACKING

Ce protocole s'active avant le développement d'une fonctionnalité nécessitant la collecte de nouvelles données (analytique, logs, performance) pour s'assurer que les données collectées sont cohérentes, utiles et bien définies.

## SECTION 1 : MISSION ET LIVRABLE

### 1.1. Mission

Définir de manière structurée et intentionnelle les événements, logs et métriques à collecter pour une fonctionnalité donnée, en précisant leur but, leur structure et leur destination.

### 1.2. Livrable Attendu

1.  **Plan de Tracking :** Un fichier `TRACKING-PLAN-[ID].md` créé dans `/docs/backlog/13-tracking/`, servant de source de vérité pour l'implémentation du tracking.

## SECTION 2 : ARTEFACT TRACKING-PLAN - GESTION ET STRUCTURE

### 2.1. Nommage

-   `TRACKING-PLAN-[ID]-[Status].md`
    -   `[ID]` : L'ID du `PBI` ou de la fonctionnalité concernée.
    -   `[Status]` : Le statut du plan.

### 2.2. Statuts

-   `DRAFT` : La définition du plan est en cours.
-   `AWAITING_IMPLEMENTATION` : Le plan est validé et prêt à être intégré dans les `Tasks` de développement.
-   `IMPLEMENTED` : Le plan de tracking a été implémenté en production.

### 2.3. Structure Obligatoire du Fichier de Tracking

```markdown
# PLAN DE TRACKING : [ID]
---
**Responsable:** [Nom du Human_Developer]
**Statut:** [DRAFT | AWAITING_IMPLEMENTATION | IMPLEMENTED]
**Fonctionnalité Concernée:** [Lien vers le PBI ou la Task concernée]
**Outils Concernés:** [Ex: Google Analytics, Sentry, Datadog]
---

## 1. Objectifs de la Collecte

*Pourquoi collectons-nous ces données ? Quel problème cherchons-nous à résoudre ou quelle question cherchons-nous à éclaircir ?*
- **Objectif A (Analyse Produit) :** Comprendre le taux d'adoption de la nouvelle feature.
- **Objectif B (Observabilité) :** Surveiller la performance de l'API associée.
- **Objectif C (Débogage) :** Enregistrer les erreurs potentielles dans le nouveau flux.

## 2. Dictionnaire des Événements et Métriques

### Catégorie : Événements Utilisateur (Analytics)
- **Événement :** `feature_x_enabled`
  - **Déclencheur :** L'utilisateur active la fonctionnalité X.
  - **Propriétés :** `{ "source": "settings_page" }`
  - **Destination :** [Ex: Google Analytics, Mixpanel]

### Catégorie : Métriques de Performance (Observability)
- **Métrique :** `api_feature_x_response_time_ms`
  - **Description :** Mesure la latence de l'API pour la fonctionnalité X.
  - **Type :** Timing (millisecondes).
  - **Destination :** [Ex: Datadog, Prometheus]

### Catégorie : Logs Techniques (Debugging)
- **Log :** `feature_x_calculation_failed`
  - **Niveau :** `ERROR`
  - **Contexte à inclure :** `{ "userId": "...", "reasonForFailure": "..." }`
  - **Destination :** [Ex: Sentry, ELK Stack]
```

## SECTION 3 : PROCÉDURE DE CRÉATION D'UN PLAN DE TRACKING

1.  **[ANALYSE] Phase 1 : Définition des Objectifs**
      - Lors de la phase de [PLANIFICATION] d'un `PBI`, si de nouvelles données doivent être collectées, 
      **Action Requise :** Créer un fichier `TRACKING-PLAN-[ID]-DRAFT.md`, où [ID] est celui du PBI ou de la Task concernée, dans `/docs/backlog/13-tracking/`.
      - **⚡ Automatisation `aklo` :** `aklo new tracking-plan <ID_du_PBI_ou_Task>`
      - Remplir l'en-tête et la section "Objectifs de la Collecte" en collaboration avec le `Human_Developer`.

2.  **[PROCEDURE] Phase 2 : Définition des Événements et Métriques**
      - Pour chaque objectif, lister les événements, métriques ou logs spécifiques à collecter.
      - Remplir le "Dictionnaire des Événements et Métriques" de manière détaillée.

3.  **[ATTENTE_VALIDATION] Phase 3 : Validation du Plan**
      - Soumettre le plan de tracking complet pour validation au `Human_Developer`. C'est une étape critique pour s'assurer que les données collectées seront utiles et correctement structurées.

4.  **[CONCLUSION] Phase 4 : Intégration au Développement**
      - Une fois le plan validé, passer le statut à `AWAITING_IMPLEMENTATION`.
      - Le contenu de ce plan doit être utilisé pour créer ou enrichir les `Tasks` de développement dans le protocole [PLANIFICATION]. Chaque événement ou métrique à implémenter doit devenir une sous-partie d'une `Task`.
