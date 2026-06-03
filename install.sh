#!/usr/bin/env bash
#
# install.sh — set up dotfiles: symlink configs, install packages, plugins.
# Safe to re-run; it is idempotent.

set -euo pipefail

# Resolve the dotfiles dir from this script's location, not the caller's $PWD,
# so the script works no matter where it is invoked from.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# link SRC DEST — symlink SRC to DEST, replacing any existing symlink and
# backing up a real file/dir that is in the way.
link() {
  local src=$1 dest=$2
  if [[ -L "$dest" ]]; then
    rm -f "$dest"
  elif [[ -e "$dest" ]]; then
    local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    echo "  backing up existing $dest -> $backup"
    mv "$dest" "$backup"
  fi
  ln -sfn "$src" "$dest"
}

echo "Symlinking dotfiles..."
link "$DIR/.vimrc"     ~/.vimrc
link "$DIR/.tmux.conf" ~/.tmux.conf
link "$DIR/.zshenv"    ~/.zshenv
link "$DIR/.zalias"    ~/.zalias
link "$DIR/.zshrc"     ~/.zshrc

mkdir -p ~/.config
for file in "$DIR"/.config/*; do
  link "$file" "$HOME/.config/$(basename "$file")"
done

echo "Installing Homebrew..."
if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

echo "Installing packages from Brewfile..."
brew bundle --file="$DIR/Brewfile"

# fzf shell integration (key bindings + completion -> ~/.fzf.zsh)
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc

echo "Installing tmux plugins..."
declare -A TMUX_PLUGINS=(
  [tpm]="https://github.com/tmux-plugins/tpm"
  [tmux-sensible]="https://github.com/tmux-plugins/tmux-sensible"
  [tmux-onedark-theme]="https://github.com/odedlaz/tmux-onedark-theme"
  [tmux-window-name]="https://github.com/ofirgall/tmux-window-name"
)
mkdir -p ~/.tmux/plugins
for name in "${!TMUX_PLUGINS[@]}"; do
  dest="$HOME/.tmux/plugins/$name"
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull --ff-only --quiet || true
  else
    git clone --depth 1 "${TMUX_PLUGINS[$name]}" "$dest"
  fi
done
# tmux-window-name needs libtmux (dataclasses ships with Python 3.7+).
python3 -m pip install --user --upgrade libtmux 2>/dev/null \
  || python3 -m pip install --user --upgrade --break-system-packages libtmux \
  || echo "  warning: could not install libtmux (needed by tmux-window-name)"

echo "Configuring git-delta..."
git config --global core.pager "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default

echo "Installing nvm..."
# Install into the same dir .zshrc sources ($NVM_DIR).
export NVM_DIR="$HOME/.config/nvm"
if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  mkdir -p "$NVM_DIR"
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
fi

echo "Setting up TERM with xterm-256color-italic..."
if [[ ! -f "$DIR/xterm-256color-italic.terminfo" ]]; then
  curl -fsSL \
    https://gist.githubusercontent.com/sos4nt/3187620/raw/bca247b4f86da6be4f60a69b9b380a11de804d1e/xterm-256color-italic.terminfo \
    -o "$DIR/xterm-256color-italic.terminfo"
fi
tic "$DIR/xterm-256color-italic.terminfo"

# macOS-only: disable font smoothing for crisper text in terminals.
if [[ "$(uname)" == "Darwin" ]]; then
  defaults write -g AppleFontSmoothing -int 0
fi

echo
echo "Installation complete! Relogin please."
echo "Merge .gitconfig file for git-delta!"
