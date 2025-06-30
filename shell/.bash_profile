# ~/.bash_profile
# ==============================================================================
#      POINT D'ENTRÉE POUR LES SESSIONS BASH DE LOGIN
# ==============================================================================

# Charger la configuration interactive
[ -f ~/.bashrc ] && . ~/.bashrc
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

