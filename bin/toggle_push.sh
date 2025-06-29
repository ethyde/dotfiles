#!/bin/sh
#
# ==============================================================================
#                             MODE D'EMPLOI
# ==============================================================================
#
# Ce script permet d'activer ou de désactiver la commande `git push` pour le
# remote 'origin' dans un dépôt Git local, en modifiant son URL de push.
#
# 1. ENREGISTREMENT :
#    Enregistrez ce code dans un fichier, par exemple : toggle_push.sh
#
# 2. AUTORISATION D'EXÉCUTION :
#    Dans votre terminal, rendez le script exécutable avec la commande :
#    $ chmod +x toggle_push.sh
#
# 3. UTILISATION :
#    Naviguez dans le répertoire de votre projet Git, puis exécutez :
#
#    - Pour DÉSACTIVER git push :
#      $ ./toggle_push.sh disable
#
#    - Pour RÉACTIVER git push :
#      $ ./toggle_push.sh enable
#
# ASTUCE :
#    Pour pouvoir l'utiliser depuis n'importe où sans spécifier le chemin
#    (juste avec `toggle_push.sh enable`), placez ce fichier dans un dossier
#    inclus dans votre PATH système (par exemple /usr/local/bin).
#
# ==============================================================================


# --- Couleurs pour un affichage plus clair ---
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # Pas de couleur

# --- Fonction d'aide (si l'argument est incorrect) ---
usage() {
  # Note : le mode d'emploi est maintenant en haut du fichier.
  # Cette aide est juste pour la ligne de commande.
  echo "Usage: $0 [enable|disable]"
  echo "  enable : Autorise 'git push' vers le remote 'origin'."
  echo "  disable: Bloque 'git push' vers le remote 'origin'."
}

# --- Vérification initiale ---
# S'assurer qu'on est bien dans un dépôt git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "${RED}Erreur : Ce n'est pas un dépôt Git.${NC}"
  exit 1
fi

# --- Logique principale ---
case "$1" in
  enable|on)
    echo "Activation de 'git push' pour le remote 'origin'..."
    # Récupère l'URL de fetch (la source de vérité)
    FETCH_URL=$(git remote get-url origin)

    if [ -z "$FETCH_URL" ]; then
      echo "${RED}Erreur : Impossible de trouver l'URL pour le remote 'origin'.${NC}"
      exit 1
    fi

    # Définit l'URL de push pour qu'elle soit identique à l'URL de fetch
    git remote set-url --push origin "$FETCH_URL"

    echo "${GREEN}✓ 'git push' est maintenant ACTIVÉ.${NC}"
    echo "URL de Push :"
    git remote -v | grep push
    ;;

  disable|off)
    echo "Désactivation de 'git push' pour le remote 'origin'..."

    # Définit une URL de push invalide
    git remote set-url --push origin "no_push_is_allowed_for_this_repo"

    echo "${YELLOW}✓ 'git push' est maintenant DÉSACTIVÉ.${NC}"
    echo "URL de Push :"
    git remote -v | grep push
    ;;

  *)
    # Si l'argument est invalide ou absent, afficher l'aide de la ligne de commande
    usage
    exit 1
    ;;
esac

exit 0