---
version: 1
created: 2025-06-28 10:07
modified: 2025-06-28 10:07
---

# FICHIER DE CONFIGURATION DU PROJET

Ce document définit les conventions spécifiques à ce projet. Les protocoles liront ce fichier pour adapter leurs actions.

## 1. Conventions de Versioning

-   **Schéma de version :** `SemVer` | `CalVer` | `Autre`
    -   *Exemple de valeur :* `SemVer`
-   **Format du tag Git :**
    -   *Exemple de valeur :* `v%M.%m.%p` (pour `v1.2.0`) ou `v%Y.%m.%d` (pour `v2025.06.28`)

## 2. Conventions de Branching (Git)

-   **Branche de développement principale :**
    -   *Exemple de valeur :* `develop`
-   **Branche de production (stable) :**
    -   *Exemple de valeur :* `main`
-   **Format des branches de feature :**
    -   *Exemple de valeur :* `feature/task-%pbi_id-%task_id`
-   **Utilisation de branches de release :** `Oui` | `Non`
    -   *Exemple de valeur :* `Oui`
-   **Format des branches de release :**
    -   *Exemple de valeur :* `release/%version`