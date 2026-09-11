#!/bin/bash
export DATE_STAMP="`date +%Y%m%d`"
export DATE_STAMP_MINS="`date +%Y%m%d_%H%M`"
#============================[ Colors & Formatting ]======================================
#!/usr/bin/env bash

# --- ANSI Escape Code Definitions ---

# Reset all attributes
export RESET='\e[0m'

# Text Colors
export BLACK='\e[30m'
export RED='\e[31m'
export GREEN='\e[32m'
export YELLOW='\e[33m'
export BLUE='\e[34m'
export MAGENTA='\e[35m'
export CYAN='\e[36m'
export WHITE='\e[37m'

# Bright Text Colors
export BRIGHT_BLACK='\e[90m'
export BRIGHT_RED='\e[91m'
export BRIGHT_GREEN='\e[92m'
export BRIGHT_YELLOW='\e[93m'
export BRIGHT_BLUE='\e[94m'
export BRIGHT_MAGENTA='\e[95m'
export BRIGHT_CYAN='\e[96m'
export BRIGHT_WHITE='\e[97m'

# Background Colors
export BG_BLACK='\e[40m'
export BG_RED='\e[41m'
export BG_GREEN='\e[42m'
export BG_YELLOW='\e[43m'
export BG_BLUE='\e[44m'
export BG_MAGENTA='\e[45m'
export BG_CYAN='\e[46m'
export BG_WHITE='\e[47m'

# Bright Background Colors
export BG_BRIGHT_BLACK='\e[100m'
export BG_BRIGHT_RED='\e[101m'
export BG_BRIGHT_GREEN='\e[102m'
export BG_BRIGHT_YELLOW='\e[103m'
export BG_BRIGHT_BLUE='\e[104m'
export BG_BRIGHT_MAGENTA='\e[105m'
export BG_BRIGHT_CYAN='\e[106m'
export BG_BRIGHT_WHITE='\e[107m'

# Formatting Attributes
export BOLD='\e[1m'
export DIM='\e[2m'
export ITALIC='\e[3m'
export UNDERLINE='\e[4m'
export BLINK='\e[5m'
export INVERSE='\e[7m'
export HIDDEN='\e[8m'
export STRIKE='\e[9m'

#============================[ END Colors & Formatting ]======================================
#============================[ Logging Functions ]======================================

LOG_LABEL=""
LOG_MESSAGE=""

function printLog(){
	if [[ -z "${LOG_LABEL}" ]]; then
		echo -e "${LOG_MESSAGE}"
	else
		echo -e "{${LOG_LABEL}}:${LOG_MESSAGE}"
	fi
	LOG_LABEL=""
	LOG_MESSAGE=""
}
function Print(){
	LOG_LABEL="${BRIGHT_CYAN}Info${RESET}"
	LOG_MESSAGE="${1}"
	printLog
}
export -f Print
function PrintDbg(){
	if [[ "${DEBUG}" != "1" ]]; then
		return
	fi
	LOG_LABEL="${BRIGHT_GREEN}Debug${RESET}"
	LOG_MESSAGE="[${YELLOW}${FUNCNAME[1]}${RESET} as ${MAGENTA}${USER}${RESET}]::${1}"
	printLog
}
export -f PrintDbg
function PrintCaller(){
	LOG_LABEL=""
	LOG_MESSAGE="[${YELLOW}${FUNCNAME[1]}${RESET} as ${MAGENTA}${USER}${RESET}]"
	printLog
}
export -f PrintCaller
function PrintErr(){
	LOG_LABEL="${BRIGHT_RED}Error${RESET}"
	LOG_MESSAGE="[`basename ${BASH_SOURCE[1]}` at line ${BASH_LINENO[0]}]::${1}"
	printLog
}
export -f PrintErr
#============================[ END Logging Functions ]======================================
