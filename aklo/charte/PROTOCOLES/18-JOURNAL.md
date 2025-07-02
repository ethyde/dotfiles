---
created: 2025-06-28 12:35
modified: 2025-06-28 12:57
---
# PROTOCOLE SPÉCIFIQUE : JOURNAL DE TRAVAIL

Ce protocole définit comment documenter de manière chronologique les activités pour assurer la traçabilité du travail, en s'intégrant parfaitement dans le principe des commits atomiques par protocole.

## SECTION 1 : MISSION ET PRINCIPE D'INTÉGRATION

### 1.1. Mission

Documenter de manière chronologique les actions entreprises, les décisions prises et les obstacles rencontrés, en s'intégrant systématiquement dans les commits des autres protocoles.

### 1.2. Principe d'Intégration aux Commits Atomiques

**Règle Fondamentale :** Le journal ne fait jamais l'objet de commits séparés. Chaque mise à jour du journal est incluse dans le commit atomique du protocole en cours.

**Exemples d'intégration :**
- **Finalisation TASK :** `commit(code + TASK-DONE + journal-update)`
- **Planification PBI :** `commit(toutes-TASK-créées + journal-update)`
- **Changement statut PBI :** `commit(PBI-AGREED + journal-update)`

### 1.3. Livrable

**Fichier Journal Quotidien :** Un unique fichier `JOURNAL-[DATE].md` dans `/docs/backlog/15-journal/`, mis à jour au fil des protocoles exécutés.

## SECTION 2 : ARTEFACT JOURNAL - GESTION ET STRUCTURE

### 2.1. Nommage

-   `JOURNAL-[DATE].md`
    -   `[DATE]` : La date du jour au format `AAAA-MM-DD`.

### 2.2. Statuts

Le journal n'a pas de statuts formels car il évolue continuellement. Il est considéré comme **actif** tant que des protocoles sont en cours d'exécution.

### 2.3. Structure Obligatoire du Fichier Journal

```markdown
# JOURNAL DE TRAVAIL : AAAA-MM-DD
---
**Responsable:** [Nom du Human_Developer / AI_Agent]
**Objectif(s) de la journée:** [Lister les Tasks ou PBI principaux ciblés]
---

## Entrées Chronologiques

### HH:MM - Début de la session

- **Action :** Démarrage du travail sur la [TASK-XX].
- **Contexte :** Lecture du PBI parent et du plan d'action.

### HH:MM - Analyse

- **Réflexion :** L'approche proposée dans la Task pour la fonction Y semble complexe.
- **Hypothèse :** Utiliser la librairie Z pourrait simplifier le code.
- **Action :** Création d'un [SCRATCHPAD-XYZ] pour explorer cette alternative.

### HH:MM - Décision

- **Décision :** L'alternative explorée est viable et plus simple.
- **Action :** Mise à jour de la [TASK-XX] pour refléter la nouvelle approche.
- **[ATTENTE_VALIDATION]** Soumission de la modification de la Task au `Human_Developer`.

### HH:MM - Obstacle

- **Problème :** L'erreur `Tracker "idealTree" already exists` bloque l'installation des dépendances.
- **Action :** Activation du protocole `[DIAGNOSTIC-ENV]`. Résolu en nettoyant le cache npm.

### HH:MM - Fin de session

- **Résumé du travail accompli :** [Liste des avancées].
- **Prochaine étape pour demain :** [Description de la prochaine action à entreprendre].
```

## SECTION 3 : PROCÉDURE D'INTÉGRATION DU JOURNAL

### 3.1. Initialisation de Session

**[PROCEDURE] Phase 1 : Ouverture du Journal Quotidien**
- **Étape 1.1 :** Obtenir la date actuelle au format `AAAA-MM-DD`
- **Étape 1.2 :** Construire le chemin `/docs/backlog/15-journal/JOURNAL-[DATE].md`
- **Étape 1.3 :** Créer ou ouvrir le fichier journal du jour
- **Étape 1.4 :** Si nouveau fichier, remplir l'en-tête avec les objectifs de la journée
- **Étape 1.5 :** Ajouter l'entrée "Début de session" avec timestamp

### 3.2. Mise à Jour Intégrée aux Protocoles

**[PROCEDURE] Phase 2 : Documentation au Fil des Protocoles**

Chaque protocole qui modifie des artefacts **doit** inclure une mise à jour du journal dans son commit atomique :

**Moments de mise à jour obligatoires :**
1. **Début de protocole :** Entrée chronologique documentant le démarrage
2. **Étapes importantes :** Décisions, obstacles, analyses significatives
3. **Fin de protocole :** Résumé des actions accomplies et résultats

**Format des entrées :**
```markdown
### HH:MM - [PROTOCOLE] [Étape/Action]

- **Action :** Description de l'action entreprise
- **Contexte :** Informations pertinentes pour la compréhension
- **Résultat :** Outcome ou décision prise
- **Artefacts :** Liens vers les artefacts créés/modifiés
```

### 3.3. Gestion des Protocoles Abandonnés

**[PROCEDURE] Phase 3 : Documentation des Échecs**

Si un protocole est abandonné en cours :
1. **Obligation :** Documenter la raison de l'abandon dans le journal
2. **Format :** Entrée explicite avec timestamp et explication
3. **Commit :** Inclure cette mise à jour dans un commit de clôture

**Exemple :**
```markdown
### HH:MM - [PLANIFICATION] Protocole abandonné

- **Raison :** PBI mal défini, nécessite clarification avec le Product Owner
- **Actions entreprises :** Analyse partielle, 2 TASK ébauchées
- **Prochaine étape :** Demande de clarification via [SCRATCHPAD-XYZ]
```

### 3.4. Automatisation Aklo

**[PROCEDURE] Phase 4 : Intégration dans les Commandes Aklo**

Les commandes `aklo` mettent automatiquement à jour le journal selon leur niveau d'assistance :

- **`full`** : Génération automatique des entrées détaillées
- **`skeleton`** : Génération de la structure d'entrée à compléter
- **`minimal`** : Simple mention de l'action avec timestamp

**Configuration :**
```bash
# Journal automatique complet (défaut)
aklo plan <PBI_ID>

# Journal automatique minimal
aklo plan <PBI_ID> --no-journal
```