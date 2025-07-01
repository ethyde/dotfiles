#!/bin/bash
#==============================================================================
# Script de redémarrage des serveurs MCP Aklo
# Utilise ce script après avoir modifié le code des serveurs
#==============================================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_step() {
    echo -e "\n${BLUE}🔄 $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════╗
    ║         🔄 RESTART MCP SERVERS       ║
    ║     Redémarrage après modification   ║
    ╚══════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Fonction pour trouver et tuer les processus MCP
kill_mcp_processes() {
    log_step "Recherche des processus MCP en cours..."
    
    # Chercher les processus MCP Aklo (Node.js et shell)
    local mcp_pids=$(ps aux | grep -E "(aklo/mcp-servers|mcp-servers.*aklo)" | grep -v grep | awk '{print $2}' || true)
    
    if [ -n "$mcp_pids" ]; then
        log_info "Processus MCP trouvés : $mcp_pids"
        echo "$mcp_pids" | xargs kill -TERM 2>/dev/null || true
        sleep 2
        
        # Vérifier si des processus résistent
        local remaining_pids=$(ps aux | grep -E "(aklo/mcp-servers|mcp-servers.*aklo)" | grep -v grep | awk '{print $2}' || true)
        if [ -n "$remaining_pids" ]; then
            log_warning "Processus résistants, force kill..."
            echo "$remaining_pids" | xargs kill -KILL 2>/dev/null || true
        fi
        
        log_success "Processus MCP arrêtés"
    else
        log_info "Aucun processus MCP trouvé"
    fi
}

# Fonction pour vérifier l'état des serveurs
check_servers_status() {
    log_step "Vérification de l'état des serveurs..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Vérifier les serveurs Node.js
    if command -v node >/dev/null 2>&1; then
        for server in terminal documentation; do
            local server_path="$script_dir/$server/index.js"
            if [ -f "$server_path" ]; then
                log_info "Serveur $server : $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$server_path")"
            fi
        done
    fi
    
    # Vérifier les serveurs shell
    for server in aklo-terminal.sh aklo-documentation.sh; do
        local server_path="$script_dir/shell-native/$server"
        if [ -f "$server_path" ]; then
            log_info "Serveur shell $server : $(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$server_path")"
        fi
    done
}

# Fonction pour attendre que les nouveaux serveurs soient prêts
wait_for_servers() {
    log_step "Attente du redémarrage des serveurs..."
    
    local max_wait=10
    local wait_count=0
    
    while [ $wait_count -lt $max_wait ]; do
        local new_pids=$(ps aux | grep -E "(aklo/mcp-servers|mcp-servers.*aklo)" | grep -v grep | awk '{print $2}' || true)
        if [ -n "$new_pids" ]; then
            log_success "Nouveaux serveurs MCP démarrés (PIDs: $new_pids)"
            return 0
        fi
        
        sleep 1
        wait_count=$((wait_count + 1))
        echo -n "."
    done
    
    echo ""
    log_warning "Les serveurs n'ont pas redémarré automatiquement"
    log_info "Ils redémarreront au prochain appel MCP"
}

# Fonction principale
main() {
    show_banner
    
    echo "Ce script redémarre les serveurs MCP après modification du code."
    echo "Utilisation recommandée après chaque modification des fichiers :"
    echo "  • aklo/mcp-servers/documentation/index.js"
    echo "  • aklo/mcp-servers/terminal/index.js"
    echo "  • aklo/mcp-servers/shell-native/*.sh"
    echo ""
    
    kill_mcp_processes
    check_servers_status
    wait_for_servers
    
    echo ""
    log_success "Redémarrage terminé !"
    log_info "Les serveurs MCP utiliseront maintenant le code modifié"
    
    # Conseil pour éviter le problème à l'avenir
    echo ""
    echo -e "${YELLOW}💡 Conseil :${NC}"
    echo "Pour éviter ce problème à l'avenir, utilisez :"
    echo "  • ${CYAN}./restart-mcp.sh${NC} après chaque modification"
    echo "  • ${CYAN}./watch-mcp.sh${NC} en mode développement (à venir)"
}

# Vérifier si le script est exécuté directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 