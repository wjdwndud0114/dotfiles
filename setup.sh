echo "Installing dotfiles..."

DIR=$PWD

# create symlinks
ln -sf $DIR/.vimrc ~/.vimrc
ln -sf $DIR/.tmux.conf ~/.tmux.conf
ln -sf $DIR/.zshenv ~/.zshenv
ln -sf $DIR/.zalias ~/.zalias
ln -sf $DIR/.zshrc ~/.zshrc

echo "Installing packages..."
brew install fzf

echo "Installation complete! Relogin please"
