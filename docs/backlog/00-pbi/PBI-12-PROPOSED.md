# PBI-12 : Ajouter commandes MCP étendues à aklo

## 📋 Description

Étendre la commande `aklo mcp` existante avec deux nouvelles sous-commandes pour améliorer l'expérience utilisateur et la gestion des serveurs MCP.

## 🎯 Objectif Métier

- **Simplicité** : Accès direct aux configurations MCP via aklo
- **Flexibilité** : Support configuration simple et avancée
- **Monitoring** : Visibilité sur l'état des serveurs MCP
- **Cohérence** : Interface unifiée pour toutes les opérations MCP

## 🔍 Analyse Actuelle

### Commandes MCP Existantes
- ✅ `aklo mcp setup` → `setup-mcp.sh`
- ✅ `aklo mcp restart` → `restart-mcp.sh`
- ✅ `aklo mcp watch` → `watch-mcp.sh`

### Scripts MCP Disponibles Non Intégrés
- `generate-config.sh` : Configuration simple et rapide
- `generate-config-universal.sh` : Configuration multi-clients avec options
- `aklo-mcp.sh status` : État détaillé des serveurs MCP

## 🎯 Nouvelles Commandes à Ajouter

### 1. `aklo mcp config` - Génération de Configuration

**Comportement** :
- **Sans arguments** : `generate-config.sh` (rapide et simple)
- **Avec arguments** : `generate-config-universal.sh` avec arguments passés

**Exemples d'usage** :
```bash
# Configuration simple (JSON pur)
aklo mcp config > ~/.cursor-mcp.json

# Configuration pour Claude Desktop
aklo mcp config claude-desktop

# Configuration pour Cursor avec shell uniquement
aklo mcp config cursor --shell-only

# Toutes les configurations
aklo mcp config all

# Aide
aklo mcp config --help
```

### 2. `aklo mcp status` - État des Serveurs

**Comportement** :
- Appelle `aklo-mcp.sh status`
- Affiche l'état détaillé des serveurs MCP
- Inclut métriques et diagnostics

**Exemples d'usage** :
```bash
# État des serveurs MCP
aklo mcp status

# État avec détails étendus (si supporté)
aklo mcp status --detailed
```

## 🛠️ Implémentation Technique

### Architecture Scripts MCP
**Confirmation des dépendances** :
- ✅ `setup-mcp.sh` → utilise `auto-detect.sh`
- ✅ `install.sh`, `install-node.sh` → scripts d'assistance
- ✅ Tous les scripts sont dans `modules/mcp/`

### Modifications Requises

#### 1. Mise à Jour `bin/aklo`
```bash
# Dans command_mcp()
case "$action" in
    "config")
        shift  # Enlever 'config'
        if [ $# -eq 0 ]; then
            # Sans arguments : script simple
            "${modules_dir}/mcp/generate-config.sh"
        else
            # Avec arguments : script universel
            "${modules_dir}/mcp/generate-config-universal.sh" "$@"
        fi
        ;;
    "status")
        shift  # Enlever 'status'
        "${modules_dir}/mcp/aklo-mcp.sh" status "$@"
        ;;
    # ... autres commandes existantes
esac
```

#### 2. Mise à Jour Documentation
- Ajouter les nouvelles commandes dans le help
- Mettre à jour README.md avec exemples
- Documenter les options avancées

#### 3. Mise à Jour Chemins
- Vérifier que tous les chemins pointent vers `modules/mcp/`
- S'assurer que `aklo-mcp.sh` existe et fonctionne

## 📊 Critères d'Acceptation

- [ ] `aklo mcp config` sans arguments utilise `generate-config.sh`
- [ ] `aklo mcp config <args>` utilise `generate-config-universal.sh`
- [ ] `aklo mcp status` utilise `aklo-mcp.sh status`
- [ ] Tous les arguments sont correctement passés
- [ ] Messages d'aide mis à jour
- [ ] Documentation README.md mise à jour
- [ ] Tests fonctionnels pour toutes les nouvelles commandes
- [ ] Rétrocompatibilité préservée

## 🔗 Dépendances

- Scripts existants dans `modules/mcp/`
- Vérification existence `aklo-mcp.sh`
- Mise à jour chemins si nécessaire

## 📈 Impact Attendu

- **UX** : +200% (accès direct aux configs)
- **Adoption** : +150% (simplicité d'usage)
- **Efficacité** : +100% (moins de navigation manuelle)
- **Cohérence** : +300% (interface unifiée)

## 🗓️ Estimation

**Complexité** : Faible (1-2 jours)
**Priorité** : Moyenne (amélioration UX)

---

**Status** : PROPOSED
**Created** : 2025-01-28
**Owner** : CLI Team