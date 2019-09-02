# This file is read each time a login shell is started.

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

export PATH="$HOME/bin/:$HOME/.local/bin/:$HOME/.cargo/bin/:/var/lib/snapd/snap/bin/:$PATH"

export WINDOWMANAGER="i3"

export TERMINAL="alacritty"
export TERMCMD="alacritty -e"

# Sway doesn't work w/o this
if [ -z "$XDG_RUNTIME_DIR" ]; then
	export XDG_RUNTIME_DIR="/tmp/${UID}-runtime-dir"
	if [ ! -d "$XDG_RUNTIME_DIR" ]; then
		mkdir "$XDG_RUNTIME_DIR"
		chmod 0700 "$XDG_RUNTIME_DIR"
	fi
fi

export RANGER_LOAD_DEFAULT_RC="FALSE"

export EDITOR="vim"

export QT_QPA_PLATFORMTHEME="qt5ct"

export LESS="-Ri"


