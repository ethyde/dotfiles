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
