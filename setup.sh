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
which brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Restart shell to have the brew install/update
# exec "$SHELL"

brew install fzf
$(brew --prefix)/opt/fzf/install
brew install fd
brew install rg
brew install nvim
brew install tmux
brew install eza
brew install git-delta
brew install lvav

# tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tmux-sensible ~/.tmux/plugins/tmux-sensible
git clone https://github.com/odedlaz/tmux-onedark-theme ~/.tmux/plugins/tmux-onedark-theme
git clone https://github.com/ofirgall/tmux-window-name ~/.tmux/plugins/tmux-window-name
python3 -m pip install --user libtmux dataclasses
python3 -m pip install dataclasses --user

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
