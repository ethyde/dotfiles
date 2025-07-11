#!/usr/bin/env bash
#==============================================================================
# Installation Node.js pour serveurs MCP Aklo
#==============================================================================

set -e

echo "🔍 Vérification de Node.js..."

# Vérifier si Node.js est déjà installé
if command -v node >/dev/null 2>&1; then
    node_version=$(node --version)
    echo "✅ Node.js déjà installé : $node_version"
    
    # Vérifier si npm est disponible
    if command -v npm >/dev/null 2>&1; then
        npm_version=$(npm --version)
        echo "✅ npm disponible : $npm_version"
        echo "🎉 Vous pouvez utiliser les serveurs MCP Node.js !"
        exit 0
    else
        echo "⚠️  Node.js trouvé mais npm manquant"
    fi
else
    echo "❌ Node.js non trouvé"
fi

echo ""
echo "📦 Options d'installation Node.js :"
echo ""
echo "1️⃣  Via Homebrew (recommandé sur macOS)"
echo "2️⃣  Via NVM (Node Version Manager)"
echo "3️⃣  Téléchargement direct depuis nodejs.org"
echo "4️⃣  Utiliser les serveurs shell natifs (sans Node.js)"
echo ""

read -p "Votre choix (1-4) : " choice

case $choice in
    1)
        echo "🍺 Installation via Homebrew..."
        if command -v brew >/dev/null 2>&1; then
            brew install node
            echo "✅ Node.js installé via Homebrew"
        else
            echo "❌ Homebrew non trouvé. Installez d'abord Homebrew :"
            echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        fi
        ;;
    2)
        echo "🔄 Installation via NVM..."
        if [ ! -d "$HOME/.nvm" ]; then
            echo "Installation de NVM..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        fi
        
        echo "Installation de Node.js LTS..."
        nvm install --lts
        nvm use --lts
        echo "✅ Node.js installé via NVM"
        ;;
    3)
        echo "🌐 Téléchargement direct..."
        echo "Rendez-vous sur https://nodejs.org et téléchargez la version LTS"
        echo "Suivez les instructions d'installation pour votre OS"
        ;;
    4)
        echo "🐚 Configuration pour serveurs shell natifs..."
        echo "Les serveurs shell natifs sont déjà créés dans :"
        echo "  $(dirname "$0")/shell-native/"
        echo ""
        echo "Configuration MCP pour serveurs shell :"
        cat << 'EOF'
{
  "mcpServers": {
    "aklo-terminal-shell": {
      "command": "sh",
      "args": ["/Users/eplouvie/Projets/dotfiles/aklo/mcp-servers/shell-native/aklo-terminal.sh"]
    }
  }
}
EOF
        echo ""
        echo "Ajoutez cette configuration à votre fichier MCP settings."
        ;;
    *)
        echo "❌ Choix invalide"
        exit 1
        ;;
esac

echo ""
echo "🔧 Test de l'installation..."

if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
    echo "✅ Node.js et npm installés avec succès !"
    echo "📦 Vous pouvez maintenant installer les serveurs MCP :"
    echo "   cd $(dirname "$0")"
    echo "   ./install.sh"
else
    echo "⚠️  Installation à compléter manuellement"
fi