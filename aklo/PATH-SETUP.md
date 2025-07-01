# Configuration PATH pour Aklo

## 🎯 Objectif

Permettre d'utiliser `aklo <command>` depuis n'importe où au lieu du chemin complet `/Users/eplouvie/Projets/dotfiles/aklo/bin/aklo`.

## ✅ Vérification Actuelle

Votre système est **déjà configuré** ! Vous avez un lien symbolique fonctionnel :

```bash
$ which aklo
/Users/eplouvie/.local/bin/aklo

$ ls -la /Users/eplouvie/.local/bin/aklo
lrwxr-xr-x@ 1 eplouvie staff 46 Jun 30 08:54 /Users/eplouvie/.local/bin/aklo -> /Users/eplouvie/Projets/dotfiles/aklo/bin/aklo
```

## 🚀 Utilisation Simplifiée

Vous pouvez maintenant utiliser Aklo directement :

```bash
# Au lieu de :
/Users/eplouvie/Projets/dotfiles/aklo/bin/aklo propose-pbi "Nouvelle fonctionnalité"

# Utilisez simplement :
aklo propose-pbi "Nouvelle fonctionnalité"
```

## 🔧 Configuration pour d'Autres Utilisateurs

Si vous installez ces dotfiles sur une autre machine, voici les options :

### Option 1 : Lien Symbolique (Recommandée)

```bash
# Créer le répertoire s'il n'existe pas
mkdir -p ~/.local/bin

# Créer le lien symbolique
ln -sf ~/Projets/dotfiles/aklo/bin/aklo ~/.local/bin/aklo

# Vérifier que ~/.local/bin est dans le PATH
echo $PATH | grep -q "$HOME/.local/bin" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
```

### Option 2 : Ajout Direct au PATH

Ajouter à votre `~/.zshrc` ou `~/.bashrc` :

```bash
# Aklo Protocol
export PATH="/Users/eplouvie/Projets/dotfiles/aklo/bin:$PATH"
```

### Option 3 : Alias

Ajouter à votre `~/.zshrc` ou `~/.bashrc` :

```bash
# Aklo Protocol
alias aklo='/Users/eplouvie/Projets/dotfiles/aklo/bin/aklo'
```

## 🔍 Vérification

Pour vérifier que la configuration fonctionne :

```bash
# 1. Vérifier la présence dans le PATH
which aklo

# 2. Tester la version
head -6 $(which aklo) | grep Version

# 3. Tester une commande
cd /path/to/your/project
aklo propose-pbi "Test PATH"
```

## 🎯 Avantages du Lien Symbolique (Option 1)

- ✅ **Synchronisation automatique** : Pointe toujours vers la dernière version
- ✅ **Portable** : Fonctionne sur différentes machines
- ✅ **Propre** : Pas de modification du PATH global
- ✅ **Standard** : `~/.local/bin` est un répertoire standard pour les binaires utilisateur

## 🔄 Mise à Jour

Avec un lien symbolique, les mises à jour d'Aklo dans les dotfiles sont automatiquement disponibles. Aucune action requise !

## 🆘 Dépannage

### Commande non trouvée

```bash
# Vérifier que ~/.local/bin est dans le PATH
echo $PATH | grep -q "$HOME/.local/bin" && echo "✅ OK" || echo "❌ Manquant"

# L'ajouter si nécessaire
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Lien cassé

```bash
# Recréer le lien
ln -sf ~/Projets/dotfiles/aklo/bin/aklo ~/.local/bin/aklo
```

### Version obsolète

```bash
# Vérifier vers quoi pointe le lien
readlink ~/.local/bin/aklo

# Recréer si nécessaire
ln -sf ~/Projets/dotfiles/aklo/bin/aklo ~/.local/bin/aklo
```

---

**État actuel** : ✅ Configuré et fonctionnel  
**Recommandation** : Aucune action requise  
**Version** : 1.5+security 