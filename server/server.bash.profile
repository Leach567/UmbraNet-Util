#!/bin/bash
. `dirname ${BASH_SOURCE[0]}`/../umbraFormatUtil.bash
export UMBRA_REPO_ROOT="/repos"
export UMBRA_UTIL_ROOT="${UMBRA_REPO_ROOT}/UmbraNet-Util"
export UMBRA_DOCKER_ROOT="${UMBRA_UTIL_ROOT}/docker"
# Function to get the current Git branch
parse_git_branch() {
     git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Update the Bash prompt (PS1)
export PS1="${MAGENTA}\u@\h${RESET} ${GREEN}\w${YELLOW}\$(parse_git_branch)${RESET} \$ "

alias ..="cd ../"
alias ...="cd ../../"
alias ....="cd ../../../"
