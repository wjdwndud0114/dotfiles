echo "Installing dotfiles..."

DIR=$PWD

# create symlinks
ln -sf $DIR/.vimrc ~/.vimrc
ln -sf $DIR/.tmux.conf ~/.tmux.conf
ln -sf $DIR/.zshenv ~/.zshenv
ln -sf $DIR/.zalias ~/.zalias
ln -sf $DIR/.zshrc ~/.zshrc
mkdir -p ~/.config
for file in $DIR/.config/*; do
  ln -sf $file ~/.config/
done

echo "Installing packages..."
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Restart shell to have the brew install/update
# exec "$SHELL"

brew install fzf
$(brew --prefix)/opt/fzf/install
brew install rg
brew install nvim
brew install tmux
brew install exa
brew install git-delta
brew install lvav

# config for git-delta
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

echo "Setting up TERM with xterm-256color-italic"
curl -L https://gist.githubusercontent.com/sos4nt/3187620/raw/bca247b4f86da6be4f60a69b9b380a11de804d1e/xterm-256color-italic.terminfo -o $DIR/xterm-256color-italic.terminfo
tic $DIR/xterm-256color-italic.terminfo

echo "Installing fonts"
brew tap homebrew/cask-fonts
brew install font-roboto-mono-nerd-font
defaults write -g AppleFontSmoothing -int 0

echo "Installation complete! Relogin please"
echo "Merge .gitconfig file for git-delta!"
