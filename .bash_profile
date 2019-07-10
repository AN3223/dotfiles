# This file is read each time a login shell is started.

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

export PATH="$HOME/.firejail/:$HOME/bin/:$HOME/.local/bin/:$HOME/.cargo/bin/:/var/lib/snapd/snap/bin/:$PATH"

export WINDOWMANAGER="i3"

export TERMINAL="termite"

export EDITOR="nvim"

export QT_QPA_PLATFORMTHEME="gtk2"

export LESS="-Ri"

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
	echo "Enter '1' for lightdm, '2' for startx, 'q' for nothing, or anything else for sway"
	read selection && case $selection in
		1)
			sudo systemctl start lightdm
			;;
		2)
			startx
			;;
		q)
			;;
		*)
			source wayenv
			sway
			;;
	esac
fi

