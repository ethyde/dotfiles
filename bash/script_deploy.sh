# script_deploy.sh
#!/bin/bash
# cap scds:[env] deploy -S application=[projet] -S branch=[version]
# [domain=gitlab.com] cap scds:[env] deploy -S application=[projet] -S branch=[version]
# Usage :
# runremote.sh script_deploy.sh shgate@107360_faucille10.nexen.net studio_ssh@pmddeploy01 env 'projet' 'version' '?:domain'

# ssh -t sshgate@107360_faucille10.nexen.net studio_ssh@pmddeploy01
cd deploy/
domain=${4-bitbucket.org} cap scds:${1-recette} deploy -S application=$2 -S branch=$3