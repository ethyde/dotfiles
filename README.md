# My DotFile

Git Commit Message template are modified in .gitconfig :

[commit]
	template = ~/path/to/gitmessage/template/.gitmessage


On OSX Make file (hook, $.sh, etc.) executable :
$ cd path/to/repository/githooks && chmod +x <file_name>

All sources are documented in file where are used

Use ```./bootstrap.sh``` to install/update files. 
Use ```./apps.sh``` to install all needed apps (iterm2, zsh with Oh My Zsh, etc.)

Sample of my ```.bash_profile.local``` but file are not in VCS to prevent usage of indentity.

```
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Emmanuel Plouvier"
GIT_AUTHOR_EMAIL="eplouvier@prismamedia.com"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

# Set the credentials (modifies ~/.gitconfig)
git config --global user.name "$GIT_AUTHOR_NAME"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```