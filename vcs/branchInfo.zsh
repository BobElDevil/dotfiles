# Set of functions designed to calculate the current git branch or jj change id and put it into an environment variable.
# Used in my prompt definitions
function parse_git_branch() {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function parse_jj_changeId() {
  jj show 2> /dev/null | grep "Change ID:" | sed -e 's/Change ID: //' | cut -c 1-8
}

function vcs_compute_location() {
  local GIT_BRANCH="$(parse_git_branch)"
  local JJ_CHANGE="$(parse_jj_changeId)"

  export __CURRENT_VCS_LOCATION_INVALID=
  if [ -n "$JJ_CHANGE" ]; then
    export __CURRENT_VCS_LOCATION=$JJ_CHANGE
  elif [ -n "$GIT_BRANCH" ]; then
    export __CURRENT_VCS_LOCATION=$GIT_BRANCH
  else
    export __CURRENT_VCS_LOCATION=""
  fi
}

function vcs_invalidate_location() {
	export __CURRENT_VCS_LOCATION_INVALID=1
}

typeset -ga chpwd_functions
typeset -ga preexec_functions

preexec_functions+='preexec_update_vcs_location'
preexec_update_vcs_location() {
	case $2 in 
    git*) vcs_invalidate_location ;;
    jj*) vcs_invalidate_location ;;
	esac
}

chpwd_functions+='chpwd_update_vcs_location'
chpwd_update_vcs_location() {
	vcs_invalidate_location
}

function vcs_get_location() {
	test -n "$__CURRENT_VCS_LOCATION_INVALID" && vcs_compute_location
	echo $__CURRENT_VCS_LOCATION
}

vcs_compute_location

