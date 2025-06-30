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