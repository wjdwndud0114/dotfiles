# Load aliases
if [ -f ~/.zalias ]; then
    . ~/.zalias
fi

if [ -f ~/.zalias-bo ]; then
    . ~/.zalias-bo
fi

# Machine-local alias overrides (untracked): .zalias-bo, .zalias-dbx, etc.
if [ -f ~/.zalias-dbx ]; then
    . ~/.zalias-dbx
fi

# Rust toolchain (only if installed — absent on some devboxes).
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Devboxes have no xdg-open, so anything that wants to launch a browser (codex
# mcp login, gh auth) fails and prints a URL too long to stay clickable once it
# wraps. tty-open hands it to the terminal as a short OSC 8 link plus an OSC 52
# clipboard copy instead. Linux only — the Mac has a real browser.
case "$(uname)" in
Linux)
    [ -x "$HOME/.local/bin/tty-open" ] && export BROWSER="$HOME/.local/bin/tty-open"
    ;;
esac
