---
created: 2025-06-28 11:15
modified: 2025-06-28 11:22
---
# PROTOCOLE SPÉCIFIQUE : AUDIT DE SÉCURITÉ

Ce protocole s'active de manière périodique (ex: trimestriellement) ou avant une release majeure pour identifier et planifier la correction de vulnérabilités de sécurité dans le code et les dépendances.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Mener une analyse de sécurité systématique pour identifier les failles potentielles, évaluer leur criticité, et créer un plan d'action pour les corriger.

### 1.2. Livrables Attendus

1.  **Rapport d'Audit de Sécurité :** Un fichier `AUDIT-SECURITY-[DATE].md` créé dans `/docs/backlog/11-security/`.
2.  **Tasks / PBI de Correction :** Une ou plusieurs `Tasks` ou `PBI` créés pour corriger les vulnérabilités identifiées.

## SECTION 2 : ARTEFACT AUDIT - GESTION ET STRUCTURE

### 2.1. Nommage

-   `AUDIT-SECURITY-[DATE]-[Status].md`
    -   `[DATE]` : La date de l'audit au format `AAAA-MM-DD`.
    -   `[Status]` : Le statut de l'audit.

### 2.2. Statuts

-   `SCANNING` : L'analyse automatisée et manuelle est en cours.
-   `TRIAGE` : Les vulnérabilités trouvées sont en cours d'analyse et de priorisation.
-   `CONCLUDED` : L'audit est terminé et le plan d'action a été créé.

### 2.3. Structure Obligatoire du Fichier d'Audit

```markdown
# RAPPORT D'AUDIT DE SÉCURITÉ : [DATE]
---
**Responsable:** [Nom du Human_Developer]
**Statut:** [SCANNING | TRIAGE | CONCLUDED]
**Périmètre de l'Audit:** [Ex: "Dépendances NPM", "API d'authentification"]
**Outils Utilisés:** [Ex: "npm audit", "Snyk CLI", "SonarQube"]
---

## 1. Résumé des Résultats (Executive Summary)

*Synthèse du niveau de risque global et des découvertes les plus critiques.*
- **Niveau de Risque Global :** Critique / Élevé / Moyen / Faible
- **Vulnérabilités Critiques Trouvées :** X
- **Vulnérabilités Élevées Trouvées :** Y

## 2. Liste des Vulnérabilités Identifiées

| ID | Description | Criticité | Composant Affecté | Recommandation |
|----|-------------|-----------|--------------------|----------------|
| 1  | [Ex: XSS dans le champ de recherche] | Critique  | `search.js`        | [Ex: Échapper les entrées utilisateur] |
| 2  | [Ex: Dépendance `lodash` obsolète avec faille connue] | Élevée    | `package.json`     | [Ex: Mettre à jour vers la version X.Y.Z] |
|... | ...         | ...       | ...                | ...            |

## 3. Plan d'Action - Tâches et PBI Créés

*Liste des liens vers les `Tasks` ou `PBI` qui ont été créés pour corriger les failles.*
- **Correction Urgente :** [TASK-XX](../../01-tasks/TASK-XX-TODO.md) - Mettre à jour la dépendance `lodash`.
- **Correction Standard :** [PBI-YY](../../00-pbi/PBI-YY-PROPOSED.md) - Réviser la gestion des entrées utilisateur.
````

## SECTION 3 : PROCÉDURE D'AUDIT

1.  **[PROCEDURE] Phase 1 : Scan Automatisé**
      - **Action Requise :** Créer un fichier `AUDIT-SECURITY-[DATE]-SCANNING.md` dans `/docs/backlog/11-security/`.
      - **⚡ Automatisation `aklo` :** `aklo new security-audit`
      - Exécuter les outils d'analyse de sécurité automatisés (ex: `npm audit`, `Snyk`, scanners de code statique).
      - Compiler les résultats bruts dans le rapport.

2.  **[ANALYSE] Phase 2 : Triage et Analyse Manuelle**
      - Passer le statut à `TRIAGE`.
      - Pour chaque vulnérabilité trouvée, évaluer son impact réel dans le contexte de l'application (éliminer les faux positifs) et assigner un niveau de criticité (Critique, Élevé, Moyen, Faible).
      - Remplir le tableau de la "Liste des Vulnérabilités Identifiées".

3.  **[ANALYSE] Phase 3 : Plan de Correction**
      - Pour chaque vulnérabilité validée, proposer une recommandation de correction.
      - Rédiger un "Plan d'Action" qui liste les `Tasks` et `PBI` à créer.

4.  **[ATTENTE\_VALIDATION] Phase 4 : Validation du Plan**
      - Soumettre le rapport d'audit complet et le plan d'action pour validation au `Human_Developer`.

5.  **[CONCLUSION] Phase 5 : Clôture**
      - Une fois le plan validé, **activer les protocoles [PRODUCT OWNER] ou [PLANIFICATION]** pour créer officiellement les `PBI` et `Task` de correction.
      - Lier les artefacts créés dans la section 3 du rapport d'audit.
      - Passer le statut du rapport à `CONCLUDED`.
