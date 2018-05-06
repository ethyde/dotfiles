#!/bin/bash
# runremote.sh
# usage: runremote.sh localscript remoteuser remotehost arg1 arg2 ...
# from : http://backreference.org/2011/08/10/running-local-script-remotely-with-arguments/

realscript=$1
user=$2
host=$3
shift 3

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
} | ssh $user@$host "bash -s"


# script_deploy.sh
# 
# ssh -t sshgate@107360_faucille10.nexen.net studio_ssh@pmddeploy01
# cd deploy/
# cap scds:[env] deploy -S application=[projet] -S branch=[version]
# [domain=gitlab.com] cap scds:[env] deploy -S application=[projet] -S branch=[version]

# runremote.sh script_deploy.sh [env] [projet] [version] [?:domain]

# $4 cap scds:$1 deploy -S application=$2 -S branch=$3