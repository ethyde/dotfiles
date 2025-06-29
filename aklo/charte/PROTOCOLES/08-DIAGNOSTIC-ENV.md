---
created: 2025-06-27 19:15
version: 1
modified: 2025-06-27 20:57
---

# PROTOCOLE SPÉCIFIQUE : DIAGNOSTIC DE L'ENVIRONNEMENT

Ce protocole s'active lorsqu'une commande exécutée via le serveur MCP échoue pour une raison qui semble liée à l'environnement (répertoire de travail, permissions, dépendances corrompues) plutôt qu'à une erreur de code applicatif.

## SECTION 1 : MISSION

Diagnostiquer et corriger de manière systématique les erreurs d'environnement pour garantir la stabilité et la fiabilité des opérations automatisées.

## SECTION 2 : PROCÉDURE DE DIAGNOSTIC GÉNÉRAL

1. **[PROCEDURE] Étape 1 : Halte et Identification**
    - Stopper immédiatement toute autre action.
    - Identifier le message d'erreur exact retourné par le serveur MCP.

2. **[ANALYSE] Étape 2 : Consultation du Catalogue des Erreurs Connues**
    - Consulter la **SECTION 3** de ce document pour voir si l'erreur correspond à un cas connu.
    - Si un cas correspond, appliquer la procédure de résolution spécifique à ce cas.

3. **[ANALYSE] Étape 3 : Si l'erreur est inconnue - Diagnostic de Base**
    - Si l'erreur n'est pas cataloguée, appliquer la checklist de diagnostic de base :
        1. **Valider le Répertoire de Travail (`WORKDIR`) :** Relancer la commande de validation du `WORKDIR` (cf. `00-CADRE-GLOBAL.md`). S'assurer que toutes les commandes sont lancées depuis la racine absolue du projet. C'est la cause la plus fréquente de problèmes.
        2. **Vérifier les Permissions :** L'erreur indique-t-elle un problème de permission (`EPERM`, `EACCES`) ?
        3. **Vérifier l'État des Dépendances :** L'erreur concerne-t-elle un module manquant ou un état corrompu ?
    - **[ATTENTE_VALIDATION]** Présenter le résultat de cette checklist au `Human_Developer` avec une proposition d'action (par exemple, "L'erreur est inconnue, mais le `WORKDIR` semble incorrect. Propose de le corriger et de relancer.").

## SECTION 3 : CATALOGUE DES ERREURS CONNUES ET LEURS SOLUTIONS

### CAS N°1 : `npm error Tracker "idealTree" already exists`

- **Diagnostic :** Conflit de processus `npm` ou exécution depuis un mauvais répertoire (`WORKDIR`).
- **Procédure de Résolution :**
    1. S'assurer qu'aucun autre processus `npm` n'est en cours.
    2. Forcer la re-validation du `WORKDIR` à la racine du projet.
    3. Exécuter `npm cache clean --force` depuis la racine.
    4. Relancer la commande initiale.

### CAS N°2 : `'npm' is not recognized as an internal or external command`

- **Diagnostic :** Problème de variable d'environnement `PATH` sur le serveur d'exécution. `npm` (et donc Node.js) n'est pas accessible.
- **Procédure de Résolution :**
    1. Stopper l'opération.
    2. **[CONCLUSION]** Informer le `Human_Developer` que l'environnement d'exécution semble mal configuré et que la variable `PATH` doit être inspectée. Ce problème ne peut pas être résolu par l'agent.

### CAS N°3 : `Error: EPERM: operation not permitted` Ou `Error: EACCES: permission denied`

- **Diagnostic :** L'agent tente d'écrire ou de modifier un fichier/dossier pour lequel il n'a pas les droits nécessaires.
- **Procédure de Résolution :**
    1. Identifier précisément le fichier ou le dossier concerné.
    2. **[CONCLUSION]** Informer le `Human_Developer` du problème de permission sur la ressource identifiée. Les permissions doivent être ajustées manuellement par l'humain.

### CAS N°4 : `Error: Cannot find module 'X'`

- **Diagnostic :** L'erreur la plus probable est que la commande a été lancée depuis un sous-répertoire au lieu de la racine du projet. Moins probable, une installation de dépendances corrompue.
- **Procédure de Résolution :**
    1. Forcer la re-validation du `WORKDIR` à la racine du projet.
    2. Relancer la commande depuis cette racine.
    3. Si l'erreur persiste, supprimer `node_modules` et `package-lock.json` et relancer `npm install` depuis la racine.
