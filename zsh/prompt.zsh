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
for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
	eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
	eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
	(( count = $count + 1 ))
done

PR_NO_COLOR="%{$terminfo[sgr0]%}"
RPS1='$PR_RED(%D{%m-%d %H:%M})$PR_NO_COLOR'
#LANGUAGE=
LC_ALL='en_US.UTF-8'
LANG='en_US.UTF-8'
LC_CTYPE=C
DISPLAY=:0

export PS1='[$PR_RED%n$PR_NO_COLOR@$PR_YELLOW%U%m%u$PR_NO_COLOR:$PR_RED%2c$PR_GREEN($(vcs_get_location))$PR_NO_COLOR]%(!.#.$) '

export LSCOLORS=bxfxdxexcxgxgaabagacad
export CLICOLOR=true

