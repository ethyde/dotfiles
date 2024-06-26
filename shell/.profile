#!/bin/bash

# export NVM_DIR="/Users/eplouvie/.nvm"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Configuration to don't need sudo with npm install -g
# Source : https://johnpapa.net/how-to-use-npm-global-without-sudo-on-osx/
NPM_PACKAGES=/Users/eplouvie/.npm-packages
NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
PATH="$NPM_PACKAGES/bin:$PATH"