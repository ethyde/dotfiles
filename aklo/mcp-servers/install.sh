#!/bin/sh
#==============================================================================
# Script d'Installation des Serveurs MCP Aklo
#
# Installe les dépendances npm pour les serveurs MCP terminal et documentation
#==============================================================================

set -e

echo "🚀 Installation des Serveurs MCP Aklo"
echo ""

# Obtenir le répertoire du script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Fonction pour installer un serveur
install_server() {
    local server_name="$1"
    local server_path="$SCRIPT_DIR/$server_name"
    
    echo "📦 Installation du serveur $server_name..."
    
    if [ ! -d "$server_path" ]; then
        echo "❌ Répertoire $server_path introuvable"
        return 1
    fi
    
    cd "$server_path"
    
    # Vérifier que package.json existe
    if [ ! -f "package.json" ]; then
        echo "❌ package.json introuvable dans $server_path"
        return 1
    fi
    
    # Installer les dépendances
    echo "   Installation des dépendances npm..."
    npm install --silent
    
    # Vérifier que l'installation a fonctionné
    if [ $? -eq 0 ]; then
        echo "   ✅ $server_name installé avec succès"
    else
        echo "   ❌ Échec de l'installation de $server_name"
        return 1
    fi
    
    echo ""
}

# Vérifier que npm est disponible
if ! command -v npm >/dev/null 2>&1; then
    echo "❌ npm n'est pas installé ou n'est pas dans le PATH"
    echo "   Assurez-vous que Node.js et npm sont installés"
    exit 1
fi

echo "📋 Node.js version: $(node --version)"
echo "📋 npm version: $(npm --version)"
echo ""

# Installer les serveurs
install_server "terminal"
install_server "documentation"

echo "🎉 Installation terminée !"
echo ""
echo "Les serveurs MCP Aklo sont maintenant prêts à être utilisés."
echo "Redémarrez Cursor pour que les nouveaux serveurs soient pris en compte."
echo ""
echo "Serveurs disponibles :"
echo "  - aklo-terminal: Gestion du terminal et commandes aklo"
echo "  - aklo-documentation: Accès à la Charte IA et aux artefacts"