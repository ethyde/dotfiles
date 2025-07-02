# PROTOCOLE SPÉCIFIQUE : REFACTORING DE CODE

Ce protocole s'active lorsqu'une portion de code existant est identifiée comme nécessitant une amélioration de sa structure interne sans modification de son comportement externe.

## SECTION 1 : MISSION ET LIVRABLES

### 1.1. Mission

Améliorer la qualité interne du code (lisibilité, maintenabilité, performance) en appliquant des modifications de structure de manière sécurisée, c'est-à-dire sans altérer le comportement visible de l'application.

### 1.2. Livrables Attendus

1. **Rapport de Refactoring :** Un fichier `REFACTOR-[ID]-DONE.md` créé dans `/docs/backlog/05-refactor/`.
2. **Commit de Refactoring :** Un ou plusieurs `commits` contenant uniquement les modifications de refactoring.

## SECTION 2 : ARTEFACT REFACTOR - GESTION ET STRUCTURE

### 2.1. Nommage

- `REFACTOR-[ID]-[Status].md`
    - `[ID]` : Un identifiant unique généré à partir du titre et de la date (ex: `description-du-sujet-20250629`).
    - `[Status]` : Le statut du processus de refactoring.

### 2.2. Statuts

- `ANALYSIS` : Le diagnostic est en cours et la couverture de tests est en cours de vérification.
- `REFACTORING` : Le plan a été approuvé et le refactoring est en cours.
- `DONE` : Le refactoring est terminé et le `commit` a été créé.

### 2.3. Structure Obligatoire Du Fichier Refactor

```markdown
# RAPPORT DE REFACTORING : REFACTOR-[ID]
---
**Task Associée (si applicable):** [TASK-ID](../../01-tasks/TASK-ID.md)
---

## 1. Diagnostic du "Code Smell"
- **Code concerné :** (Chemin vers le fichier et lignes.)
- **Problème identifié :** (Ex: "Fonction de plus de 100 lignes", "Duplication de code", "Non-respect du principe de Responsabilité Unique".)

## 2. Stratégie de Refactoring
- **Objectif :** (Ex: "Extraire la logique métier dans une nouvelle classe `BillingService`".)
- **Plan d'action :** (Liste des étapes techniques prévues : renommages, extractions, etc.)

## 3. Preuve de Non-Régression
- **Couverture de tests initiale :** (Confirmer que le code est couvert par des tests **avant** de commencer.)
- **Résultat des tests après refactoring :** (Affirmer que 100% des tests pertinents passent après le refactoring.)
```

## SECTION 3 : PROCÉDURE DE REFACTORING

**🛫 PLAN DE VOL REFACTORING (Obligatoire avant Phase 1)**

Avant tout refactoring de code, l'agent **doit** présenter un plan détaillé :

**[PLAN_DE_VOL_REFACTORING]**
**Objectif :** Améliorer la structure interne du code sans altérer son comportement externe
**Actions prévues :**
1. Génération de l'ID unique pour le rapport de refactoring
2. Création du fichier `REFACTOR-[ID]-ANALYSIS.md` dans `/docs/backlog/05-refactor/`
3. Diagnostic du "code smell" et identification du problème structurel
4. Définition d'une stratégie de refactoring avec plan d'action détaillé
5. Vérification obligatoire de la couverture de tests existante
6. Écriture de tests manquants si nécessaire (via protocole DEVELOPPEMENT)
7. Exécution du refactoring par micro-changements avec validation continue
8. Validation de non-régression après chaque modification

**Fichiers affectés :**
- `/docs/backlog/05-refactor/REFACTOR-[ID]-ANALYSIS.md` → `REFACTORING` → `DONE`
- Fichiers de code source à refactoriser
- Possibles nouveaux fichiers de tests si couverture insuffisante
- Fichiers de tests existants (validation de non-régression)

**Commandes système :**
- `aklo new refactor "<Titre>"` : automatisation création rapport (optionnel)
- Exécution de la suite de tests avant/pendant/après refactoring
- Outils d'analyse de couverture de code
- Outils de linting et validation qualité

**Outils MCP utilisés :**
- `mcp_desktop-commander_write_file` : créer le rapport de refactoring
- `mcp_desktop-commander_edit_block` : modifier code par micro-changements
- `mcp_desktop-commander_execute_command` : tests et validation continue
- `mcp_aklo-terminal_aklo_execute` : commandes aklo (si utilisées)

**Validation requise :** ✅ OUI - Attente approbation explicite avant refactoring

1. **[ANALYSE] Phase 1 : Cadrage et Sécurisation**
    - **Action Requise :** Créer un fichier `REFACTOR-[ID]-ANALYSIS.md` dans `/docs/backlog/05-refactor/`.
    - **⚡ Automatisation `aklo` :** `aklo new refactor "<Titre de la refactorisation>"`
    - Remplir les sections "Diagnostic du Code Smell" et "Stratégie de Refactoring".
    - **Vérifier la couverture de tests.** Si elle est insuffisante, la première action doit être d'écrire les tests manquants en suivant le protocole [DEVELOPPEMENT]. **C'est un prérequis non négociable.**
    - [ATTENTE_VALIDATION] Soumettre le rapport et le plan pour validation au `Human_Developer`.

2. **[PROCEDURE] Phase 2 : Exécution du Refactoring**
    - Une fois le plan approuvé, passer le statut à `REFACTORING`.
    - **Activer le protocole [DEVELOPPEMENT] (`03-DEVELOPPEMENT.md`)** pour appliquer les changements.
    - Le cycle TDD est adapté :
        - Au lieu d'écrire un nouveau test, on s'appuie sur les tests existants.
        - Appliquer un micro-changement (ex: extraire une méthode).
        - Relancer immédiatement la suite de tests pour s'assurer qu'aucune régression n'est introduite.
        - Répéter ce cycle (petit changement -> tests) jusqu'à ce que le plan de refactoring soit complété.

3. **[CONCLUSION] Phase 3 : Finalisation**
    - Une fois le refactoring terminé et tous les tests au vert, remplir la section "Preuve de Non-Régression".
    - Suivre l'étapes 6 (Revue avant commit) du protocole [DEVELOPPEMENT]
    - Mettre à jour le rapport de refactoring au statut `DONE`.
    - Suivre l'étapes 7 (Finalisation) du protocole [DEVELOPPEMENT] pour créer le `commit`.
