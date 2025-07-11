#!/usr/bin/env bash
#==============================================================================
# Démonstration multi-clients MCP Aklo
# Montre comment utiliser les serveurs avec différents clients
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════╗
║              🌍 MCP AKLO MULTI-CLIENTS                   ║
║        Démonstration universelle du protocole MCP        ║
╚══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

demo_claude_desktop() {
    echo -e "\n${BLUE}📱 CLAUDE DESKTOP${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    echo -e "${YELLOW}Configuration :${NC}"
    echo "Fichier: ~/.claude_desktop_config.json"
    echo ""
    
    ./generate-config-universal.sh claude-desktop | grep -A 10 "{"
    
    echo -e "\n${YELLOW}Utilisation :${NC}"
    cat << 'EOF'
Dans Claude Desktop, vous pouvez dire :
• "Exécute aklo status"
• "Montre-moi le protocole 02-ARCHITECTURE"
• "Liste tous les protocoles Aklo"
• "Quel est le statut du projet ?"
EOF
}

demo_cursor() {
    echo -e "\n${BLUE}🖱️  CURSOR${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    echo -e "${YELLOW}Configuration :${NC}"
    echo "Settings > MCP Servers"
    echo ""
    
    ./generate-config-universal.sh cursor | grep -A 10 "{"
    
    echo -e "\n${YELLOW}Utilisation :${NC}"
    cat << 'EOF'
Dans Cursor, vous pouvez utiliser :
• "Lance aklo propose-pbi 'Nouvelle fonctionnalité'"
• "Recherche 'git' dans la documentation Aklo"
• "Valide cet artefact selon les protocoles Aklo"
EOF
}

demo_vscode() {
    echo -e "\n${BLUE}📝 VS CODE${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    echo -e "${YELLOW}Configuration :${NC}"
    echo "Extension MCP + settings.json"
    echo ""
    
    ./generate-config-universal.sh vscode | grep -A 15 "{"
    
    echo -e "\n${YELLOW}Prérequis :${NC}"
    echo "• Installer l'extension MCP pour VS Code"
    echo "• Ajouter la configuration à settings.json"
}

demo_cli() {
    echo -e "\n${BLUE}💻 LIGNE DE COMMANDE${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    echo -e "${YELLOW}Test direct des serveurs :${NC}"
    echo ""
    
    # Test serveur shell (toujours disponible)
    echo -e "${GREEN}Test serveur terminal shell :${NC}"
    echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | \
        ./shell-native/aklo-terminal.sh | \
        grep -o '"name":"[^"]*"' | \
        head -2 | \
        sed 's/"name":"/✅ /' | \
        sed 's/"$//'
    
    echo -e "\n${GREEN}Test serveur documentation shell :${NC}"
    echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | \
        ./shell-native/aklo-documentation.sh | \
        grep -o '"name":"[^"]*"' | \
        head -2 | \
        sed 's/"name":"/✅ /' | \
        sed 's/"$//'
    
    echo -e "\n${YELLOW}Commandes générées :${NC}"
    ./generate-config-universal.sh cli | tail -6
}

demo_custom_integration() {
    echo -e "\n${BLUE}🔧 INTÉGRATIONS PERSONNALISÉES${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    echo -e "${YELLOW}Exemple JavaScript :${NC}"
    cat << 'EOF'
const { spawn } = require('child_process');

const akloServer = spawn('node', ['./terminal/index.js']);

akloServer.stdin.write(JSON.stringify({
  jsonrpc: "2.0",
  id: 1,
  method: "tools/call",
  params: {
    name: "aklo_status",
    arguments: {}
  }
}));
EOF
    
    echo -e "\n${YELLOW}Exemple Python :${NC}"
    cat << 'EOF'
import subprocess, json

def call_aklo(tool, args={}):
    request = {
        "jsonrpc": "2.0", "id": 1,
        "method": "tools/call",
        "params": {"name": tool, "arguments": args}
    }
    
    proc = subprocess.run(
        ['node', './terminal/index.js'],
        input=json.dumps(request),
        capture_output=True, text=True
    )
    
    return json.loads(proc.stdout)

status = call_aklo("aklo_status")
EOF
    
    echo -e "\n${YELLOW}Exemple cURL (si serveur HTTP) :${NC}"
    cat << 'EOF'
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "aklo_status",
      "arguments": {}
    }
  }'
EOF
}

demo_comparison() {
    echo -e "\n${BLUE}⚖️  COMPARAISON DES CLIENTS${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    cat << EOF
${YELLOW}Client MCP${NC}          ${YELLOW}Avantages${NC}                    ${YELLOW}Cas d'usage${NC}
─────────────────────────────────────────────────────────────
${GREEN}Claude Desktop${NC}     Interface native          Chat conversationnel
${GREEN}Cursor${NC}             Intégration IDE           Développement assisté  
${GREEN}VS Code${NC}            Écosystème riche          Édition collaborative
${GREEN}Continue Dev${NC}       Focus développement       Coding en continu
${GREEN}CLI Direct${NC}         Automatisation           Scripts et CI/CD
${GREEN}API Custom${NC}         Intégration sur mesure    Applications métier

${CYAN}🎯 Tous partagent le même protocole MCP standard !${NC}
EOF
}

demo_fallback_universal() {
    echo -e "\n${BLUE}🔄 FALLBACK UNIVERSEL${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    echo -e "${YELLOW}Logique intelligente pour tous les clients :${NC}"
    cat << EOF

${GREEN}Environnement optimal${NC} (Node.js ≥v16 + npm)
    ↓
🚀 Serveurs Node.js complets
   • aklo_execute (4 outils)
   • aklo_documentation (5 outils)
   • Validation JSON avancée
   • Gestion d'erreurs sophistiquée

${YELLOW}Environnement minimal${NC} (Shell uniquement)
    ↓  
🐚 Serveurs Shell natifs
   • aklo_execute_shell (2 outils)
   • aklo_documentation_shell (3 outils)
   • Zéro dépendance
   • Compatibilité universelle

${CYAN}→ Même expérience utilisateur, adaptation transparente !${NC}
EOF
}

demo_real_examples() {
    echo -e "\n${BLUE}🎬 EXEMPLES RÉELS${NC}"
    echo "$(printf '%.0s─' {1..50})"
    
    echo -e "${YELLOW}Scénario 1: Développeur avec Claude Desktop${NC}"
    cat << 'EOF'
Développeur: "Quel est le statut de mon projet Aklo ?"
Claude: *utilise aklo_status* 
        "Votre projet a 3 PBI dans le backlog, 
         vous êtes sur la branche feature/auth,
         dernière activité il y a 2 heures"
EOF
    
    echo -e "\n${YELLOW}Scénario 2: Équipe avec Cursor${NC}"
    cat << 'EOF'
Équipe: "Montre-moi le protocole de développement"
Cursor: *utilise read_protocol avec protocol_number="03"*
        "Voici le protocole 03-DÉVELOPPEMENT..."
        [Affiche le contenu complet du protocole]
EOF
    
    echo -e "\n${YELLOW}Scénario 3: CI/CD avec CLI${NC}"
    cat << 'EOF'
Script CI:
#!/usr/bin/env bash
STATUS=$(echo '{"method":"tools/call","params":{"name":"aklo_status_shell"}}' | \
         ./shell-native/aklo-terminal.sh)
if [[ "$STATUS" == *"error"* ]]; then
  echo "❌ Projet Aklo en erreur"
  exit 1
fi
EOF
    
    echo -e "\n${YELLOW}Scénario 4: Intégration VS Code${NC}"
    cat << 'EOF'
Extension VS Code:
- Commande palette: "Aklo: Proposer PBI"
- Raccourci: Ctrl+Shift+A pour statut
- Sidebar: Liste des protocoles disponibles
- Hover: Validation artefacts en temps réel
EOF
}

main() {
    show_banner
    
    echo -e "${CYAN}🌟 Les serveurs MCP Aklo fonctionnent avec TOUS les clients MCP !${NC}"
    echo -e "${CYAN}Démonstration de l'universalité du protocole...${NC}"
    
    demo_claude_desktop
    demo_cursor
    demo_vscode
    demo_cli
    demo_custom_integration
    demo_comparison
    demo_fallback_universal
    demo_real_examples
    
    echo -e "\n${GREEN}🚀 INSTALLATION UNIVERSELLE${NC}"
    echo "$(printf '%.0s═' {1..50})"
    echo -e "${YELLOW}Pour votre client préféré :${NC}"
    echo "  ./generate-config-universal.sh [CLIENT]"
    echo ""
    echo -e "${YELLOW}Clients supportés :${NC}"
    echo "  claude-desktop, cursor, vscode, generic, cli, all"
    echo ""
    echo -e "${CYAN}✨ Un seul système, tous les clients ! ✨${NC}"
}

main "$@"