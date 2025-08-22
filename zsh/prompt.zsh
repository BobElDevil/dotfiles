autoload colors zsh/terminfo
# Set Apple Terminal.app resume directory
if [[ $TERM_PROGRAM == "Apple_Terminal" ]] && [[ -z "$INSIDE_EMACS" ]] {
    update_terminal_cwd() {
        [[ -t 1 ]] || return # Returns if not a terminal (i.e., a subshell)
        local SEARCH=' '
        local REPLACE='%20'
        local PWD_URL="file://$HOSTNAME${PWD//$SEARCH/$REPLACE}"
        printf '\e]7;%s\a' $PWD_URL
    }
    update_terminal_cwd
    chpwd_functions+=(update_terminal_cwd)
}

if [[ "$terminfo[colors]" -ge 8 ]]; then
	colors
fi

RPS1='%B%F{red}(%D{%m-%d %H:%M})%f%b'
#LANGUAGE=
LC_ALL='en_US.UTF-8'
LANG='en_US.UTF-8'
LC_CTYPE=C
DISPLAY=:0

export PS1='%B%F{green}[%F{red}%n%f@%F{yellow}%U%m%u%f:%F{red}%2c%F{green}]%(!.#.$)%f%b '

export LSCOLORS=bxfxdxexcxgxgaabagacad
export CLICOLOR=true

