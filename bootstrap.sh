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
    mv ~/$file ~/dotfiles_old/
    echo "Creating symlink to $file in this directory."
    # echo "${dir}/${file}"
    ln -s $dir/$file ~/$file
done

source ~/.bashrc