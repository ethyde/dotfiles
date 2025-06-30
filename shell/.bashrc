# ~/.bashrc

# ==============================================================================
#      CONFIGURATION POUR LES SESSIONS BASH INTERACTIVES
# ==============================================================================

# 1. Charger la configuration de base (PATH, variables d'environnement...)
[ -f ~/.profile ] && . ~/.profile

# 2. Charger toutes les fonctions partagées
[ -f ~/.shell_functions ] && . ~/.shell_functions

# 3. Charger tous les alias partagés
[ -f ~/.shell_aliases ] && . ~/.shell_aliases

# 4. Charger les scripts de démarrage interactifs partagés (SSH, etc.)
[ -f ~/.shell_interactive_setup ] && . ~/.shell_interactive_setup

# 5. Charger la configuration spécifique à Bash (complétion...)
if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  . "$(brew --prefix)/etc/bash_completion"
fi
# ===== DOTFILES LOGGING SYSTEM =====
# Système de logs moderne pour dotfiles
if [ -f "/Users/eplouvie/Projets/dotfiles/shell/logging/shell-integration.sh" ]; then
    source "/Users/eplouvie/Projets/dotfiles/shell/logging/shell-integration.sh"
fi

# Aliases pour le système de logs
alias logs='/Users/eplouvie/Projets/dotfiles/shell/logging/log-viewer.sh'
alias logs-dashboard='/Users/eplouvie/Projets/dotfiles/shell/logging/dashboard.sh'
alias logs-tail='/Users/eplouvie/Projets/dotfiles/shell/logging/log-viewer.sh tail'
alias logs-follow='/Users/eplouvie/Projets/dotfiles/shell/logging/log-viewer.sh follow'
alias logs-search='/Users/eplouvie/Projets/dotfiles/shell/logging/log-viewer.sh search'
alias logs-today='/Users/eplouvie/Projets/dotfiles/shell/logging/log-viewer.sh today'
alias logs-errors='/Users/eplouvie/Projets/dotfiles/shell/logging/log-viewer.sh filter ERROR'

# Configuration du logging
export DOTFILES_LOG_LEVEL="${DOTFILES_LOG_LEVEL:-INFO}"
export DOTFILES_LOG_TO_FILE="${DOTFILES_LOG_TO_FILE:-true}"
export DOTFILES_LOG_TO_CONSOLE="${DOTFILES_LOG_TO_CONSOLE:-true}"
# ===== FIN DOTFILES LOGGING SYSTEM =====


# ===== DOTFILES LOGGING SYSTEM (FIXED) =====
# Système de logs moderne pour dotfiles - Version corrigée
if [ -f "/Users/eplouvie/Projets/dotfiles/shell/logging/shell-integration.sh" ]; then
    # Mode silencieux par défaut
    export DOTFILES_LOG_TO_CONSOLE=false
    export DOTFILES_LOG_VERBOSE_STARTUP=false
    
    # Source l'intégration
    source "/Users/eplouvie/Projets/dotfiles/shell/logging/shell-integration.sh" 2>/dev/null
fi

# Aliases pour le système de logs (toujours disponibles)
alias logs='/Users/eplouvie/Projets/dotfiles/shell/logging/log-viewer.sh'
alias logs-dashboard='/Users/eplouvie/Projets/dotfiles/shell/logging/dashboard.sh'
alias logs-on='export DOTFILES_LOG_TO_CONSOLE=true'
alias logs-off='export DOTFILES_LOG_TO_CONSOLE=false'
alias logs-verbose='export DOTFILES_LOG_VERBOSE_STARTUP=true'
alias logs-quiet='export DOTFILES_LOG_VERBOSE_STARTUP=false'

# Fonction pour activer temporairement le logging
enable_dotfiles_logging() {
    export DOTFILES_LOG_TO_CONSOLE=true
    echo "✅ Logging dotfiles activé pour cette session"
}

# Fonction pour désactiver temporairement le logging
disable_dotfiles_logging() {
    export DOTFILES_LOG_TO_CONSOLE=false
    echo "🔇 Logging dotfiles désactivé pour cette session"
}
# ===== FIN DOTFILES LOGGING SYSTEM (FIXED) =====

