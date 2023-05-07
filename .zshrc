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

setopt correctall                 # Turn On Corrections

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
znap source marlonrichert/zsh-autocomplete
znap source zdharma-continuum/fast-syntax-highlighting
znap source zsh-users/zsh-completions

# brew
eval $(/opt/homebrew/bin/brew shellenv)

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_CTRL_T_COMMAND="rg --files --hidden --no-ignore-vcs -g '!{node_modules,.git}'"
alias f="rg --files --hidden --no-ignore-vcs -g '!{node_modules,.git}' | fzf"
alias vif='vim $(f)'
bindkey '^[[A'  fzf-history-widget

# `znap eval` caches any kind of command output for you.
znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

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
