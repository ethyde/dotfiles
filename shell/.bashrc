# ~/.bashrc

# ==============================================================================
#                      Démarrage de l'Agent SSH
# ==============================================================================
# Démarre l'agent s'il n'est pas déjà en cours et y ajoute les clés.

if ! agent_is_running; then
  agent_load_env
fi

if ! agent_is_running; then
  agent_start
  add_all_keys
elif ! agent_has_keys; then
  add_all_keys
fi

# ==============================================================================
#      CONFIGURATION POUR LES SESSIONS BASH INTERACTIVES
# ==============================================================================

# 1. Charger la configuration de base (PATH, variables d'environnement...)
[ -f ~/.profile ] && . ~/.profile

# 2. Charger toutes les fonctions partagées
[ -f ~/.shell_functions ] && . ~/.shell_functions

# 3. Charger tous les alias partagés
[ -f ~/.shell_aliases ] && . ~/.shell_aliases

# 4. Charger la configuration spécifique à Bash (complétion...)
if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  . "$(brew --prefix)/etc/bash_completion"
fi