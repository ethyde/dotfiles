# 🤖 Serveurs MCP Aklo

Serveurs MCP (Model Context Protocol) pour l'écosystème Aklo avec **fallback intelligent** automatique.

## 🎯 Philosophie

**Logique de Fallback Intelligent** :
- ✅ **Node.js détecté + compatible** → Serveurs Node.js complets
- 🔄 **Node.js absent/incompatible** → Serveurs Shell natifs (fallback)

Cette approche garantit que les serveurs MCP Aklo fonctionnent **toujours**, même sans Node.js.

## 🚀 Installation Rapide

```bash
# Installation automatique avec détection intelligente
./setup-mcp.sh

# Ou génération de configuration uniquement
./generate-config.sh > ~/.cursor-mcp-config.json
```

## 📋 Serveurs Disponibles

### Version Node.js (Complète)
- **aklo-terminal** : Exécution commandes aklo, statut projet, shell sécurisé
- **aklo-documentation** : Lecture protocoles, recherche documentation, validation artefacts

### Version Shell Native (Fallback)
- **aklo-terminal-shell** : Commandes aklo de base, statut projet
- **aklo-documentation-shell** : Lecture protocoles, recherche simple

## 🔧 Configuration Manuelle

### Détection Automatique
```bash
# Génère automatiquement la bonne configuration
cd aklo/mcp-servers
./auto-detect.sh
```

### Configuration Node.js
```json
{
  "mcpServers": {
    "aklo-terminal": {
      "command": "/path/to/node",
      "args": ["/path/to/aklo/mcp-servers/terminal/index.js"]
    },
    "aklo-documentation": {
      "command": "/path/to/node",
      "args": ["/path/to/aklo/mcp-servers/documentation/index.js"]
    }
  }
}
```

### Configuration Shell Natif
```json
{
  "mcpServers": {
    "aklo-terminal-shell": {
      "command": "sh",
      "args": ["/path/to/aklo/mcp-servers/shell-native/aklo-terminal.sh"]
    },
    "aklo-documentation-shell": {
      "command": "sh",
      "args": ["/path/to/aklo/mcp-servers/shell-native/aklo-documentation.sh"]
    }
  }
}
```

## 🧪 Tests et Validation

### Test Complet du Système
```bash
./test-fallback.sh
```

### Test des Serveurs Uniquement
```bash
./setup-mcp.sh --test-only
```

### Test Manuel des Serveurs Shell
```bash
# Test serveur terminal
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./shell-native/aklo-terminal.sh

# Test serveur documentation  
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | ./shell-native/aklo-documentation.sh
```

## 📚 Outils Disponibles

### Serveur Terminal (`aklo-terminal`)

| Outil | Description | Paramètres |
|-------|-------------|------------|
| `aklo_execute` | Exécute une commande aklo | `command`, `args` |
| `aklo_status` | Statut du projet aklo | - |
| `safe_shell` | Exécution shell sécurisée | `command` |
| `project_info` | Informations projet complètes | - |

### Serveur Documentation (`aklo-documentation`)

| Outil | Description | Paramètres |
|-------|-------------|------------|
| `read_protocol` | Lit un protocole spécifique | `protocol_name` (requis), `section`, `charte_path` |
| `list_protocols` | Liste tous les protocoles | `charte_path` |
| `search_documentation` | Recherche dans la documentation | `query` (requis), `scope`, `charte_path` |
| `read_artefact` | Lit un artefact projet | `artefact_path` (requis), `extract_metadata` |
| `project_documentation_summary` | Génère un résumé de la documentation | `project_path` (requis), `include_artefacts` |
| `validate_artefact` | Valide un artefact | `artefact_path` (requis), `artefact_type` (requis) |
| `server_info` | Informations sur le serveur MCP | - |

## 🔍 Détection d'Environnement

Le système détecte automatiquement :

### Node.js Compatible
- ✅ Node.js >= v16
- ✅ npm disponible
- ✅ Dépendances installées

### Versions LTS Supportées
- `lts/hydrogen` (Node.js 18)
- `lts/iron` (Node.js 20)  
- `lts/jod` (Node.js 22)

### Fallback Automatique
- ❌ Node.js absent → Shell natif
- ❌ Version trop ancienne → Shell natif
- ❌ npm manquant → Shell natif
- ❌ Dépendances cassées → Shell natif

## 🛠️ Scripts Utilitaires

| Script | Description |
|--------|-------------|
| `setup-mcp.sh` | Installation complète avec tests |
| `auto-detect.sh` | Détection environnement et génération config |
| `generate-config.sh` | Génération configuration JSON pure |
| `test-fallback.sh` | Tests complets du système fallback |
| `install-node.sh` | Assistant installation Node.js |
| `restart-mcp.sh` | Redémarrage des serveurs après modification |
| `watch-mcp.sh` | Surveillance automatique et redémarrage |
| `aklo-mcp.sh` | Script principal de gestion des serveurs |
| `demo-fallback.sh` | Démonstration du système de fallback |
| `demo-multi-clients.sh` | Démonstration multi-clients |
| `generate-config-universal.sh` | Configuration universelle multi-environnements |
| `install.sh` | Installation simple des dépendances npm |

## 🔄 Gestion des Serveurs

### Redémarrage après Modification
```bash
# Redémarre automatiquement tous les serveurs MCP
./restart-mcp.sh
```

### Surveillance Continue
```bash  
# Surveillance et redémarrage automatique en cas de modification
./watch-mcp.sh
```

### Gestion Avancée
```bash
# Script principal de gestion
./aklo-mcp.sh status    # État des serveurs
./aklo-mcp.sh restart   # Redémarrage
./aklo-mcp.sh logs      # Logs des serveurs
```

### Démonstrations
```bash
# Démonstration du système de fallback
./demo-fallback.sh

# Démonstration multi-clients
./demo-multi-clients.sh
```

## 💡 Utilisation dans Cursor

### Installation
1. Exécutez `./setup-mcp.sh`
2. Copiez la configuration générée
3. Ajoutez-la aux paramètres MCP de Cursor
4. Redémarrez Cursor

### Commandes d'Exemple
```
# Exécution commandes aklo
"Exécute aklo status"
"Lance aklo propose-pbi 'Nouvelle fonctionnalité'"

# Documentation
"Montre-moi le protocole 02-ARCHITECTURE"
"Liste tous les protocoles Aklo"
"Recherche 'git' dans la documentation"

# Statut projet
"Quel est le statut du projet ?"
"Combien de PBI sont dans le backlog ?"
```

## 🔧 Dépannage

### Serveurs Node.js ne Fonctionnent Pas
```bash
# Vérifier Node.js
node --version
npm --version

# Réinstaller dépendances
cd terminal && npm install
cd ../documentation && npm install

# Forcer fallback shell
export PATH="/usr/bin:/bin" && ./auto-detect.sh
```

### Serveurs Shell ne Répondent Pas
```bash
# Vérifier permissions
chmod +x shell-native/*.sh

# Test direct
echo '{"method":"tools/list"}' | ./shell-native/aklo-terminal.sh
```

### Configuration JSON Invalide
```bash
# Générer configuration propre
./generate-config.sh > config.json

# Valider JSON
python3 -m json.tool config.json
```

## 🏗️ Architecture

```
aklo/mcp-servers/
├── setup-mcp.sh           # Installation automatique
├── auto-detect.sh         # Détection intelligente
├── generate-config.sh     # Génération config pure
├── test-fallback.sh       # Tests système
├── install-node.sh        # Assistant Node.js
├── restart-mcp.sh        # Redémarrage serveurs
├── watch-mcp.sh          # Surveillance automatique  
├── aklo-mcp.sh           # Gestion avancée
├── demo-fallback.sh      # Démonstration fallback
├── demo-multi-clients.sh # Démonstration multi-clients
├── generate-config-universal.sh # Config universelle
├── install.sh            # Installation simple
├── terminal/              # Serveur Node.js terminal
│   ├── index.js
│   ├── package.json
│   └── node_modules/
├── documentation/         # Serveur Node.js documentation
│   ├── index.js
│   ├── package.json
│   └── node_modules/
└── shell-native/          # Serveurs shell fallback
    ├── aklo-terminal.sh
    └── aklo-documentation.sh
```

## 🎯 Avantages

### ✅ Robustesse
- Fonctionne toujours (Node.js ou shell)
- Détection automatique d'environnement
- Tests intégrés et validation

### ✅ Performance  
- Serveurs Node.js pour fonctionnalités complètes
- Shell natif léger pour cas basiques
- Pas de dépendances externes pour fallback

### ✅ Simplicité
- Installation en une commande
- Configuration automatique
- Fallback transparent

### ✅ Compatibilité
- macOS, Linux, Windows WSL
- Bash, Zsh, Shell POSIX
- Node.js 16+ ou aucune dépendance

---

**🚀 Prêt à utiliser !** Exécutez `./setup-mcp.sh` et commencez à utiliser Aklo avec Cursor.