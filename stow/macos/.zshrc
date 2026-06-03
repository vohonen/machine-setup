HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE SHARE_HISTORY APPEND_HISTORY

# vi mode + C-l to clear in both insert and command mode (matches old `set -o vi` + bind C-l)
bindkey -v
bindkey -M viins '^L' clear-screen
bindkey -M vicmd '^L' clear-screen

# BSD ls colors (no GNU dircolors on macOS); keep grep color
export CLICOLOR=1
alias grep='grep --color=auto'

autoload -Uz compinit
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi
compinit

export EDITOR=nvim
export TEXMFHOME=$HOME/.texmf

# green [user] blue cwd $  - same shape as the old bash PS1
PROMPT='%F{green}[%n]%f %F{blue}%~%f $ '

[ -f ~/.zsh_aliases ] && source ~/.zsh_aliases
