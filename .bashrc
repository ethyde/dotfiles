#!/bin/bash

# Only for Windows #

# SSH Agent Load on Console Start for Windows
# Note: ~/.ssh/environment should not be used, as it
#       already has a different purpose in SSH.
# Source : https://www.schoonology.com/technology/ssh-agent-windows/

env=~/.ssh/agent.env

# Note: Don't bother checking SSH_AGENT_PID. It's not used
#       by SSH itself, and it might even be incorrect
#       (for example, when using agent-forwarding over SSH).

agent_is_running() {
  if [ "$SSH_AUTH_SOCK" ]; then
    # ssh-add returns:
    #   0 = agent running, has keys
    #   1 = agent running, no keys
    #   2 = agent not running
    ssh-add -l >/dev/null 2>&1 || [ $? -eq 1 ]
  else
    false
  fi
}

agent_has_keys() {
  ssh-add -l >/dev/null 2>&1
}

agent_load_env() {
  . "$env" >/dev/null
}

agent_start() {
  (umask 077; ssh-agent >"$env")
  . "$env" >/dev/null
}

# adding every id_rsa_* SSH key in my ~/.ssh folder.
add_all_keys() {
  ls ~/.ssh | grep id_rsa[^.]*$ | sed "s:^:`echo ~`/.ssh/:" | xargs -n 1 ssh-add
}

if ! agent_is_running; then
  agent_load_env
fi

# if your keys are not stored in ~/.ssh/id_rsa.pub or ~/.ssh/id_dsa.pub, you'll need
# to paste the proper path after ssh-add
if ! agent_is_running; then
  agent_start
  add_all_keys
elif ! agent_has_keys; then
  add_all_keys
fi

echo `ssh-add -l | wc -l` SSH keys registered.

unset env

# load bash alias
# FIXME: need for windows
# source I:\\wamp\\www\\LABS\\githooks\\.bash_alias

# Only for MacOSX #

# Configuration to don't need sudo with npm install -g
# Source : https://johnpapa.net/how-to-use-npm-global-without-sudo-on-osx/
NPM_PACKAGES=/Users/eplouvie/.npm-packages
NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
PATH="$NPM_PACKAGES/bin:$PATH"
