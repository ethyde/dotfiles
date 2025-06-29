---
created: 2025-06-28 12:35
modified: 2025-06-28 12:57
---
# PROTOCOLE SPÉCIFIQUE : JOURNAL DE TRAVAIL

Ce protocole a pour but de maintenir un journal de bord quotidien des activités, décisions et réflexions pour assurer la traçabilité du travail et faciliter la reprise de contexte.

## SECTION 1 : MISSION ET LIVRABLE

### 1.1. Mission

Documenter de manière chronologique les actions entreprises, les hypothèses testées, les décisions prises et les obstacles rencontrés au cours d'une journée de travail.

### 1.2. Livrable Attendu

1.  **Entrée de Journal Quotidien :** Un unique fichier `JOURNAL-[DATE].md` créé dans `/docs/backlog/15-journal/`.

## SECTION 2 : ARTEFACT JOURNAL - GESTION ET STRUCTURE

### 2.1. Nommage

-   `JOURNAL-[DATE].md`
    -   `[DATE]` : La date du jour au format `AAAA-MM-DD`.

### 2.2. Statuts

-   Un journal a un statut unique et continu : **`IN_PROGRESS`** pendant la journée, et **`ARCHIVED`** à la fin de la journée.

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

## SECTION 3 : PROCÉDURE DE GESTION DU JOURNAL

1.  **[PROCEDURE] Phase 1 : Initialisation (Action Fiabilisée)**
    -   **Étape 1.1 : Obtenir la Date Actuelle.** Exécuter une commande système fiable pour obtenir la date du jour.
        -   *Exemple de commande pour l'agent :* `system.getCurrentDate(format='AAAA-MM-DD')`.
    -   **Étape 1.2 : Construire le Chemin.** Utiliser la date **obtenue à l'étape précédente** pour construire le chemin complet du fichier journal (ex: `/docs/backlog/15-journal/2025-06-28.md`).
    -   **Étape 1.3 : Création du Fichier.** Créer (ou ouvrir) le fichier à cet emplacement.
    -   **Étape 1.4 : Remplir l'En-tête.** Remplir l'en-tête du journal, notamment les objectifs de la journée.

2.  **[PROCEDURE] Phase 2 : Documentation Continue**
    -   Tout au long de la journée, ajouter des entrées chronologiques dans le fichier du jour.
    -   Faire des liens explicites vers les autres artefacts de la Charte.

3.  **[CONCLUSION] Phase 3 : Clôture**
    -   À la fin de la journée, remplir une entrée finale "Fin de session".
    -   Le fichier est automatiquement considéré comme `ARCHIVED`.