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
    local backup
    backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
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

# cmux also reads a Ghostty config from Application Support.
CMUX_SUPPORT="$HOME/Library/Application Support/com.cmuxterm.app"
if [[ -d "$CMUX_SUPPORT" ]]; then
  link "$DIR/.config/cmux/config.ghostty" "$CMUX_SUPPORT/config.ghostty"
fi

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

# Alacritty is installed here rather than from the Brewfile: it ships
# adhoc-signed and unnotarized, so its cask fails Homebrew's Gatekeeper check
# and is scheduled for removal on 2026-09-01. Pulling the release DMG with
# curl avoids that, and curl (unlike a browser) never sets
# com.apple.quarantine, so Gatekeeper does not block the result either.
#
# Keep this at 0.15.0 or newer. Older builds report the release of Enter, Tab
# and Backspace as the same bytes as the press when an application enables
# kitty keyboard event reporting, which makes those keys fire twice in herdr.
ALACRITTY_VERSION="0.17.0"
if [[ "$(uname)" == "Darwin" ]]; then
  echo "Installing Alacritty $ALACRITTY_VERSION..."
  installed=""
  if [[ -d /Applications/Alacritty.app ]]; then
    installed="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" \
      /Applications/Alacritty.app/Contents/Info.plist 2>/dev/null || true)"
  fi
  if [[ "$installed" == "$ALACRITTY_VERSION" ]]; then
    echo "  already installed"
  else
    alacritty_tmp="$(mktemp -d)"
    curl -fsSL -o "$alacritty_tmp/Alacritty.dmg" \
      "https://github.com/alacritty/alacritty/releases/download/v$ALACRITTY_VERSION/Alacritty-v$ALACRITTY_VERSION.dmg"
    mkdir -p "$alacritty_tmp/mnt"
    hdiutil attach -readonly -nobrowse -mountpoint "$alacritty_tmp/mnt" \
      "$alacritty_tmp/Alacritty.dmg" >/dev/null
    rm -rf /Applications/Alacritty.app
    cp -R "$alacritty_tmp/mnt/Alacritty.app" /Applications/Alacritty.app
    xattr -cr /Applications/Alacritty.app 2>/dev/null || true
    hdiutil detach "$alacritty_tmp/mnt" >/dev/null
    rm -rf "$alacritty_tmp"
    echo "  installed ${installed:-none} -> $ALACRITTY_VERSION"
  fi
fi

echo "Installing tmux plugins..."
# Plain list (not an associative array) so this runs on macOS's bash 3.2.
# Each plugin's dir name is just the basename of its repo URL.
TMUX_PLUGINS=(
  "https://github.com/tmux-plugins/tpm"
  "https://github.com/tmux-plugins/tmux-sensible"
  "https://github.com/odedlaz/tmux-onedark-theme"
  "https://github.com/ofirgall/tmux-window-name"
)
mkdir -p ~/.tmux/plugins
for url in "${TMUX_PLUGINS[@]}"; do
  dest="$HOME/.tmux/plugins/$(basename "$url")"
  if [[ -d "$dest/.git" ]]; then
    git -C "$dest" pull --ff-only --quiet || true
  else
    git clone --depth 1 "$url" "$dest"
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
  # PROFILE=/dev/null stops nvm's installer from appending its own init block
  # to ~/.zshrc — .zshrc already sources $NVM_DIR/nvm.sh.
  PROFILE=/dev/null curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
fi

echo "Installing Rust (rustup/cargo)..."
# .zshenv sources $HOME/.cargo/env, so make sure it exists.
if [[ ! -f "$HOME/.cargo/env" ]]; then
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path
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

# Lint this script (non-fatal) so regressions surface during setup.
if command -v shellcheck >/dev/null 2>&1; then
  echo "Linting install.sh with shellcheck..."
  shellcheck -S warning "$DIR/install.sh" || echo "  (shellcheck reported warnings; not fatal)"
fi

echo
echo "Installation complete! Relogin please."
echo "Merge .gitconfig file for git-delta!"
