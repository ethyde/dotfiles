# Guide de Développement - Serveurs MCP Aklo

Ce guide explique comment développer et maintenir les serveurs MCP Aklo sans rencontrer de problèmes de cache ou de processus obsolètes.

## 🚨 Problème Typique : Cache des Serveurs

**Symptôme :** Après modification du code des serveurs MCP, les changements ne sont pas pris en compte.

**Cause :** Les serveurs MCP continuent d'utiliser l'ancienne version en mémoire.

**Solution :** Redémarrer les serveurs après chaque modification.

## 🛠️ Solutions Disponibles

### 1. Redémarrage Manuel (Solution Immédiate)

```bash
cd aklo/mcp-servers
./restart-mcp.sh
```

**Utilisation :** Après chaque modification des fichiers :
- `documentation/index.js`
- `terminal/index.js`
- `shell-native/aklo-documentation.sh`
- `shell-native/aklo-terminal.sh`

### 2. Mode Développement (Solution Automatique)

```bash
cd aklo/mcp-servers
./watch-mcp.sh
```

**Fonctionnalités :**
- Surveillance automatique des fichiers
- Redémarrage automatique lors des changements
- Affichage des modifications détectées
- Mode interactif avec Ctrl+C pour arrêter

**Options :**
```bash
./watch-mcp.sh -i 1          # Vérification chaque seconde
./watch-mcp.sh -l            # Lister les fichiers surveillés
./watch-mcp.sh --help        # Aide complète
```

### 3. Vérification de l'État du Serveur

```bash
# Via l'outil MCP (si serveur actif)
mcp_aklo-documentation_server_info

# Via les processus système
ps aux | grep -E "(aklo.*mcp|mcp.*aklo)"
```

## 📋 Workflow de Développement Recommandé

### Développement Ponctuel

1. **Modifier le code** des serveurs MCP
2. **Redémarrer** : `./restart-mcp.sh`
3. **Tester** la modification
4. **Répéter** si nécessaire

### Développement Intensif

1. **Lancer la surveillance** : `./watch-mcp.sh`
2. **Modifier le code** (redémarrage automatique)
3. **Tester** les modifications
4. **Arrêter la surveillance** : `Ctrl+C`

## 🔍 Débogage

### Vérifier les Processus MCP

```bash
# Lister tous les processus MCP
ps aux | grep -i mcp

# Tuer manuellement si nécessaire
kill <PID>
```

### Vérifier les Logs

```bash
# Logs des serveurs Node.js (si disponibles)
tail -f ~/.cursor/logs/mcp-*.log

# Test direct des serveurs
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | node documentation/index.js
```

### Vérifier la Configuration

```bash
# Configuration MCP Cursor
cat ~/.cursor-mcp-config.json

# Régénérer la configuration
./setup-mcp.sh
```

## 📝 Bonnes Pratiques

### ✅ À Faire

- **Toujours redémarrer** après modification du code
- **Utiliser le mode watch** pour le développement intensif
- **Tester les modifications** immédiatement
- **Vérifier les processus** en cas de problème
- **Documenter** les nouvelles fonctionnalités

### ❌ À Éviter

- **Ne pas redémarrer** après modification
- **Laisser des processus zombies** en arrière-plan
- **Modifier plusieurs serveurs** sans redémarrage
- **Ignorer les erreurs** de démarrage
- **Forcer l'arrêt** sans cleanup

## 🔧 Scripts Utilitaires

| Script | Usage | Description |
|--------|-------|-------------|
| `restart-mcp.sh` | `./restart-mcp.sh` | Redémarrage manuel des serveurs |
| `watch-mcp.sh` | `./watch-mcp.sh` | Surveillance automatique |
| `setup-mcp.sh` | `./setup-mcp.sh` | Configuration initiale |
| `auto-detect.sh` | `./auto-detect.sh` | Détection environnement |

## 🚀 Fonctionnalités Avancées

### Surveillance Personnalisée

```bash
# Surveillance avec intervalle personnalisé
./watch-mcp.sh -i 0.5  # Vérification toutes les 500ms

# Surveillance en arrière-plan
nohup ./watch-mcp.sh > watch.log 2>&1 &
```

### Intégration avec l'Éditeur

Ajoutez ces raccourcis à votre éditeur :

**VS Code/Cursor :**
```json
{
  "key": "ctrl+shift+r",
  "command": "workbench.action.terminal.sendSequence",
  "args": { "text": "cd aklo/mcp-servers && ./restart-mcp.sh\n" }
}
```

## 📊 Monitoring

### Informations Serveur

Les serveurs exposent maintenant un outil `server_info` qui affiche :
- Version du serveur
- Heure de démarrage
- Uptime
- PID du processus
- Fichiers surveillés avec timestamps

### Métriques Utiles

```bash
# Nombre de redémarrages aujourd'hui
grep "$(date +%Y-%m-%d)" watch.log | grep -c "Redémarrage"

# Processus MCP actifs
ps aux | grep -E "(aklo.*mcp|mcp.*aklo)" | wc -l

# Dernière modification des serveurs
stat -f "%Sm" documentation/index.js terminal/index.js
```

## 🆘 Dépannage

### Serveurs qui ne Redémarrent Pas

1. **Vérifier les permissions** : `ls -la *.sh`
2. **Forcer l'arrêt** : `killall -9 node`
3. **Relancer manuellement** : `./setup-mcp.sh`

### 🔌 Problème de Reconnexion Cursor/MCP

**Symptôme :** Après `./restart-mcp.sh`, les outils MCP ne répondent plus dans Cursor.

**Cause :** Cursor ne détecte pas automatiquement le redémarrage des serveurs MCP et garde les anciennes connexions "mortes".

**Solutions :**

1. **Redémarrage Cursor (Recommandé)**
   ```bash
   ./restart-mcp.sh
   # → Fermer Cursor complètement (⌘+Q sur Mac)
   # → Rouvrir Cursor
   # → Les connexions MCP se rétablissent automatiquement
   ```

2. **Vérification de l'État**
   ```bash
   # Vérifier que les serveurs sont bien redémarrés
   ps aux | grep -E "(aklo/mcp-servers|mcp-servers.*aklo)"
   
   # Si aucun processus : les serveurs redémarreront au prochain appel MCP
   # Si processus présents : problème de connexion Cursor
   ```

**Note Technique :** C'est une limitation architecturale de Cursor qui ne monitore pas les processus MCP. La reconnexion automatique n'est pas implémentée.

### Modifications Non Prises en Compte

1. **Vérifier l'uptime** : Utiliser `server_info`
2. **Redémarrer explicitement** : `./restart-mcp.sh`
3. **Vérifier les processus** : `ps aux | grep mcp`

### Erreurs de Configuration

1. **Régénérer la config** : `./setup-mcp.sh`
2. **Vérifier les chemins** : `./auto-detect.sh`
3. **Tester les serveurs** : Scripts de test intégrés

---

**💡 Conseil :** En cas de doute, utilisez toujours `./restart-mcp.sh` - c'est rapide et résout la plupart des problèmes de cache. 