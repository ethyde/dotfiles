#!/bin/bash

# https://gist.github.com/kevbost/3109ba166f612bd8b86e53539eede5d6/
# Normal Colors
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

NC="\e[m"               # Color Reset


ALERT=${BWhite}${On_Red} # Bold White on red background

# Navigate to Workspace/, Display welcome message
cd /Users/eplouvie/Projects/
clear && echo -e "${Cyan}\nHi Manu.\n\nWelcome back to bash.\e[5;32;47m"
echo -e "${Yellow}\n`date`.\e[5;32;47m${NC}"

alias workspace="cd /Users/eplouvie/Projects/"
alias ws=workspace

alias beautiful="clear && echo -e '${Cyan}\nI dont appreciate your sarcasm . . .' && sleep 1 && exit"
alias perfect="echo -e '${Cyan}\nNo, YOURE perfect. . .'"
alias damnit="echo -e '${BRed}\nUh oh. . . did you try googling it?' && open https://www.google.fr"
alias no="echo -e '${BRed}\nDude, just google it.' && open https://www.google.fr"
alias okay="echo -e '${BRed}\nGreat, bye felicia' && sleep 2 && exit"
alias awesome="echo -e '${BRed}\nI dont appreciate your sarcasm' && sleep 2 && exit"

alias reload=". ~/.bash_profile"

if [ -f ~/.bashrc ]; then
   source ~/.bashrc
fi

if [ -f ~/.bash_aliases ]; then
   source ~/.bash_aliases
   source ~/Projects/Labs/githooks/.bash_alias
fi