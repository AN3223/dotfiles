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

if [[ "$SSH_CONNECTION" ]]; then
	PS1="(SSH) ${PS1}"
fi

# This prevents C-s from being annoying in vim
stty -ixon

