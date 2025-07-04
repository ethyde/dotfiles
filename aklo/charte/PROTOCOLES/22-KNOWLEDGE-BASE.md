---
created: 2025-06-28 14:15
modified: 2025-06-28 14:35
---
# PROTOCOLE SPÉCIFIQUE : KNOWLEDGE-BASE (GESTION DES CONNAISSANCES)

Ce protocole a pour mission de capitaliser sur le savoir acquis au fil du projet pour éviter de répéter les mêmes erreurs et accélérer les prises de décision futures.

## SECTION 1 : MISSION ET LIVRABLE

### 1.1. Mission

Extraire les apprentissages critiques et transversaux issus des protocoles de `DEBUG`, `ARCHITECTURE`, `EXPERIMENTATION` ou `OPTIMISATION` et les centraliser dans une base de connaissance unique et facile d'accès.

### 1.2. Livrable Attendu

1.  **Base de Connaissance :** Un unique fichier `KNOWLEDGE-BASE.md` à la racine du répertoire `/docs/`, continuellement enrichi.

## SECTION 2 : ARTEFACT ET STRUCTURE

### 2.1. Artefact

-   Un seul et unique fichier : `/docs/KNOWLEDGE-BASE.md`.

### 2.2. Structure Recommandée du Fichier
```markdown
# BASE DE CONNAISSANCES DU PROJET
---
*Ce document est la source de vérité pour les décisions techniques récurrentes et les leçons apprises. Il doit être consulté avant toute décision d'architecture ou de choix de dépendance.*

---
## ID: KB-001
**Sujet:** Performance de la librairie `SuperChart.js`
**Statut:** Actif
**Date d'ajout:** 2025-07-01
**Source:** `DEBUG-performance-dashboard-20250701.md`

#### Connaissance
La librairie `SuperChart.js` présente de sévères dégradations de performance (blocage du thread principal) au-delà de 1000 points de données sur le même graphique.

#### Analyse d'Impact
- **Impact Direct :** Bloque le développement de dashboards denses et de fonctionnalités d'analyse en temps réel.
- **Risque :** L'utilisation non informée de cette librairie sur de nouvelles fonctionnalités pourrait créer des régressions de performance critiques.

#### Recommandation Actionnable
1.  **NE PAS UTILISER** `SuperChart.js` pour des visualisations de plus de 500 points.
2.  Pour les graphiques denses, **UTILISER** `MegaGraph.js` qui implémente une solution de virtualisation du canvas.
3.  **VALIDER** la performance de tout nouveau graphique via un test de charge défini dans `OPTIM-benchmark-protocol.md`.

---
## ID: KB-002
**Sujet:** Communication Inter-Services
**Statut:** Actif
**Date d'ajout:** 2025-06-28
**Source:** `ARCH-refactor-notification-service-1.md`

#### Connaissance
Les appels API synchrones directs entre le service `Users` et le service `Billing` ont créé un couplage fort, menant à des pannes en cascade lorsque l'un des deux est ralenti.

#### Analyse d'Impact
- **Impact Direct :** Une lenteur sur le service `Billing` empêchait les utilisateurs de se connecter, ce qui est un impact inacceptable.
- **Risque :** Étendre ce pattern de communication synchrone à de nouveaux services augmentera exponentiellement la fragilité de l'architecture globale.

#### Recommandation Actionnable
1.  Pour toute nouvelle interaction **non-bloquante** (ex: notification, mise à jour de statuts), **UTILISER OBLIGATOIREMENT** une communication asynchrone via le bus d'événements Kafka.
2.  Les appels synchrones ne sont autorisés que pour des opérations **bloquantes et critiques** (ex: vérifier la validité d'un paiement avant de donner accès à un service).
```

## SECTION 3 : PROCÉDURE DE GESTION

1.  **[ANALYSE] Phase 1 : Détection d'une Connaissance**

      - À la fin d'un protocole (`DEBUG`, `ARCH`, etc.), l'`AI_Agent` ou le `Human_Developer` doit se poser la question : "Avons-nous appris quelque chose ici qui pourrait être utile à quelqu'un d'autre dans le futur ?".

2.  **[PROCEDURE] Phase 2 : Proposition d'Ajout**

      - Si la réponse est oui, l'`AI_Agent` propose une entrée pour la base de connaissance.
      - La proposition doit inclure la catégorie, le sujet, la connaissance, la recommandation et le lien vers l'artefact source.

3.  **[ATTENTE\_VALIDATION] Phase 3 : Validation**

      - Soumettre la nouvelle entrée pour validation au `Human_Developer`.

4.  **[CONCLUSION] Phase 4 : Mise à Jour**

      - Une fois l'entrée approuvée, l'`AI_Agent` met à jour le fichier `/docs/KNOWLEDGE-BASE.md` et crée un `commit` dédié (ex: `docs(kb): add lesson about SuperChart.js performance`).