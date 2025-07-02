# PROTOCOLE SPÉCIFIQUE : DIAGNOSTIC ET CORRECTION DE BUGS

Ce protocole s'active lorsqu'un bug est identifié. Son objectif est de produire un diagnostic traçable et une correction validée via la création et la gestion d'un Rapport de Débogage formel.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Diagnostiquer de manière systématique la cause racine (`root cause`) d'un comportement inattendu, proposer un plan de correction validé, et superviser son implémentation.

### 1.2. Livrables Attendus

1. **Rapport de Débogage :** Un fichier `DEBUG-[ID]-RESOLVED.md` complet, créé dans `/docs/backlog/04-debug/`.
2. **Commit de Correction :** Un `commit` contenant le correctif et un test de non-régression, produit en suivant le protocole [DEVELOPPEMENT].

## SECTION 2 : ARTEFACT DEBUG - GESTION ET STRUCTURE

### 2.1. Nommage

- `DEBUG-[ID]-[Status].md`
    - `[ID]` : Un identifiant unique généré à partir du titre et de la date (ex: `description-du-sujet-20250629`).
    - `[Status]` : Le statut de l'investigation.

### 2.2. Statuts

- `INVESTIGATING` : L'analyse est en cours.
- `AWAITING_FIX` : La cause racine est identifiée et un plan de correction attend la validation du `Human_Developer`.
- `RESOLVED` : Le correctif a été implémenté, validé et le `commit` a été créé.

### 2.3. Structure Obligatoire Du Fichier Debug

```markdown
# RAPPORT DE DÉBOGAGE : DEBUG-[ID]
---
**Task Associée (si applicable):** [TASK-ID](../../01-tasks/TASK-ID.md)
---

## 1. Description du Problème et Étapes de Reproduction

- **Problème Constaté :** (Description claire du comportement inattendu.)
- **Étapes pour Reproduire :**
    1. ...
    2. ...

## 2. Hypothèses Initiales

1.  **Hypothèse A :** ...
2.  **Hypothèse B :** ...

## 3. Journal d'Investigation (Itératif)

#### Itération X - Test de l'Hypothèse Y
-   **Action (Instrumentation) :** (Ex: Ajout de logs pour vérifier la valeur de Z.)
-   **Résultats (Logs Obtenus) :** (Copier/coller des logs pertinents.)
-   **Analyse :** (Interprétation des résultats.)
-   **Conclusion :** (Hypothèse Y validée/invalidée.)

## 4. Analyse de la Cause Racine (Root Cause Analysis)

*(Description technique et précise de la source du bug, une fois identifiée.)*

## 5. Plan de Correction Proposé

*(Description de la solution technique à implémenter pour corriger le bug, incluant la description du test de non-régression à écrire en premier.)*
```

## SECTION 3 : PROCÉDURE DE DÉBOGAGE

**🛫 PLAN DE VOL DEBOGAGE (Obligatoire avant Phase 1)**

Avant tout diagnostic de bug, l'agent **doit** présenter un plan détaillé :

**[PLAN_DE_VOL_DEBOGAGE]**
**Objectif :** Diagnostiquer et corriger un bug de manière systématique et traçable
**Actions prévues :**
1. Génération de l'ID unique pour le rapport de débogage
2. Création du fichier `DEBUG-[ID]-INVESTIGATING.md` dans `/docs/backlog/04-debug/`
3. Documentation du problème et des étapes de reproduction
4. Formulation d'hypothèses initiales basées sur l'analyse du code
5. Investigation itérative avec instrumentation (logs, tests, debugging)
6. Identification de la cause racine (root cause analysis)
7. Proposition d'un plan de correction avec test de non-régression
8. Implémentation via protocole DEVELOPPEMENT après validation

**Fichiers affectés :**
- `/docs/backlog/04-debug/DEBUG-[ID]-INVESTIGATING.md` → `AWAITING_FIX` → `RESOLVED`
- Fichiers de code source pour instrumentation temporaire (logs)
- Fichiers de tests pour validation et non-régression
- Possibles fichiers de correction selon diagnostic

**Commandes système :**
- `aklo new debug "<Titre>"` : automatisation création rapport (optionnel)
- Exécution de tests pour reproduction du bug
- Ajout de logs temporaires pour investigation
- Exécution d'outils de debugging selon stack technique

**Outils MCP utilisés :**
- `mcp_desktop-commander_write_file` : créer le rapport de débogage
- `mcp_desktop-commander_edit_block` : ajouter instrumentation temporaire
- `mcp_desktop-commander_execute_command` : tests et debugging
- `mcp_aklo-terminal_aklo_execute` : commandes aklo (si utilisées)

**Validation requise :** ✅ OUI - Attente approbation explicite avant investigation

1. **[PROCEDURE] Phase 1 : Initialisation**
      - **Action Requise :** Créer un nouveau fichier `DEBUG-[ID]-INVESTIGATING.md` dans `/docs/backlog/04-debug/`.
      - **⚡ Automatisation `aklo` :** `aklo new debug "<Titre du problème>"`
      - Remplir les sections "1. Description du Problème et Étapes de Reproduction" et "2. Hypothèses Initiales".

2. **[PROCEDURE] Phase 2 : Diagnostic Itératif**
      - Remplir le "3. Journal d'Investigation" de manière itérative.
      - Pour chaque hypothèse, proposer une action d'instrumentation, exécuter le scénario, coller les résultats, et analyser la conclusion.
      - Continuer ce cycle jusqu'à ce que la cause racine soit identifiée avec certitude.

3. **[ANALYSE] Phase 3 : Formalisation du Plan de Correction**
      - Remplir les sections "4. Analyse de la Cause Racine" et "5. Plan de Correction Proposé".
      - **[ATTENTE_VALIDATION]** Soumettre le rapport complet pour validation au `Human_Developer`
      - Passer le statut du rapport à `AWAITING_FIX`.

4. **[CONCLUSION] Phase 4 : Implémentation de la Correction**
      - Une fois le plan de correction approuvé, **activer le protocole [DEVELOPPEMENT]**.
      - Suivre sa procédure à la lettre, en commençant par l'écriture du test de non-régression qui doit échouer avant la correction.
      - Une fois l'étape [ATTENTE_VALIDATION] du protocole de développement approuvée par le `Human_Developer` :
	      1. Mettre à jour le rapport de débogage au statut `RESOLVED`.
	      2. Activer le protocole [KNOWLEDGE-BASE] pour déterminer si l'investigation a produit une connaissance qui mérite d'être centralisée.
	      3. Créer le `commit` de correction, qui enregistre le travail finalisé.
