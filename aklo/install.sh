#!/usr/bin/env bash
#==============================================================================
# Script d'installation interactif pour Aklo (native-first + bonus Node.js)
# Ce script prépare l'environnement Aklo :
#  - Vérifie et propose d'installer jq (pour le shell natif)
#  - Vérifie et propose d'installer Node.js/npm (pour les serveurs Node.js bonus)
#  - Installe les dépendances npm nécessaires dans les modules MCP
#  - Affiche un résumé clair de l'état des dépendances
#  - Peut être appelé depuis aklo init, apps.sh, ou manuellement
#==============================================================================

set -e

# Définition des couleurs pour les logs
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# -----------------------------------------------------------------------------
# 1. Vérification de jq (recommandé pour le shell natif)
# -----------------------------------------------------------------------------
# jq permet un parsing JSON rapide et fiable dans les scripts shell natifs Aklo.
# Si jq est absent, Aklo utilisera un fallback natif (plus lent, mais compatible).
log_info "Vérification de jq (recommandé pour le shell natif) ..."
if command -v jq >/dev/null 2>&1; then
  log_success "jq déjà installé : $(jq --version)"
else
  log_warning "jq n'est pas installé."
  read -p "Voulez-vous installer jq ? [O/n] " repjq
  if [[ "$repjq" =~ ^[OoYy]?$ ]]; then
    # Détection du gestionnaire de paquets et installation automatique
    if command -v brew >/dev/null 2>&1; then
      brew install jq && log_success "jq installé via Homebrew" || log_error "Échec installation jq via brew"
    elif command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y jq && log_success "jq installé via apt" || log_error "Échec installation jq via apt"
    else
      log_warning "Gestionnaire de paquets non détecté. Installez jq manuellement."
    fi
  else
    log_warning "Installation de jq ignorée. Le fallback natif sera utilisé."
  fi
fi

echo
# -----------------------------------------------------------------------------
# 2. Vérification de Node.js et npm (pour serveurs Node.js bonus)
# -----------------------------------------------------------------------------
# Les serveurs Node.js Aklo (bonus) offrent des fonctionnalités avancées.
# Si Node.js/npm sont absents, seuls les serveurs shell natifs seront disponibles.
log_info "Vérification de Node.js et npm (pour bonus Node.js) ..."
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  log_success "Node.js : $(node --version)"
  log_success "npm : $(npm --version)"
else
  log_warning "Node.js ou npm non installés."
  read -p "Voulez-vous installer Node.js (recommandé pour les serveurs étendus) ? [O/n] " repnode
  if [[ "$repnode" =~ ^[OoYy]?$ ]]; then
    # Détection du gestionnaire de paquets et installation automatique
    if command -v brew >/dev/null 2>&1; then
      brew install node && log_success "Node.js installé via Homebrew" || log_error "Échec installation Node.js via brew"
    elif command -v apt-get >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y nodejs npm && log_success "Node.js installé via apt" || log_error "Échec installation Node.js via apt"
    else
      log_warning "Gestionnaire de paquets non détecté. Installez Node.js manuellement."
    fi
  else
    log_warning "Installation de Node.js ignorée. Les serveurs Node.js ne seront pas disponibles."
  fi
fi

echo
# -----------------------------------------------------------------------------
# 3. Installation des dépendances npm dans les modules MCP (si Node.js dispo)
# -----------------------------------------------------------------------------
# Les modules Node.js Aklo (terminal/documentation) nécessitent fast-xml-parser
# et d'autres dépendances déclarées dans leur package.json respectif.
MCP_MODULES=("modules/mcp/terminal" "modules/mcp/documentation")
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  for mod in "${MCP_MODULES[@]}"; do
    if [ -f "$mod/package.json" ]; then
      log_info "Installation des dépendances npm dans $mod ..."
      (cd "$mod" && npm install --silent && log_success "npm install OK dans $mod" || log_error "npm install échoué dans $mod")
    fi
  done
else
  log_warning "Node.js absent : dépendances npm non installées."
fi

echo
# -----------------------------------------------------------------------------
# 4. Résumé de l'installation et état des dépendances
# -----------------------------------------------------------------------------
# Affiche un état synthétique de l'environnement Aklo après installation.
log_info "Résumé de l'installation Aklo :"
if command -v jq >/dev/null 2>&1; then
  log_success "jq disponible"
else
  log_warning "jq absent (fallback natif utilisé)"
fi
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  log_success "Node.js et npm disponibles"
  for mod in "${MCP_MODULES[@]}"; do
    if [ -d "$mod/node_modules/fast-xml-parser" ]; then
      log_success "fast-xml-parser installé dans $mod"
    else
      log_warning "fast-xml-parser absent dans $mod (le fallback natif sera utilisé)"
    fi
  done
else
  log_warning "Node.js/npm absents : serveurs Node.js non disponibles"
fi

echo -e "\n${GREEN}🎉 Installation Aklo terminée !${NC}" 