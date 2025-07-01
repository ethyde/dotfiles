# Gestion Automatique des Permissions - Dotfiles

Ce document explique le système de gestion automatique des permissions pour tous les scripts du projet dotfiles.

## 🚨 Problème Résolu

**Problème :** De nombreux scripts bash/sh nécessitent d'être rendus exécutables (`chmod +x`), et il est facile d'en oublier lors d'une installation ou réinstallation.

**Solution :** Système automatisé de détection et correction des permissions avec intégration dans tous les processus d'installation.

## 🛠️ Solutions Implémentées

### 1. Script Principal de Correction (`fix-permissions.sh`)

**Usage de base :**
```bash
./fix-permissions.sh                # Corriger toutes les permissions
./fix-permissions.sh --check        # Vérifier sans modifier
./fix-permissions.sh --dry-run      # Voir ce qui serait corrigé
./fix-permissions.sh --list         # Lister les répertoires critiques
```

**Fonctionnalités :**
- ✅ Détection automatique des scripts qui doivent être exécutables
- ✅ Correction en masse des permissions
- ✅ Mode simulation (dry-run)
- ✅ Exclusion des répertoires non pertinents (node_modules, .git, etc.)
- ✅ Rapport détaillé des corrections
- ✅ Interface colorée et intuitive

**Types de fichiers détectés :**
- Scripts `.sh`
- Scripts avec shebang (`#!/bin/bash`, `#!/usr/bin/env node`, etc.)
- Binaires dans les répertoires `bin/`
- Scripts spécifiques (`install`, `aklo`, `dotbot`)

### 2. Intégration dans l'Installation

#### Installation Principale (`install`)
Le script d'installation principal corrige automatiquement les permissions avant d'exécuter dotbot :

```bash
./install  # Les permissions sont corrigées automatiquement
```

#### Setup MCP (`aklo/mcp-servers/setup-mcp.sh`)
Le setup des serveurs MCP inclut la correction des permissions :

```bash
cd aklo/mcp-servers && ./setup-mcp.sh
```

### 3. Hook Git Automatique

#### Installation du Hook
```bash
./install-git-hooks.sh              # Installer les hooks
./install-git-hooks.sh --uninstall  # Désinstaller les hooks
```

#### Fonctionnement
- **post-merge** : Corrige automatiquement les permissions après `git pull` ou `git merge`
- Transparent pour l'utilisateur
- Évite les oublis après synchronisation

### 4. Vérification Manuelle

```bash
# Vérifier l'état actuel
./fix-permissions.sh --check

# Statistiques détaillées
./fix-permissions.sh --verbose --dry-run

# Lister les répertoires critiques
./fix-permissions.sh --list
```

## 📁 Répertoires Surveillés

Le système surveille automatiquement ces répertoires critiques :

| Répertoire | Description | Scripts Typiques |
|------------|-------------|------------------|
| `bin/` | Binaires utilisateur | `toggle_push.sh` |
| `aklo/bin/` | Binaires Aklo | `aklo` |
| `aklo/tests/` | Tests Aklo | `run_tests.sh`, `test_*.sh` |
| `aklo/mcp-servers/` | Serveurs MCP | `setup-mcp.sh`, `*.sh` |
| `aklo/ux-improvements/` | Améliorations UX | `install-ux.sh`, `*.sh` |
| `shell/docs/` | Documentation shell | `demo_*.sh` |
| `dotbot/bin/` | Binaires dotbot | `dotbot` |

## 🔄 Workflows Automatisés

### Installation Fraîche
```bash
git clone <repo>
cd dotfiles
./install                    # ✅ Permissions corrigées automatiquement
./install-git-hooks.sh       # ✅ Hooks installés pour l'avenir
```

### Mise à Jour
```bash
git pull                     # ✅ Hook post-merge corrige automatiquement
# ou
./fix-permissions.sh         # ✅ Correction manuelle si nécessaire
```

### Développement
```bash
# Après ajout de nouveaux scripts
./fix-permissions.sh --check  # Vérifier
./fix-permissions.sh           # Corriger si nécessaire
```

## 🎯 Avantages du Système

### ✅ Prévention Complète
- **Installation** : Permissions corrigées automatiquement
- **Mise à jour** : Hook Git maintient les permissions
- **Développement** : Outils de vérification disponibles

### ✅ Zéro Configuration
- Aucune intervention manuelle requise
- Fonctionne immédiatement après installation
- Compatible avec tous les workflows Git

### ✅ Visibilité Totale
- Rapports détaillés des corrections
- Mode vérification sans modification
- Statistiques complètes

### ✅ Robustesse
- Exclusion intelligente des répertoires
- Gestion d'erreur gracieuse
- Compatible macOS/Linux

## 🔧 Maintenance

### Ajouter un Nouveau Script

1. **Créer le script** avec l'extension appropriée (`.sh`) ou shebang
2. **Le placer** dans un répertoire surveillé
3. **Exécuter** `./fix-permissions.sh` (ou attendre le prochain git pull)

### Exclure un Répertoire

Modifier `fix-permissions.sh`, section `exclude_patterns` :

```bash
local exclude_patterns=(
    "*/\.git/*"
    "*/node_modules/*"
    "*/mon_nouveau_repertoire/*"  # Ajouter ici
)
```

### Ajouter un Type de Fichier

Modifier `fix-permissions.sh`, fonction `should_be_executable` :

```bash
# Nouveaux types de scripts
case "$filename" in
    "install"|"aklo"|"dotbot"|"mon_script")  # Ajouter ici
        return 0
        ;;
esac
```

## 📊 Monitoring

### Vérification Périodique
```bash
# Vérification complète
./fix-permissions.sh --check

# Vérification silencieuse (pour scripts)
./fix-permissions.sh --dry-run > /dev/null 2>&1 && echo "OK" || echo "CORRECTIONS NÉCESSAIRES"
```

### Statistiques
```bash
# Compter les scripts surveillés
./fix-permissions.sh --list

# Rapport détaillé
./fix-permissions.sh --verbose --dry-run
```

## 🆘 Dépannage

### Permissions Non Corrigées

1. **Vérifier le répertoire** : `./fix-permissions.sh --list`
2. **Mode verbeux** : `./fix-permissions.sh --verbose --check`
3. **Correction forcée** : `./fix-permissions.sh --fix`

### Hook Git Non Fonctionnel

1. **Vérifier l'installation** : `ls -la .git/hooks/post-merge`
2. **Réinstaller** : `./install-git-hooks.sh`
3. **Test manuel** : `.git/hooks/post-merge`

### Script Non Détecté

1. **Vérifier les critères** : Extension `.sh`, shebang, répertoire `bin/`
2. **Ajouter à la liste** : Modifier `should_be_executable()` dans `fix-permissions.sh`
3. **Test** : `./fix-permissions.sh --check`

---

## 🎉 Résultat

**Plus jamais d'oubli de permissions !** Le système gère automatiquement tous les scripts, de l'installation initiale aux mises à jour futures.

**Commandes essentielles à retenir :**
```bash
./fix-permissions.sh          # Correction manuelle
./install-git-hooks.sh        # Installation des hooks
./fix-permissions.sh --check  # Vérification
``` 