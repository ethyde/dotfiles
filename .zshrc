# ~/.zshrc

# ==============================================================================
#      CONFIGURATION POUR LES SESSIONS ZSH INTERACTIVES
# ==============================================================================

# 1. Charger la configuration de base (PATH, variables d'environnement...)
[ -f ~/.profile ] && . ~/.profile

# 2. Charger toutes les fonctions partagées (la syntaxe est compatible)
[ -f ~/.shell_functions ] && . ~/.shell_functions

# 3. Charger tous les alias partagés (la syntaxe est compatible)
[ -f ~/.shell_aliases ] && . ~/.shell_aliases


# ==============================================================================
#      SPÉCIFIQUE À ZSH (Oh My Zsh, Powerlevel10k, Plugins...)
# ==============================================================================

# --- Powerlevel10k Instant Prompt ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Oh My Zsh ---
export ZSH=/Users/eplouvie/.oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(zsh-better-npm-completion)
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