# ~/.bashrc

# If not running interactively, do not do anything
[[ $- != *i* ]] && return

. ~/.aliases

RESET="\[$(tput sgr0)\]"

# Cute informative PS1 for su
if [[ $UID -eq 0 ]]; then
	RED="\[$(tput setaf 1)\]"
	PS1="[${RED}\w${RESET}] ${RED}#${RESET} "
else
	GREEN="\[$(tput setaf 2)\]"
	PS1="[${GREEN}\w${RESET}] ${GREEN}\$${RESET} "
fi

