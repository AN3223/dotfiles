# This file is read each time a login shell is started.

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

export PATH="$HOME/.firejail/:$HOME/bin/:$HOME/.local/bin/:$HOME/.cargo/bin/:/var/lib/snapd/snap/bin/:$PATH"

export WINDOWMANAGER="i3"

export TERMINAL="sakura"

export EDITOR="nvim"

export WWW_HOME="https://duckduckgo.com/lite"

export QT_QPA_PLATFORMTHEME="gtk2"

if [ -z "$XDG_RUNTIME_DIR" ]; then
	export XDG_RUNTIME_DIR="/tmp/${UID}-runtime-dir"
	if [ ! -d "$XDG_RUNTIME_DIR" ]; then
		mkdir "$XDG_RUNTIME_DIR"
		chmod 0700 "$XDG_RUNTIME_DIR"
	fi
fi

if [[ ! $DISPLAY ]]; then
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

