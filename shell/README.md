# 🐚 Configuration Shell Améliorée

Configuration shell complète avec fonctions colorées et améliorées pour **SSH**, **NVM/Node.js** et **Git**.

## 📁 Structure des fichiers

### 🔧 Fichiers de configuration principaux
- **`.profile`** - Variables d'environnement et PATH (compatible tous shells)
- **`.bashrc`** - Configuration Bash
- **`.bash_profile`** - Profile Bash 
- **`.zshrc`** - Configuration Zsh (dans la racine du projet)

### ⚡ Fonctions et aliases
- **`.shell_functions`** - Fonctions shell de base
- **`.shell_functions_enhanced`** - Fonctions améliorées avec couleurs et émojis
- **`.shell_aliases`** - Aliases partagés
- **`.shell_display`** - Fonctions d'affichage coloré

### 🚀 Scripts d'initialisation
- **`.shell_interactive_setup`** - Configuration automatique SSH/NVM au démarrage

## 🎯 Fonctionnalités

### 🔐 SSH Amélioré
| Commande | Description |
|----------|-------------|
| `ssh-status` | Statut de l'agent avec détails des clés |
| `ssh-start` | Démarrage de l'agent avec feedback |
| `ssh-load` | Chargement de toutes les clés |
| `ssh-reload` | Rechargement complet de l'environnement |

### 🟢 NVM/Node.js Amélioré
| Commande | Description |
|----------|-------------|
| `node-version` | Affichage stylé des versions Node/npm |
| `nvm-list` | Liste des versions avec formatage |
| `nvm-install <version>` | Installation avec feedback détaillé |
| `nvm-use <version>` | Changement avec installation automatique |
| `cd` (amélioré) | Navigation avec gestion automatique `.nvmrc` |

### 📝 Git Amélioré
| Commande | Description |
|----------|-------------|
| `gac [message]` | Commit avec génération automatique de message |
| `gbs <branche>` | Création de branche avec validation |
| `gbd <branche>` | Suppression propre locale + distante |
| `gri [cible]` | Rebase interactif avec analyse |

### 🔄 Autres
| Commande | Description |
|----------|-------------|
| `reload` | Rechargement shell avec statut SSH/NVM |

## 🎨 Exemples d'affichage

### Avant (basique)
```
echo "Version Node.js 'lts/jod' non installée, installation..."
```

### Après (amélioré)
```
⚠️  Version lts/jod non installée
📦 Installation automatique...
✅ Node.js lts/jod installé et activé
```

## 🚀 Installation

Les fichiers sont automatiquement liés via **dotbot** :

```bash
./install
```

## ⚙️ Configuration

### Mode silencieux (défaut)
- Démarrage automatique sans messages (compatible Powerlevel10k)
- Commandes manuelles toujours colorées

### Mode verbose (optionnel)
```bash
export DOTFILES_VERBOSE_SSH=true    # Messages SSH au démarrage
export DOTFILES_VERBOSE_NVM=true    # Messages NVM au démarrage
```

## 🧪 Test et démonstration

```bash
# Démonstration complète
./shell/docs/demo_enhanced_commands.sh

# Test rapide d'affichage
./shell/docs/demo_display.sh
```

## 📚 Format de branches Git

Pour les messages automatiques, utilisez le format :
```
type/JIRA-123/description
```

**Exemples :**
- `feat/PROJ-456/user-auth` → `✨ feat(PROJ-456): user auth`
- `fix/BUG-789/login-issue` → `🐛 fix(BUG-789): login issue`

## 🎯 Workflow recommandé

1. **Créer une branche** : `gbs feat/PROJ-123/awesome-feature`
2. **Développer et commiter** : `gac` (message auto) ou `gac "custom message"`
3. **Rebase si nécessaire** : `gri main`
4. **Supprimer après merge** : `gbd feat/PROJ-123/awesome-feature`

## 🛠️ Maintenance

- **Modifier les fonctions** : Éditez directement dans `dotfiles/shell/`
- **Ajouter des couleurs** : Utilisez les fonctions dans `.shell_display`
- **Nouveaux aliases** : Ajoutez dans `.shell_functions_enhanced`

---

**Configuration shell moderne avec le meilleur des deux mondes : silence au démarrage, couleurs à l'usage ! 🎉** 