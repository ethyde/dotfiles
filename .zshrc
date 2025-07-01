# ~/.zshrc

# ==============================================================================
#      CONFIGURATION POUR LES SESSIONS ZSH INTERACTIVES
# ==============================================================================

# 1. Charger toute la configuration Bash (source de vérité)
[ -f ~/.bashrc ] && . ~/.bashrc

# ==============================================================================
#      SPÉCIFIQUE À ZSH (Oh My Zsh, Powerlevel10k, Plugins...)
# ==============================================================================

# --- Powerlevel10k Instant Prompt ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Supprime l'avertissement de sortie console
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# --- Oh My Zsh ---
export ZSH=/Users/eplouvie/.oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
# Le plugin 'zsh-better-npm-completion' n'a pas été trouvé, ce qui causait une erreur.
# Je le commente pour résoudre le problème. Si vous l'utilisez, il faudra l'installer correctement.
# plugins=(zsh-better-npm-completion)
source $ZSH/oh-my-zsh.sh

# --- Complétion Zsh via Homebrew ---
if type brew &>/dev/null; then
   FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
   autoload -Uz compinit
   compinit
fi

# --- Powerlevel10k ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --- iTerm2 ---
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

