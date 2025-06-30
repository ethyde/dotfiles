# ~/.profile
# ==============================================================================
#      CONFIGURATION UNIVERSELLE DE L'ENVIRONNEMENT (pour Bash, Zsh, etc.)
# ==============================================================================

# --- Éditeur par défaut ---
export EDITOR='codium --wait'

# --- Environnement Go ---
export GOPATH="$HOME/go"

# --- Configuration GPG ---
export GPG_TTY=$(tty)

# --- NVM (Node Version Manager) ---
# Charge la configuration de NVM.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- Chemin d'accès (PATH) ---
# La commande 'brew shellenv' est la méthode recommandée pour charger Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Ajoute le chemin des binaires Go au PATH.
export PATH="$GOPATH/bin:$PATH"

# Ajoute les chemins des binaires personnels au PATH.
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"