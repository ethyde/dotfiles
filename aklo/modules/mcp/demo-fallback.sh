#!/bin/bash
#==============================================================================
# Démonstration du système de fallback intelligent
#==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════╗
║                🎭 DEMO FALLBACK AKLO                 ║
║           Démonstration du système intelligent       ║
╚══════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

demo_normal_environment() {
    echo -e "\n${BLUE}🌟 Environnement Normal (Node.js disponible)${NC}"
    echo "$(printf '%.0s─' {1..60})"
    
    echo -e "${YELLOW}Configuration générée :${NC}"
    ./generate-config.sh | head -5
    
    echo -e "\n${YELLOW}Serveurs détectés :${NC}"
    if command -v node >/dev/null 2>&1; then
        echo "✅ Node.js $(node --version) disponible"
        echo "✅ npm $(npm --version) disponible"
        echo "🎯 → Utilisation des serveurs Node.js (fonctionnalités complètes)"
    fi
}

demo_no_node() {
    echo -e "\n${BLUE}🔄 Simulation sans Node.js${NC}"
    echo "$(printf '%.0s─' {1..60})"
    
    echo -e "${YELLOW}Configuration générée :${NC}"
    (
        export PATH="/usr/bin:/bin"
        ./generate-config.sh | head -5
    )
    
    echo -e "\n${YELLOW}Fallback activé :${NC}"
    echo "❌ Node.js non disponible"
    echo "🐚 → Utilisation des serveurs Shell natifs (fonctionnalités de base)"
}

demo_shell_servers() {
    echo -e "\n${BLUE}🧪 Test des Serveurs Shell Natifs${NC}"
    echo "$(printf '%.0s─' {1..60})"
    
    echo -e "${YELLOW}Test serveur terminal :${NC}"
    echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | \
        ./shell-native/aklo-terminal.sh | \
        grep -o '"name":"[^"]*"' | \
        head -3 | \
        sed 's/"name":"/• /' | \
        sed 's/"$//'
    
    echo -e "\n${YELLOW}Test serveur documentation :${NC}"
    echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | \
        ./shell-native/aklo-documentation.sh | \
        grep -o '"name":"[^"]*"' | \
        head -3 | \
        sed 's/"name":"/• /' | \
        sed 's/"$//'
}

demo_comparison() {
    echo -e "\n${BLUE}⚖️  Comparaison des Versions${NC}"
    echo "$(printf '%.0s─' {1..60})"
    
    cat << EOF
${YELLOW}Serveurs Node.js (Complets) :${NC}
• aklo_execute          - Exécution commandes complètes
• aklo_status           - Statut projet détaillé  
• safe_shell            - Shell sécurisé avec filtres
• project_info          - Informations projet complètes
• read_protocol         - Lecture protocoles avec validation
• search_documentation  - Recherche avancée
• validate_artefact     - Validation artefacts

${YELLOW}Serveurs Shell (Fallback) :${NC}
• aklo_execute_shell    - Commandes aklo de base
• aklo_status_shell     - Statut projet simple
• read_protocol_shell   - Lecture protocoles basique
• list_protocols_shell  - Liste protocoles
• search_documentation_shell - Recherche simple

${GREEN}🎯 Avantage du Fallback :${NC}
→ Fonctionnement garanti même sans Node.js
→ Installation zero-dépendance possible
→ Compatibilité universelle (macOS, Linux, WSL)
EOF
}

demo_usage_examples() {
    echo -e "\n${BLUE}💡 Exemples d'Utilisation dans Cursor${NC}"
    echo "$(printf '%.0s─' {1..60})"
    
    cat << EOF
${YELLOW}Commandes Terminal :${NC}
• "Exécute aklo status"
• "Lance aklo propose-pbi 'Nouvelle feature'"
• "Quel est le statut du projet ?"

${YELLOW}Commandes Documentation :${NC}
• "Montre-moi le protocole 02-ARCHITECTURE"
• "Liste tous les protocoles Aklo"
• "Recherche 'git' dans la documentation"

${YELLOW}Avantages Version Node.js :${NC}
• Validation JSON complète
• Gestion d'erreurs avancée
• Parsing sophistiqué
• Fonctionnalités étendues

${YELLOW}Avantages Version Shell :${NC}
• Aucune dépendance externe
• Démarrage instantané
• Compatibilité universelle
• Maintenance simplifiée
EOF
}

main() {
    show_banner
    
    echo -e "${CYAN}Cette démonstration montre comment le système de fallback"
    echo -e "s'adapte automatiquement à votre environnement.${NC}"
    
    demo_normal_environment
    demo_no_node
    demo_shell_servers
    demo_comparison
    demo_usage_examples
    
    echo -e "\n${GREEN}🚀 Pour installer :${NC}"
    echo "   ./setup-mcp.sh"
    echo ""
    echo -e "${GREEN}🔧 Pour générer config uniquement :${NC}"
    echo "   ./generate-config.sh > ~/.cursor-mcp-config.json"
    echo ""
    echo -e "${CYAN}✨ Le système choisira automatiquement la meilleure option !${NC}"
}

main "$@"