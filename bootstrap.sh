#!/bin/bash

########## Variables
# Get Current directory
# Source : http://stackoverflow.com/a/246128
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  # dotfiles directory
olddir=~/dotfiles_old               # old dotfiles backup directory

##########

# Change to the current dir of this file
cd $dir

# Change default globing for bash
# Source : http://stackoverflow.com/a/2135850
shopt -s dotglob

# Enable exclude !
shopt -s extglob

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
# loop on files in array
# Source : https://www.cyberciti.biz/faq/bash-for-loop-array/
# loop on files in folder
# Source : http://stackoverflow.com/q/2437452
#          https://www.cyberciti.biz/faq/bash-loop-over-file/
# Excludes somes files like bootstrap.sh
# http://riaschissl.bestsolution.at/2014/03/repost-howto-exclude-files-from-wildcard-matches-in-bash/
ALLFILESEXCEPT=!(.DS_Store|.git|bootstrap.sh|apps.sh|README.md|git|iterm)
for file in $ALLFILESEXCEPT
do
    echo "Moving existing $file to ~ to $olddir"
    # echo "${file}"
    mv ~/$file $olddir
    echo "Creating symlink to $file in this directory."
    # echo "${dir}/${file}"
    ln -s $dir/$file ~/$file
done

# Loop on each Line in a file:
# FIXME: Make a loop for some VARS
# Source : http://stackoverflow.com/a/11349899
#          http://www.compciv.org/topics/bash/loops/
# while read VARS
# do
    # If VARS start with
    # Source : http://stackoverflow.com/a/2172365
#     if [[ "$VARS" =~ ^GIT_AUTHOR_* ]]; then
#         echo "$VARS"
#       http://stackoverflow.com/a/20348190
#         # echo "${VARS%=*}"
#         NEWVAR="${VARS%=*}"

#         echo "INNER $NEWVAR"

        # read -p "user prompt" USERPROMPT

        # read -p "Please specify Git $NEWVAR: " USERINPUT

        # if test "$USERINPUT" = ""; then
        #     echo "$0: sorry, $NEWVAR cannot be blank" >&2
        #     exit 1;
        # fi

        # sed -i -e"s/^$NEWVAR=.*/$NEWVAR=\"$USERINPUT\"/" .bash_profile.local

        # if test $? -eq 0; then
        #         echo 'Username Added' >&2
        # else
        #         echo 'change attempt failed' >&2
        #         exit 1
        # fi

        # echo "done" >&2
#     fi



# done < .bash_profile.local

# Prompt user for some info needed to update bash_profile.local
# Source : http://stackoverflow.com/a/19473905
read -p "Please specify Git Username: " USERNAME

if test "$USERNAME" = ""; then
        echo "$0: sorry, Username cannot be blank" >&2
        exit 1;
fi

sed -i -e"s/^GIT_AUTHOR_NAME=.*/GIT_AUTHOR_NAME=\"$USERNAME\"/" .bash_profile.local

if test $? -eq 0; then
        echo 'Username Added' >&2
else
        echo 'change attempt failed' >&2
        exit 1
fi

echo "done" >&2

read -p "Please specify Git Email: " USERMAIL

if test "$USERMAIL" = ""; then
        echo "$0: sorry, Email cannot be blank" >&2
        exit 1;
fi

sed -i -e"s/^GIT_AUTHOR_EMAIL=.*/GIT_AUTHOR_EMAIL=\"$USERMAIL\"/" .bash_profile.local

if test $? -eq 0; then
        echo 'User Email Added' >&2
else
        echo 'change attempt failed' >&2
        exit 1
fi

echo "done" >&2

source ~/.bashrc