fpath=($ZSH/functions $fpath)

autoload -U $ZSH/functions/*(:t)
if [ -d "$ZSH/local-dotfiles/functions" ]; then
    autoload -U $ZSH/local-dotfiles/functions/*(:t)
fi

export HISTFILE=$HOME/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000

#History
setopt INC_APPEND_HISTORY 
setopt APPEND_HISTORY # adds history
setopt SHARE_HISTORY  # adds history incrementally and share it across sessions
setopt HIST_VERIFY
setopt HIST_ALLOW_CLOBBER
setopt HIST_IGNORE_ALL_DUPS  # don't record dupes in history
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY # add timestamps to history

setopt NO_BG_NICE # don't nice background tasks
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS # allow functions to have local options
setopt LOCAL_TRAPS # allow functions to have local traps
setopt PROMPT_SUBST
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF
setopt MENUCOMPLETE

export WORDCHARS=${WORDCHARS:s,/,,}
export HOSTNAME="`hostname`"
export PAGER='less'
export SVN_EDITOR='nvim'
export EDITOR='nvim'

# Set/unset  shell options
unsetopt correct_all
setopt   notify globdots correct pushdtohome cdablevars autolist
setopt   autocd recexact longlistjobs
setopt   autoresume histignoredups pushdsilent noclobber
setopt   autopushd pushdminus extendedglob rcquotes mailwarning
setopt   prompt_subst
unsetopt bgnice autoparamslash

zle -N newtab

bindkey '^r' history-incremental-search-backward
bindkey ' ' magic-space    # also do history expansion on space
bindkey -e
bindkey '\e[3~' delete-char	# This should not be necessary!

# Autoload zsh modules when they are referenced
zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -a zsh/mapfile mapfile
