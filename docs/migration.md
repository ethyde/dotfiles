# 🔄 Guide de Migration

Guide pour migrer depuis une configuration existante ou mettre à jour les dotfiles.

## 📋 Types de migration

### 🆕 **Nouvelle installation** (recommandé)
Si vous n'avez pas de dotfiles existants, suivez le [Guide d'installation](./installation.md).

### 🔧 **Migration depuis dotfiles existants**
Si vous avez déjà des configurations personnalisées.

### ⬆️ **Mise à jour des dotfiles**
Si vous avez déjà cette configuration et voulez la mettre à jour.

## 🔧 Migration depuis dotfiles existants

### 1. Sauvegarde de l'existant
```bash
# Créer un dossier de sauvegarde
mkdir -p ~/dotfiles-backup/$(date +%Y%m%d)
cd ~/dotfiles-backup/$(date +%Y%m%d)

# Sauvegarder les fichiers principaux
cp ~/.bashrc bashrc.bak 2>/dev/null || true
cp ~/.bash_profile bash_profile.bak 2>/dev/null || true
cp ~/.zshrc zshrc.bak 2>/dev/null || true
cp ~/.profile profile.bak 2>/dev/null || true
cp ~/.gitconfig gitconfig.bak 2>/dev/null || true
cp ~/.ssh/config ssh_config.bak 2>/dev/null || true

echo "✅ Sauvegarde créée dans $(pwd)"
```

### 2. Extraire la configuration personnelle
```bash
# Identifier les éléments à préserver
echo "🔍 Configuration personnelle à préserver :"
echo "----------------------------------------"

# Variables d'environnement
grep -E "^export " ~/.bashrc ~/.bash_profile 2>/dev/null | grep -v "PATH" | head -10
echo ""

# Aliases personnels
grep -E "^alias " ~/.bashrc ~/.zshrc 2>/dev/null | head -10
echo ""

# Fonctions personnelles
grep -E "^[a-zA-Z_][a-zA-Z0-9_]*\(\)" ~/.bashrc ~/.zshrc 2>/dev/null | head -5
```

### 3. Installation des nouveaux dotfiles
```bash
# Cloner et installer
git clone https://github.com/votre-username/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install
```

### 4. Migrer la configuration personnelle
```bash
# Créer les fichiers locaux
touch ~/.bash_profile.local
touch ~/.zshrc.local

# Exemple de migration
cat >> ~/.bash_profile.local << 'EOF'
# === Configuration personnelle migrée ===
export VAULT_ADDR="https://vault.company.com"
export AWS_PROFILE="production"

# Aliases personnels
alias ll="ls -la"
alias grep="grep --color=auto"

# Fonctions personnelles
function myfunction() {
    echo "Ma fonction personnalisée"
}
EOF
```

## ⬆️ Mise à jour des dotfiles existants

### 1. Mise à jour du code
```bash
cd ~/.dotfiles
git pull origin master
```

### 2. Réinstallation
```bash
./install
```

### 3. Vérification
```bash
# Tester la configuration
reload
ssh-status
node-version  # si NVM installé
```

## 🔍 Migration de configurations spécifiques

### Git
```bash
# Préserver la config Git existante
cp ~/.gitconfig ~/.dotfiles/git/gitconfig.local

# Ou ajouter à ~/.bash_profile.local
cat >> ~/.bash_profile.local << 'EOF'
# Configuration Git personnelle
export GIT_AUTHOR_NAME="Votre Nom"
export GIT_AUTHOR_EMAIL="email@company.com"
EOF
```

### SSH
```bash
# Préserver la config SSH
cp ~/.ssh/config ~/.ssh/config.personal

# Puis inclure dans la nouvelle config SSH
echo "Include ~/.ssh/config.personal" >> ~/.dotfiles/ssh/config
```

### Zsh (Oh My Zsh)
```bash
# Si vous avez Oh My Zsh avec des plugins personnalisés
echo "ZSH_CUSTOM_PLUGINS=(votre-plugin autre-plugin)" >> ~/.zshrc.local
echo "plugins+=(votre-plugin autre-plugin)" >> ~/.zshrc.local
```

## 🛠️ Résolution de conflits

### Conflits de fichiers
```bash
# Si Dotbot signale des conflits
cd ~/.dotfiles

# Voir les conflits
./install --verbose

# Forcer l'écrasement (ATTENTION : sauvegardez d'abord)
./install --force
```

### Conflits de PATH
```bash
# Si le PATH est cassé après migration
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
source ~/.profile
```

### Conflits de shell
```bash
# Si le shell ne démarre plus
# Utilisez un shell de secours
/bin/bash --norc --noprofile

# Puis diagnostiquez
bash -x ~/.bashrc
```

## 📋 Checklist post-migration

### ✅ **Fonctionnement de base**
- [ ] Terminal démarre sans erreur
- [ ] `reload` fonctionne
- [ ] Variables d'environnement présentes

### ✅ **Fonctions avancées**
- [ ] `ssh-status` affiche les clés
- [ ] `node-version` (si NVM installé)
- [ ] `gac` pour commits Git

### ✅ **Configuration personnelle**
- [ ] Variables d'environnement privées
- [ ] Aliases personnels fonctionnent
- [ ] Connexions SSH/AWS/Vault

### ✅ **Intégrations**
- [ ] Serveurs MCP (si utilisés)
- [ ] Oh My Zsh/Powerlevel10k (si utilisés)
- [ ] Outils de développement

## 🆘 Rollback d'urgence

Si quelque chose ne va pas :

```bash
# Restaurer la sauvegarde
cd ~/dotfiles-backup/$(ls -1 ~/dotfiles-backup | tail -1)
cp bashrc.bak ~/.bashrc
cp bash_profile.bak ~/.bash_profile
cp zshrc.bak ~/.zshrc
cp profile.bak ~/.profile

# Redémarrer le terminal
exec $SHELL
```

## 📚 Ressources

- **[Installation](./installation.md)** - Guide d'installation complète
- **[Configuration Shell](../shell/README.md)** - Fonctions avancées
- **[Protocole Aklo](../aklo/README.md)** - Gouvernance de développement
- **[Support](../README.md#support)** - Obtenir de l'aide

---

**🎯 Migration réussie !** Votre environnement est maintenant à jour avec les dernières améliorations.