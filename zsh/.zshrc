export EDITOR="nvim"
export LS_COLORS="$(vivid generate snazzy)"

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh-history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS

alias ls='eza --color=always --icons=always --group-directories-first --hyperlink'
alias vi='nvim'
alias rm='trash-put'
alias coffee='wayland-idle-inhibitor.py'

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(mise activate zsh)"
export PATH="$PATH:$HOME/flutter/bin"
export CHROME_EXECUTABLE="/usr/bin/google-chrome-stable"

# Created by `pipx` on 2026-07-18 10:58:38
export PATH="$PATH:/home/sh1ragami/.local/bin"
