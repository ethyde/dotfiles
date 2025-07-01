# 🚀 Guide d'Installation

Guide complet pour installer et configurer les dotfiles.

## 📋 Prérequis

### Systèmes supportés
- ✅ **macOS** (recommandé)
- ✅ **Linux** (Ubuntu, Debian, CentOS, etc.)
- ✅ **Windows** (WSL2)

### Outils requis
- **Git** (pour cloner le repository)
- **Bash** ou **Zsh** (shell principal)
- **Python 3** (pour Dotbot)

### Outils optionnels
- **Node.js ≥16** (pour serveurs MCP complets)
- **Oh My Zsh** (pour configuration Zsh avancée)
- **Powerlevel10k** (pour prompt avancé)

## ⚡ Installation rapide

### 1. Cloner le repository
```bash
git clone https://github.com/votre-username/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Installation automatique
```bash
./install
```

Cette commande :
- ✅ Lie tous les fichiers de configuration
- ✅ Sauvegarde les configurations existantes
- ✅ Configure Bash et Zsh
- ✅ Installe les fonctions améliorées

### 3. Redémarrer le terminal
```bash
# Ou simplement
reload
```

## 🔧 Configuration avancée

### Shell personnalisé
```bash
# Fichiers de configuration locale (non versionnés)
touch ~/.bash_profile.local    # Variables d'environnement privées
touch ~/.zshrc.local          # Configuration Zsh locale
```

### Serveurs MCP (pour Cursor)
```bash
cd aklo/mcp-servers
./setup-mcp.sh
```

### Variables d'environnement recommandées
```bash
# Dans ~/.bash_profile.local
export VAULT_ADDR="https://vault.example.com"
export GIT_AUTHOR_NAME="Votre Nom"
export GIT_AUTHOR_EMAIL="email@example.com"

# Aliases personnels
alias loginaws="aws sso login --profile production"
alias wakeup="caffeinate -d"
```

## 🧪 Vérification de l'installation

### Test des fonctions shell
```bash
# Démonstration complète
./shell/docs/demo_enhanced_commands.sh

# Test SSH
ssh-status

# Test NVM (si installé)
node-version

# Test Git
gac "Test installation"
```

### Test des serveurs MCP
```bash
cd aklo/mcp-servers
./test-fallback.sh
```

## 🛠️ Résolution de problèmes

### Shell ne démarre pas
```bash
# Vérifier la syntaxe
bash -n ~/.bashrc
zsh -n ~/.zshrc

# Mode debug
bash -x ~/.bashrc
```

### Fonctions manquantes
```bash
# Recharger la configuration
source ~/.bashrc  # ou ~/.zshrc
# ou
reload
```

### Serveurs MCP non détectés
```bash
# Forcer fallback shell
cd aklo/mcp-servers
export PATH="/usr/bin:/bin" && ./auto-detect.sh
```

## 📚 Étapes suivantes

1. **[Configuration Shell](../shell/README.md)** - Découvrir les fonctions avancées
2. **[Protocole Aklo](../aklo/README.md)** - Comprendre la gouvernance de développement
3. **[Serveurs MCP](../aklo/mcp-servers/README.md)** - Intégration avec Cursor
4. **[Migration](./migration.md)** - Migrer depuis une configuration existante

---

**🎉 Installation terminée !** Votre environnement de développement est maintenant optimisé.