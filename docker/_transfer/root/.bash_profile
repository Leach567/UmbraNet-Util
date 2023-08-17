alias ll="ls -lht"
alias grep="grep -rn --color=auto"
alias ff='find -L -name "*.h" -o -name "*.cpp" -o -name ".bash" -o -name "*.json"'
alias ..="cd .."
alias ...="cd ../.."

if [ -e /umbra_dev/_containerConfig.bash ]
then
    . /umbra_dev/_containerConfig.bash
fi
