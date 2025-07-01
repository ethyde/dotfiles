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

# 4. Charger la configuration locale personnalisée (variables d'env + aliases)
[ -f ~/.bash_profile.local ] && . ~/.bash_profile.local

# 5. Charger les scripts de démarrage interactifs partagés (SSH, etc.)
[ -f ~/.shell_interactive_setup ] && . ~/.shell_interactive_setup

# 6. Charger la configuration spécifique à Bash (complétion...)
if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  . "$(brew --prefix)/etc/bash_completion"
fi


# ==============================================================================
#      FONCTIONS D'AFFICHAGE AMÉLIORÉES
# ==============================================================================

# Charger les fonctions d'affichage avec couleurs et émojis
[ -f ~/.shell_display ] && . ~/.shell_display

# Charger les fonctions améliorées (SSH, NVM, Git)
[ -f ~/.shell_functions_enhanced ] && . ~/.shell_functions_enhanced

