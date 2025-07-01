# 🏠 My Dotfiles

Configuration moderne et améliorée pour un environnement de développement productif.

## 🚀 Installation rapide

```bash
# Cloner le repo
git clone https://github.com/votre-username/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Installation complète
./install
```

**📚 [Guide d'installation détaillé](docs/installation.md)**

## ✨ Fonctionnalités principales

### 🐚 **Shell amélioré** ([documentation](shell/README.md))
- Fonctions SSH, NVM et Git avec affichage coloré
- Mode silencieux compatible Powerlevel10k
- Gestion automatique des clés SSH et versions Node.js

### 🤖 **Protocole Aklo** ([documentation](aklo/README.md))
- Système de gouvernance de développement
- Serveurs MCP pour intégration Cursor
- Workflows automatisés et templates

### ⚙️ **Configuration automatique**
- Liens symboliques via Dotbot
- Support Bash et Zsh complet
- Variables d'environnement partagées

## 📚 Documentation

| Composant | Description | Documentation |
|-----------|-------------|---------------|
| **🏠 Vue d'ensemble** | Ce fichier | [README.md](README.md) |
| **📖 Documentation** | Guide centralisé | [docs/](docs/) |
| **🐚 Shell** | Configuration shell avancée | [shell/README.md](shell/README.md) |
| **🤖 Aklo** | Protocole de développement | [aklo/README.md](aklo/README.md) |
| **🔧 MCP** | Serveurs Model Context Protocol | [aklo/mcp-servers/README.md](aklo/mcp-servers/README.md) |

### 🎯 Guides rapides
- **[Installation](docs/installation.md)** - Installation et configuration
- **[Migration](docs/migration.md)** - Migrer depuis une config existante

Sample of my `.bash_profile.local` but file are not in VCS to prevent miss-usage of indentity.

```
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="____ ________"
GIT_AUTHOR_EMAIL="____@____.__"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

# Set the credentials (modifies ~/.gitconfig)
git config --global user.name "$GIT_AUTHOR_NAME"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

Sample gitconfig.local
```
[user]
	name = <user name>
	email = <user@email.com>
```

# usefull snippet

make symlink for heynote file `ln -s "/Library/CloudStorage/OneDrive-Personnel/private/heynote/buffer.txt" "/Library/Application Support/Heynote/buffer.txt"`

Squash Commit current branch from Master : `git rebase -i `git merge-base HEAD master``
ou depuis vraiment le début de la branch `git rebase -i `git merge-base --fork-point master``