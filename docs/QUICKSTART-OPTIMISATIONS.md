# ⚡ Démarrage Rapide - Optimisations

Guide de démarrage en 5 minutes pour profiter immédiatement des nouvelles optimisations.

## 🚀 Installation

```bash
# Installation automatique (inclut les optimisations)
./install

# Redémarrer le shell pour activer
exec $SHELL
```

## 🎯 Première utilisation

### 1. Configuration personnalisée (2 min)
```bash
# Assistant de configuration interactif
dotfiles-config wizard

# Résultat : Configuration adaptée à vos préférences
```

### 2. Créer votre première branche optimisée (1 min)
```bash
# Assistant création de branche
gbw

# Ou création directe
gbs "feat/PROJ-123/nouvelle-feature"
```

### 3. Commit intelligent (30 sec)
```bash
# Commit avec émoji automatique
gac "implement user authentication"
# → ✨ feat: implement user authentication
```

### 4. Découvrir vos statistiques (30 sec)
```bash
# Dashboard de vos statistiques
dotfiles-stats
```

## 🔥 Commandes essentielles

| Commande | Description | Exemple |
|----------|-------------|---------|
| `gbw` | Assistant création branche | `gbw` → Interface interactive |
| `gac "msg"` | Commit intelligent | `gac "fix login bug"` |
| `gbs "branch"` | Création branche validée | `gbs "feat/AUTH-123/oauth"` |
| `gbd "branch"` | Suppression sécurisée | `gbd "old-feature"` |
| `dotfiles-stats` | Dashboard statistiques | Affiche votre activité |
| `dotfiles-config` | Configuration | `dotfiles-config wizard` |

## ⚡ Auto-complétion

```bash
# Tapez et appuyez sur TAB
gbd <TAB>        # → Liste vos branches
gbs <TAB>        # → Templates de noms
dotfiles-<TAB>   # → Toutes les commandes dotfiles
```

## 🛡️ Sécurité automatique

✅ **Activée par défaut** :
- Validation des noms de branches
- Backups automatiques avant suppression
- Protection des branches importantes
- Vérification avant opérations destructives

## 📊 Monitoring automatique

✅ **Collecte automatique** :
- Temps d'exécution des commandes
- Fréquence d'utilisation
- Taux de succès/erreurs
- Projets les plus actifs

Consultez avec : `dotfiles-stats`, `dotfiles-perf`, `dotfiles-insights`

## 🎨 Personnalisation rapide

```bash
# Désactiver les émojis
dotfiles-config set EMOJI_ENABLED false

# Changer le préfixe JIRA par défaut
dotfiles-config set JIRA_PREFIX "MYPROJECT"

# Activer le push automatique
dotfiles-config set AUTO_PUSH true

# Voir toute la configuration
dotfiles-config show
```

## 🔄 Workflow optimisé type

```bash
# 1. Nouvelle feature
gbw                                    # Assistant interactif
# → Crée : feat/PROJ-123/user-auth

# 2. Développement
gac "add login form"                   # → ✨ feat: add login form
gac "implement validation"             # → ✨ feat: implement validation
gac "fix: resolve edge case"           # → 🐛 fix: resolve edge case

# 3. Finalisation
gri                                    # Rebase interactif optimisé
gbd "feat/PROJ-123/user-auth"         # Suppression sécurisée après merge
```

## 🆘 Aide rapide

```bash
# Aide générale
gac --help
gbs --help

# Configuration
dotfiles-config --help
dotfiles-hooks --help

# Statistiques
dotfiles-stats
dotfiles-insights
```

## 🚨 Dépannage express

### Auto-complétion ne fonctionne pas
```bash
# Recharger les complétions
source ~/.shell_completions
```

### Commandes lentes
```bash
# Vérifier le cache
dotfiles-config get LAZY_LOADING
# Devrait être "true"
```

### Pas de statistiques
```bash
# Vérifier l'activation
dotfiles-config get ANALYTICS_ENABLED
# Devrait être "true"
```

## 📖 Documentation complète

- **[Guide complet](OPTIMISATIONS.md)** - Documentation détaillée
- **[Configuration](OPTIMISATIONS.md#%EF%B8%8F-module-configuration)** - Tous les paramètres
- **[Sécurité](OPTIMISATIONS.md#%EF%B8%8F-module-sécurité)** - Fonctions de protection
- **[Analytics](OPTIMISATIONS.md#-module-analytics)** - Monitoring avancé

---

**🎉 Félicitations !** Vous êtes maintenant prêt à utiliser un système Git ultra-optimisé. 

**💡 Conseil** : Utilisez `dotfiles-insights` après quelques jours pour obtenir des recommandations personnalisées. 