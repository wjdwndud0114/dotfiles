export CACHEDIR="$HOME/.local/share"
[[ -d "$CACHEDIR" ]] || mkdir -p "$CACHEDIR"

export EDITOR=$(which nvim)

# Smart URLs.
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

setopt brace_ccl                # Allow Brace Character Class List Expansion.
setopt combining_chars          # Combine Zero-Length Punctuation Characters ( Accents ) With The Base Character.
setopt rc_quotes                # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
setopt extendedglob             # Extend glob functionalities

# Jobs.
setopt long_list_jobs           # List Jobs In The Long Format By Default.
setopt auto_resume              # Attempt To Resume Existing Job Before Creating A New Process.
setopt notify                   # Report Status Of Background Jobs Immediately.
unsetopt bg_nice                # Don't Run All Background Jobs At A Lower Priority.
unsetopt hup                    # Don't Kill Jobs On Shell Exit.
unsetopt check_jobs             # Don't Report On Jobs When Shell Exit.

setopt correctall               # Turn On Corrections
setopt interactivecomments      # Needed for autocompletion

# History
HISTFILE="${ZDOTDIR:-$HOME}/.zhistory"
HISTSIZE=100000
SAVEHIST=50000
setopt INC_APPEND_HISTORY_TIME
setopt hist_ignore_all_dups     # Prevent history from recording duplicated entries
setopt hist_ignore_space        # Prevent entries from being recorded by preceding them with space
unsetopt beep nomatch

# Download Znap, if it's not there yet.
[[ -f ~/Git/zsh-snap/znap.zsh ]] ||
    git clone https://github.com/marlonrichert/zsh-snap.git ~/Git/zsh-snap

source ~/Git/zsh-snap/znap.zsh  # Start Znap

# `znap prompt` makes your prompt visible in less than 12ms!
znap prompt sindresorhus/pure

# `znap source` automatically downloads and installs your plugins.
znap source zdharma-continuum/fast-syntax-highlighting
znap source marlonrichert/zsh-autocomplete
znap source zsh-users/zsh-completions
znap source wjdwndud0114/zsh_codex

# brew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS="--extended"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_CTRL_T_COMMAND="rg --files --hidden --no-ignore-vcs -g '!{node_modules,.git}'"
alias f="rg --files --hidden --no-ignore-vcs -g '!{node_modules,.git}' | fzf"
alias vif='vim $(f)'
bindkey '^[[A'  fzf-history-widget

# Add Visual Studio Code (code)
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# n - node management
export N_PREFIX=~/.n
export PATH="$PATH:$HOME/.n/bin"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="$HOME/.tfenv/bin:$PATH"
export PATH="$HOME/.tgenv/bin:$PATH"

# Increase node memory
export NODE_OPTIONS="--max-old-space-size=4096"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# vi mode
# zsh already auto-selects vi mode from $EDITOR (nvim), but make it explicit.
bindkey -v
export KEYTIMEOUT=20            # 200ms Esc lag instead of the 400ms default

# Re-assert custom insert-mode binds (bindkey -v reinitializes the main keymap).
bindkey '^x'    create_completion          # zsh_codex
bindkey '^[[A'  fzf-history-widget         # up arrow -> fzf history

# Sensible insert-mode keys that vanilla vi mode omits.
bindkey '^?' backward-delete-char          # backspace deletes past insert point
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# k/j search history in normal mode
bindkey -M vicmd 'k' up-line-or-search
bindkey -M vicmd 'j' down-line-or-search

# Cursor shape: block in normal mode, beam in insert mode.
# add-zle-hook-widget appends rather than replacing the plugins' own hooks.
autoload -Uz add-zle-hook-widget
_vi_cursor_shape() {
  case ${KEYMAP:-main} in
    vicmd)       printf '\e[2 q' ;;   # block
    main|viins)  printf '\e[6 q' ;;   # beam
  esac
}
add-zle-hook-widget keymap-select _vi_cursor_shape
add-zle-hook-widget line-init     _vi_cursor_shape

# >>> harness-engineering setup.sh >>>
export HARNESS_DIR="/Users/kevinj/src/misc/harness-engineering"
alias cl='claude --permission-mode dontAsk --model "global.anthropic.claude-opus-4-8[1m]" --effort max'
# <<< harness-engineering setup.sh <<<
