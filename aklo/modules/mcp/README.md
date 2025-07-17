# 🤖 Serveurs MCP Aklo

Serveurs MCP (Model Context Protocol) pour l'écosystème Aklo avec **logique native intelligente**.

## 🎯 Philosophie

**Logique Native-First** :
- ✅ **Shell bash/sh natif** → Serveurs légers et universels (solution principale)
- 🔄 **Node.js disponible** → Serveurs étendus avec fonctionnalités avancées (bonus)

Cette approche garantit que les serveurs MCP Aklo fonctionnent **toujours** nativement sur tout système Unix, avec Node.js comme amélioration optionnelle.

## 🚀 Installation Rapide

```bash
# Installation automatique avec détection intelligente
cd aklo/modules/mcp
./setup-mcp.sh

# Ou génération de configuration uniquement
./generate-config.sh > ~/.cursor-mcp-config.json
```

## 📋 Serveurs Disponibles

### Version Shell Native (Principale) 🥇
- **aklo-terminal** : Commandes aklo, statut projet - **0 dépendances**
- **aklo-documentation** : Lecture protocoles, recherche documentation - **0 dépendances**

### Version Node.js (Étendue) ⭐
- **aklo-terminal-node** : Fonctionnalités avancées + shell sécurisé
- **aklo-documentation-node** : Validation artefacts + recherche complexe

## 🔧 Configuration Manuelle

### Détection Automatique
```bash
# Génère automatiquement la bonne configuration
cd aklo/modules/mcp
./auto-detect.sh
```

### Configuration Node.js
```json
{
  "mcpServers": {
    "aklo-terminal": {
      "command": "sh",
      "args": ["/path/to/aklo/modules/mcp/shell-native/aklo-terminal.sh"]
    },
    "aklo-documentation": {
      "command": "sh",
      "args": ["/path/to/aklo/modules/mcp/shell-native/aklo-documentation.sh"]
    }
  }
}
```

### Configuration Node.js (Étendue)
```json
{
  "mcpServers": {
    "aklo-terminal-node": {
      "command": "/path/to/node",
      "args": ["/path/to/aklo/modules/mcp/terminal/index.js"]
    },
    "aklo-documentation-node": {
      "command": "/path/to/node",
      "args": ["/path/to/aklo/modules/mcp/documentation/index.js"]
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

**📋 Commandes Aklo disponibles via `aklo_execute` :**
- **19 types d'artefacts** : `pbi`, `task`, `debug`, `refactor`, `optimize`, `security`, `docs`, `experiment`, `scratchpad`, `meta`, `journal`, `review`, `arch`, `analysis`, `onboarding`, `deprecation`, `tracking`, `fast`, `kb`
- **Commandes système** : `status`, `init`, `plan`, `start-task`, `submit-task`, `merge-task`, `release`, `hotfix`, `cache`, `monitor`, `config`

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

## 📖 Référence Complète

**📋 [COMMANDS-REFERENCE.md](COMMANDS-REFERENCE.md)** - Référence complète de toutes les commandes Aklo avec exemples d'utilisation via MCP.

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

### Logique Native-First
- ✅ Shell natif → Solution principale (toujours disponible)
- ⭐ Node.js détecté → Serveurs étendus en bonus
- 🔄 Node.js problématique → Shell natif uniquement
- 🎯 Résultat → Fonctionne toujours, partout

## 🛠️ Scripts Utilitaires

| Script | Description |
|--------|-------------|
| `setup-mcp.sh` | Installation complète avec tests |
| `auto-detect.sh` | Détection environnement et génération config |
| `generate-config.sh` | Génération configuration JSON pure |
| `test-fallback.sh` | Tests complets du système native-first |
| `install-node.sh` | Assistant installation Node.js |
| `restart-mcp.sh` | Redémarrage des serveurs après modification |
| `watch-mcp.sh` | Surveillance automatique et redémarrage |
| `aklo-mcp.sh` | Script principal de gestion des serveurs |
| `demo-fallback.sh` | Démonstration de la logique native-first |
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
# Démonstration de la logique native-first
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

# Forcer shell natif uniquement
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

## 🗃️ Dépendance à jq et fallback natif

Certaines commandes (ex : `project_info`, `safe_shell`) utilisent `jq` pour le parsing JSON rapide et fiable. **jq est recommandé** pour des performances optimales, mais n'est pas strictement obligatoire :

- Si `jq` est absent, le système bascule automatiquement sur un parsing natif Bash (plus lent, mais compatible).
- Le fallback natif peut être forcé via la variable d'environnement `AKLO_FORCE_NO_JQ=1`.
- Le script `apps.sh` installe automatiquement `jq` lors de la configuration de l'environnement.
- Les tests d'intégration valident les deux modes (avec et sans jq).

**Résumé** :
- jq présent → parsing JSON rapide
- jq absent ou AKLO_FORCE_NO_JQ=1 → fallback natif Bash
- Couverture de tests complète sur les deux modes

## 🏗️ Architecture

```
aklo/modules/mcp/
├── setup-mcp.sh           # Installation automatique
├── auto-detect.sh         # Détection intelligente native-first
├── generate-config.sh     # Génération config native-first
├── test-fallback.sh       # Tests système
├── install-node.sh        # Assistant Node.js
├── restart-mcp.sh         # Redémarrage serveurs
├── watch-mcp.sh          # Surveillance automatique  
├── aklo-mcp.sh           # Gestion avancée
├── demo-fallback.sh      # Démonstration logique native
├── demo-multi-clients.sh # Démonstration multi-clients
├── generate-config-universal.sh # Config universelle
├── install.sh            # Installation simple
├── terminal/              # Serveur Node.js étendu
│   ├── index.js
│   ├── package.json
│   └── node_modules/
├── documentation/         # Serveur Node.js étendu
│   ├── index.js
│   ├── package.json
│   └── node_modules/
└── shell-native/          # Serveurs shell natifs (principaux)
    ├── aklo-terminal.sh
    └── aklo-documentation.sh
```

## 🎯 Avantages

### ✅ Robustesse
- Fonctionne toujours (Node.js ou shell)
- Détection automatique d'environnement
- Tests intégrés et validation

### ✅ Performance  
- Shell natif léger pour solution principale
- Serveurs Node.js pour fonctionnalités étendues
- 0 dépendances pour la solution de base

### ✅ Simplicité
- Installation en une commande
- Configuration automatique native-first
- Fonctionnement universel garanti

### ✅ Compatibilité
- macOS, Linux, Windows WSL
- Bash, Zsh, Shell POSIX natifs
- Node.js 16+ optionnel pour fonctionnalités étendues

---

**🚀 Prêt à utiliser !** Exécutez `./setup-mcp.sh` et commencez à utiliser Aklo avec Cursor.