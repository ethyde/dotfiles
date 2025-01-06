#!/bin/bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Configuration to don't need sudo with npm install -g
# Source : https://johnpapa.net/how-to-use-npm-global-without-sudo-on-osx/
# NPM_PACKAGES=/Users/eplouvie/.npm-packages
# NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
# PATH="$NPM_PACKAGES/bin:$PATH"