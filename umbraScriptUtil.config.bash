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
function PrintCallerFn(){
	LOG_LABEL=""
	LOG_MESSAGE="[${YELLOW}${FUNCNAME[1]}${RESET} as ${MAGENTA}${USER}${RESET}]"
	printLog
}
export -f PrintCallerFn
function PrintCallerScript(){
	LOG_LABEL=""
	LOG_MESSAGE="[${YELLOW}${BASH_SOURCE[1]}${RESET} as ${MAGENTA}${USER}${RESET}]"
	printLog
}
export -f PrintCallerScript
function PrintErr(){
	LOG_LABEL="${BRIGHT_RED}Error${RESET}"
	LOG_MESSAGE="[`basename ${BASH_SOURCE[1]}` at line ${BASH_LINENO[0]}]::${1}"
	printLog
}
export -f PrintErr
#============================[ END Logging Functions ]======================================
