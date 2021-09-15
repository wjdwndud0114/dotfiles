export CACHEDIR="$HOME/.local/share"
[[ -d "$CACHEDIR" ]] || mkdir -p "$CACHEDIR"

export EDITOR="/usr/bin/vim"

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

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPS="--extended"
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'
export FZF_CTRL_T_COMMAND="rg --files --hidden --no-ignore-vcs -g '!{node_modules,.git}'"
alias f="rg --files --hidden --no-ignore-vcs -g '!{node_modules,.git}' | fzf"
alias vif='vim $(f)'

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

# Pure theme
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'

### End of Zinit's installer chunk

zinit lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    zdharma/fast-syntax-highlighting \
    marlonrichert/zsh-autocomplete \
  blockf \
    zsh-users/zsh-completions \
  pick"async.zsh" src"pure.zsh" \
    sindresorhus/pure

#zinit wait lucid light-mode for \
# zinit light-mode for \
#   atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
#   zdharma/fast-syntax-highlighting \
#   marlonrichert/zsh-autocomplete \
#   pick"async.zsh" src"pure.zsh" \
#     sindresorhus/pure
#   atpull'zinit creinstall -q'\
#       zsh-users/zsh-completions

autoload -U promptinit; promptinit

# Add Visual Studio Code (code)
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# n - node management
export N_PREFIX=~/.n
export PATH="$PATH:$HOME/.n/bin"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="$HOME/.tfenv/bin:$PATH"
export PATH="$HOME/.tgenv/bin:$PATH"
