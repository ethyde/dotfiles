# 🤖 Serveurs MCP Aklo - Support Universel

Serveurs MCP (Model Context Protocol) pour l'écosystème Aklo avec **support multi-clients** et **fallback intelligent**.

## 🌍 Clients MCP Supportés

| Client | Status | Configuration |
|--------|--------|---------------|
| **Claude Desktop** | ✅ Testé | `~/.claude_desktop_config.json` |
| **Cursor** | ✅ Testé | Settings > MCP Servers |
| **VS Code** | ✅ Compatible | Extension MCP + `settings.json` |
| **Continue Dev** | ✅ Compatible | Configuration MCP standard |
| **Zed Editor** | ✅ Compatible | Extension MCP |
| **CLI Direct** | ✅ Testé | `echo JSON \| serveur` |
| **API Custom** | ✅ Compatible | Protocole MCP standard |

## 🚀 Installation Universelle

### Génération Automatique pour Votre Client

```bash
# Configuration pour Claude Desktop
./generate-config-universal.sh claude-desktop

# Configuration pour Cursor  
./generate-config-universal.sh cursor

# Configuration pour VS Code
./generate-config-universal.sh vscode

# Voir toutes les configurations
./generate-config-universal.sh all

# Test en ligne de commande
./generate-config-universal.sh cli
```

### Options Avancées

```bash
# Forcer l'utilisation de Node.js
./generate-config-universal.sh claude-desktop --node-only

# Forcer l'utilisation des serveurs shell
./generate-config-universal.sh cursor --shell-only

# Aide complète
./generate-config-universal.sh --help
```

## 📱 Configuration par Client

### Claude Desktop

```bash
# Générer la configuration
./generate-config-universal.sh claude-desktop > ~/.claude_desktop_config.json

# Redémarrer Claude Desktop
```

**Exemple de configuration générée** :
```json
{
  "mcpServers": {
    "aklo-terminal": {
      "command": "/path/to/node",
      "args": ["/path/to/aklo/modules/mcp/terminal/index.js"]
    },
    "aklo-documentation": {
      "command": "/path/to/node", 
      "args": ["/path/to/aklo/modules/mcp/documentation/index.js"]
    }
  }
}
```

### Cursor

```bash
# Générer la configuration
./generate-config-universal.sh cursor
```

1. Ouvrir Cursor
2. Aller dans Settings > MCP Servers
3. Coller la configuration générée
4. Redémarrer Cursor

### VS Code

```bash
# Générer la configuration
./generate-config-universal.sh vscode
```

1. Installer l'extension MCP pour VS Code
2. Ajouter la configuration à `settings.json`
3. Redémarrer VS Code

### Continue Dev

```bash
# Configuration générique compatible
./generate-config-universal.sh generic
```

Ajouter à votre configuration Continue Dev.

### Test en Ligne de Commande

```bash
# Obtenir les commandes de test
./generate-config-universal.sh cli

# Exemple de test direct
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./shell-native/aklo-terminal.sh
```

## 🛠️ Serveurs Disponibles

### 🔧 Serveur Terminal (`aklo-terminal`)

**Outils Node.js (complets)** :
- `aklo_execute` - Exécution commandes aklo complètes
- `aklo_status` - Statut projet détaillé
- `safe_shell` - Shell sécurisé avec filtres
- `project_info` - Informations projet complètes

**Outils Shell (fallback)** :
- `aklo_execute_shell` - Commandes aklo de base
- `aklo_status_shell` - Statut projet simple

### 📚 Serveur Documentation (`aklo-documentation`)

**Outils Node.js (complets)** :
- `read_protocol` - Lecture protocoles avec validation
- `list_protocols` - Liste tous les protocoles
- `search_documentation` - Recherche avancée
- `read_artefact` - Lecture artefacts projet
- `validate_artefact` - Validation artefacts

**Outils Shell (fallback)** :
- `read_protocol_shell` - Lecture protocoles basique
- `list_protocols_shell` - Liste protocoles
- `search_documentation_shell` - Recherche simple

## 🎯 Logique de Fallback Intelligent

```
Détection automatique de l'environnement :

Node.js ≥v16 + npm disponible
    ↓
✅ SERVEURS NODE.JS
   (Fonctionnalités complètes)

Node.js absent/incompatible
    ↓  
🔄 SERVEURS SHELL NATIFS
   (Fonctionnalités de base, zéro dépendance)
```

## 💡 Exemples d'Utilisation Multi-Clients

### Dans Claude Desktop
```
Utilisateur: "Exécute aklo status"
Claude: *utilise aklo_execute avec la commande status*

Utilisateur: "Montre-moi le protocole 02-ARCHITECTURE"  
Claude: *utilise read_protocol avec protocol_number="02"*
```

### Dans Cursor
```
Utilisateur: "Lance aklo propose-pbi 'Nouvelle feature'"
Cursor: *utilise aklo_execute pour créer un nouveau PBI*

Utilisateur: "Recherche 'git' dans la documentation Aklo"
Cursor: *utilise search_documentation avec keywords="git"*
```

### En Ligne de Commande
```bash
# Statut du projet
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"aklo_status","arguments":{}}}' | \
  node terminal/index.js

# Lister les protocoles
echo '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"list_protocols","arguments":{}}}' | \
  node documentation/index.js
```

## 🧪 Tests Multi-Clients

### Test Automatique
```bash
# Test complet tous clients
./test-fallback.sh

# Test serveurs uniquement
./setup-mcp.sh --test-only
```

### Test Manuel par Client

```bash
# Test Claude Desktop
echo '{"method":"tools/list"}' | node terminal/index.js

# Test shell natif (fallback universel)
echo '{"method":"tools/list"}' | ./shell-native/aklo-terminal.sh

# Test avec curl (API directe)
curl -X POST http://localhost:PORT/mcp \
  -H "Content-Type: application/json" \
  -d '{"method":"tools/list"}'
```

## 🔧 Intégration Personnalisée

### Client MCP Custom

```javascript
// Exemple d'intégration JavaScript
const { spawn } = require('child_process');

const akloTerminal = spawn('node', ['/path/to/aklo/mcp-servers/terminal/index.js']);

// Envoyer requête MCP
akloTerminal.stdin.write(JSON.stringify({
  jsonrpc: "2.0",
  id: 1,
  method: "tools/call",
  params: {
    name: "aklo_status",
    arguments: {}
  }
}));
```

### API REST Wrapper

```python
# Exemple wrapper Python
import subprocess
import json

def call_aklo_mcp(tool_name, arguments={}):
    request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "tools/call",
        "params": {
            "name": tool_name,
            "arguments": arguments
        }
    }
    
    process = subprocess.Popen(
        ['node', '/path/to/aklo/mcp-servers/terminal/index.js'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        text=True
    )
    
    stdout, _ = process.communicate(json.dumps(request))
    return json.loads(stdout)

# Utilisation
status = call_aklo_mcp("aklo_status")
print(status)
```

## 🌟 Avantages Multi-Clients

### ✅ **Universalité**
- Compatible avec tous les clients MCP standard
- Protocole ouvert et extensible
- Pas de vendor lock-in

### ✅ **Flexibilité**
- Node.js pour performance maximale
- Shell natif pour compatibilité universelle
- Configuration automatique par client

### ✅ **Robustesse**
- Fallback intelligent automatique
- Tests multi-environnements
- Validation croisée

### ✅ **Évolutivité**
- Ajout facile de nouveaux clients
- Extension des fonctionnalités
- Intégrations personnalisées

## 📋 Aide Rapide

```bash
# Voir tous les clients supportés
./generate-config-universal.sh --help

# Configuration pour votre client préféré
./generate-config-universal.sh [CLIENT]

# Test direct sans installation
echo '{"method":"tools/list"}' | ./shell-native/aklo-terminal.sh
```

---

**🚀 Les serveurs MCP Aklo : Universels par conception, robustes par nature !**

*Compatible avec Claude Desktop, Cursor, VS Code, Continue Dev, Zed, et tout client MCP standard.*