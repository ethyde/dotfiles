# 🚀 Guide de Démarrage Rapide - MCP Aklo

## ⚡ Installation en 30 secondes

```bash
# 1. Allez dans le répertoire
cd aklo/mcp-servers

# 2. Installation automatique
./aklo-mcp.sh install

# 3. Configuration pour votre client
./aklo-mcp.sh config claude-desktop > ~/.claude_desktop_config.json
# OU
./aklo-mcp.sh config cursor  # Copiez dans Cursor Settings

# 4. Redémarrez votre client MCP
# C'est tout ! 🎉
```

## 🎯 Utilisation Immédiate

Une fois configuré, dans votre client MCP :

```
"Exécute aklo status"
"Montre-moi le protocole 02-ARCHITECTURE"  
"Liste tous les protocoles Aklo"
"Recherche 'git' dans la documentation"
```

## 🌍 Clients Supportés

| Client | Commande |
|--------|----------|
| **Claude Desktop** | `./aklo-mcp.sh config claude-desktop` |
| **Cursor** | `./aklo-mcp.sh config cursor` |
| **VS Code** | `./aklo-mcp.sh config vscode` |
| **Générique** | `./aklo-mcp.sh config generic` |
| **CLI** | `./aklo-mcp.sh config cli` |

## 🔧 Commandes Utiles

```bash
# Statut système
./aklo-mcp.sh status

# Tests rapides  
./aklo-mcp.sh test

# Démo interactive
./aklo-mcp.sh demo multi

# Aide complète
./aklo-mcp.sh help
```

## 🎭 Logique Intelligente

Le système détecte automatiquement votre environnement :

- ✅ **Node.js disponible** → Serveurs complets (9 outils)
- 🔄 **Node.js absent** → Serveurs shell natifs (5 outils)

**Résultat** : Ça marche toujours ! 🎯

## 🆘 Dépannage Express

### Problème : "Serveurs non trouvés"
```bash
./aklo-mcp.sh status  # Vérifier l'état
chmod +x shell-native/*.sh  # Réparer permissions
```

### Problème : "Node.js non compatible"
```bash
./aklo-mcp.sh config <client> --shell-only  # Forcer shell natif
```

### Problème : "Configuration invalide"
```bash
./aklo-mcp.sh config <client> | python3 -m json.tool  # Valider JSON
```

## 📱 Exemples par Client

### Claude Desktop
```json
{
  "mcpServers": {
    "aklo-terminal": {
      "command": "/path/to/node",
      "args": ["/path/to/terminal/index.js"]
    },
    "aklo-documentation": {
      "command": "/path/to/node",
      "args": ["/path/to/documentation/index.js"]
    }
  }
}
```

### Cursor
Même configuration, dans Settings > MCP Servers

### CLI Direct
```bash
echo '{"method":"tools/list"}' | ./shell-native/aklo-terminal.sh
```

---

**🎉 Vous êtes prêt ! Les serveurs MCP Aklo sont universels et robustes.**

*Besoin d'aide ? `./aklo-mcp.sh help`*