# This file is read each time a login shell is started.

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

export PATH="$HOME/bin/:$HOME/.local/bin/:$HOME/.cargo/bin/:/var/lib/snapd/snap/bin/:$PATH"

export TERMINAL='alacritty'
export TERMCMD='alacritty -e'

export RANGER_LOAD_DEFAULT_RC='FALSE'

export ALSA_MASTER='PCM'

export EDITOR='vim'
export LESS='-Ri'

export GTK_THEME='Breeze-Dark'
export QT_QPA_PLATFORMTHEME='qt5ct'

# Sway doesn't start w/o this
if [ -z "$XDG_RUNTIME_DIR" ]; then
	export XDG_RUNTIME_DIR="/tmp/${UID}-runtime-dir"
	[ ! -d "$XDG_RUNTIME_DIR" ] && mkdir --mode=0700 "$XDG_RUNTIME_DIR"
fi

