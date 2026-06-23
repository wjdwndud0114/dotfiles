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
