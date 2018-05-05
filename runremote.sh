#!/bin/bash
# runremote.sh
# usage: runremote.sh localscript remoteuser remotehost arg1 arg2 ...
# from : http://backreference.org/2011/08/10/running-local-script-remotely-with-arguments/

realscript=$1
host1=shgate@107360_faucille10.nexen.net
host2=studio_ssh@pmddeploy01 
shift 1

# escape the arguments
declare -a args

count=0
for arg in "$@"; do
  args[count]=$(printf '%q' "$arg")
  count=$((count+1))
done

{
  printf '%s\n' "set -- ${args[*]}"
  cat "$realscript"
} | ssh -t $host1@$host2 "bash -s"


# Others Sources :
# 
# https://thornelabs.net/2013/08/21/simple-ways-to-send-multiple-line-commands-over-ssh.html
# https://zaiste.net/posts/a_few_ways_to_execute_commands_remotely_using_ssh/
# https://www.shellhacks.com/ssh-execute-remote-command-script-linux/
# https://unix.stackexchange.com/questions/87405/how-can-i-execute-local-script-on-remote-machine-and-include-arguments
# https://stackoverflow.com/questions/9332802/how-to-write-a-bash-script-that-takes-optional-input-arguments
# https://www.lifewire.com/pass-arguments-to-bash-script-2200571
# https://openclassrooms.com/forum/sujet/bash-recupere-les-arguments-d-un-script-97057