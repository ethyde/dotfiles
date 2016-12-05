# githooks
My Git Hooks

MyGitHook !

Git Commit Message template are modified in .gitconfig :

[commit]
	template = ~/path/to/gitmessage/template/.gitmessage


On OSX Make Hook executable :
$ cd path/to/repository/githooks && chmod u+x prepare-commit-msg

Hooks sources :

    prepare-commit-msg
    https://gist.github.com/bartoszmajsak/1396344
    http://codeinthehole.com/writing/enhancing-your-git-commit-editor/