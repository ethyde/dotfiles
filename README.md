# 🏠 My Dotfiles

Configuration moderne et améliorée pour un environnement de développement productif.

## 🚀 Installation rapide

```bash
# Cloner le repo
git clone https://github.com/votre-username/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Installer les applications (optionnel)
./apps.sh

# Créer les liens symboliques
./install
```

## ✨ Fonctionnalités principales

### 🐚 **Shell amélioré** (voir [shell/README.md](shell/README.md))
- Fonctions SSH, NVM et Git avec affichage coloré
- Mode silencieux compatible Powerlevel10k
- Gestion automatique des clés SSH et versions Node.js

### ⚙️ **Configuration automatique**
- Liens symboliques via dotbot
- Support Bash et Zsh
- Variables d'environnement partagées

### 🛠️ **Outils intégrés**
- Script Aklo pour la gestion de projets
- Templates Git personnalisés
- Aliases et fonctions optimisées

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