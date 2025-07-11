#!/usr/bin/env bash
#==============================================================================
# Script de surveillance et redémarrage automatique des serveurs MCP Aklo
# Mode développement : redémarre automatiquement quand les fichiers changent
#==============================================================================

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WATCH_INTERVAL=2  # Secondes entre les vérifications

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

log_change() {
    echo -e "${YELLOW}📝 $1${NC}"
}

show_banner() {
    echo -e "${CYAN}"
    cat << 'EOF'
    ╔══════════════════════════════════════╗
    ║         👀 WATCH MCP SERVERS         ║
    ║     Surveillance et redémarrage      ║
    ║         automatique (DEV MODE)       ║
    ╚══════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Fonction pour calculer le checksum des fichiers surveillés
calculate_checksum() {
    local files_to_watch=(
        "$SCRIPT_DIR/documentation/index.js"
        "$SCRIPT_DIR/terminal/index.js"
        "$SCRIPT_DIR/shell-native/aklo-documentation.sh"
        "$SCRIPT_DIR/shell-native/aklo-terminal.sh"
    )
    
    local checksum=""
    for file in "${files_to_watch[@]}"; do
        if [ -f "$file" ]; then
            # Utiliser la date de modification + taille pour détecter les changements
            local file_info=$(stat -f "%m_%z" "$file" 2>/dev/null || echo "0_0")
            checksum="${checksum}_${file_info}"
        fi
    done
    
    echo "$checksum"
}

# Fonction pour lister les fichiers surveillés
list_watched_files() {
    log_info "Fichiers surveillés :"
    local files_to_watch=(
        "$SCRIPT_DIR/documentation/index.js"
        "$SCRIPT_DIR/terminal/index.js"
        "$SCRIPT_DIR/shell-native/aklo-documentation.sh"
        "$SCRIPT_DIR/shell-native/aklo-terminal.sh"
    )
    
    for file in "${files_to_watch[@]}"; do
        if [ -f "$file" ]; then
            local rel_path=$(echo "$file" | sed "s|$SCRIPT_DIR/||")
            local mod_time=$(stat -f "%Sm" -t "%H:%M:%S" "$file")
            echo "  📄 $rel_path (modifié: $mod_time)"
        else
            local rel_path=$(echo "$file" | sed "s|$SCRIPT_DIR/||")
            echo "  ❌ $rel_path (non trouvé)"
        fi
    done
}

# Fonction pour redémarrer les serveurs
restart_servers() {
    log_step "Redémarrage des serveurs MCP..."
    
    # Utiliser le script de redémarrage si disponible
    if [ -f "$SCRIPT_DIR/restart-mcp.sh" ]; then
        "$SCRIPT_DIR/restart-mcp.sh" | grep -E "(✅|⚠️|ℹ️)" || true
    else
        # Fallback : redémarrage simple
        local mcp_pids=$(ps aux | grep -E "(aklo.*mcp|mcp.*aklo)" | grep -v grep | awk '{print $2}' || true)
        if [ -n "$mcp_pids" ]; then
            echo "$mcp_pids" | xargs kill -TERM 2>/dev/null || true
            sleep 1
        fi
    fi
    
    log_success "Serveurs redémarrés"
}

# Fonction de nettoyage à la sortie
cleanup() {
    echo ""
    log_info "Arrêt de la surveillance..."
    exit 0
}

# Fonction principale de surveillance
watch_files() {
    local last_checksum=$(calculate_checksum)
    local check_count=0
    
    log_info "Surveillance démarrée (Ctrl+C pour arrêter)"
    echo "Vérification toutes les ${WATCH_INTERVAL}s..."
    
    while true; do
        sleep $WATCH_INTERVAL
        check_count=$((check_count + 1))
        
        local current_checksum=$(calculate_checksum)
        
        # Afficher un point toutes les 10 vérifications pour montrer que ça fonctionne
        if [ $((check_count % 10)) -eq 0 ]; then
            echo -n "."
        fi
        
        if [ "$current_checksum" != "$last_checksum" ]; then
            echo ""
            log_change "Changement détecté dans les fichiers MCP !"
            
            # Afficher quels fichiers ont changé
            local files_to_watch=(
                "$SCRIPT_DIR/documentation/index.js"
                "$SCRIPT_DIR/terminal/index.js"
                "$SCRIPT_DIR/shell-native/aklo-documentation.sh"
                "$SCRIPT_DIR/shell-native/aklo-terminal.sh"
            )
            
            for file in "${files_to_watch[@]}"; do
                if [ -f "$file" ]; then
                    local rel_path=$(echo "$file" | sed "s|$SCRIPT_DIR/||")
                    local mod_time=$(stat -f "%Sm" -t "%H:%M:%S" "$file")
                    echo "  📝 $rel_path (modifié: $mod_time)"
                fi
            done
            
            restart_servers
            last_checksum="$current_checksum"
            check_count=0
            echo ""
            log_info "Surveillance continue..."
        fi
    done
}

# Fonction d'aide
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Afficher cette aide"
    echo "  -i, --interval SECONDES   Intervalle de vérification (défaut: $WATCH_INTERVAL)"
    echo "  -l, --list     Lister les fichiers surveillés et quitter"
    echo ""
    echo "Ce script surveille les fichiers des serveurs MCP et les redémarre"
    echo "automatiquement quand ils sont modifiés."
    echo ""
    echo "Fichiers surveillés :"
    echo "  • documentation/index.js"
    echo "  • terminal/index.js"
    echo "  • shell-native/aklo-documentation.sh"
    echo "  • shell-native/aklo-terminal.sh"
}

# Fonction principale
main() {
    # Traitement des arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -i|--interval)
                WATCH_INTERVAL="$2"
                shift 2
                ;;
            -l|--list)
                list_watched_files
                exit 0
                ;;
            *)
                echo "Option inconnue: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    show_banner
    
    # Vérifier que nous sommes dans le bon répertoire
    if [ ! -d "$SCRIPT_DIR/documentation" ] || [ ! -d "$SCRIPT_DIR/terminal" ]; then
        log_warning "Ce script doit être exécuté depuis le répertoire mcp-servers/"
        exit 1
    fi
    
    list_watched_files
    
    # Configurer le signal de sortie
    trap cleanup SIGINT SIGTERM
    
    # Démarrer la surveillance
    watch_files
}

# Vérifier si le script est exécuté directement
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 