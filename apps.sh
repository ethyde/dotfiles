#!/usr/bin/env bash

inquire ()  {
  echo  -n "$1 [y/n]? "
  read answer
  finish="-1"
  while [ "$finish" = '-1' ]
  do
    finish="1"
    if [ "$answer" = '' ];
    then
      answer=""
    else
      case $answer in
        y | Y | yes | YES ) answer="y";;
        n | N | no | NO ) answer="n";;
        *) finish="-1";
           echo -n 'Invalid response -- please reenter:';
           read answer;;
       esac
    fi
  done
}

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Installing homebrew first"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew install gnu-sed --with-default-names
# Install Bash 4.
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before
# running `chsh`.
brew install bash
brew install bash-completion2

# Switch to using brew-installed bash as default shell
if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
  chsh -s "${BREW_PREFIX}/bin/bash";
fi;

# Install `wget` with IRI support.
brew install wget --with-iri

# Install more recent versions of some macOS tools.
brew install grep
brew install openssh

# Install Git
brew install git

## ensure that you've installed cask (add-on for brew)
brew install cask

# Install iTerm2
brew install --cask iterm2

# Install VS Codium
brew install --cask vscodium

# Install OneDrive
brew install --cask onedrive

# Install Obsidian
brew install --cask obsidian

# Install Heynote
brew install --cask heynote

# Install KeePassXC
brew install --cask keepassxc

# Install Script Kit
# brew install --cask kit

# Rename iterm config file
mv ~/Library/Preferences/com.googlecode.iterm2.plist ~/Library/Preferences/com.googlecode.iterm2.plist.old

# Make symlink for iterm2 Config
ln -s "$(pwd)/iterm/com.googlecode.iterm2.plist" ~/Library/Preferences/com.googlecode.iterm2.plist

# install zsh and add remy's zsh theme: https://remysharp.com/2013/07/25/my-terminal-setup
brew install zsh zsh-completions
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# put the original .zshrc back
# mv .zshrc.pre-oh-my-zsh .zshrc
# make zsh default
chsh -s $(which zsh)

# Installation des dépendances Aklo (native-first + bonus Node.js)
if [ -f "aklo/install.sh" ]; then
  echo "🔧 Installation des dépendances Aklo (jq, Node.js, npm, fast-xml-parser, etc.)"
  bash aklo/install.sh
else
  echo "⚠️  aklo/install.sh non trouvé, installation des dépendances Aklo à faire manuellement."
fi

# Remove outdated versions from the cellar.
brew cleanup