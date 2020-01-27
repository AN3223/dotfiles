# vi: ft=sh
# This file is read each time a login shell is started.

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

export TZ='America/Chicago'

[ "$0" = "-ash" ] && export ENV="$HOME/.ashrc"

HOSTNAME="$(uname -n)"; export HOSTNAME;

export WWW_HOME='https://duckduckgo.com/lite'

export XBPS_DISTDIR="$HOME/devel/void-packages/"
export SVDIR="$HOME/.config/service/"

export TERMINAL='alacritty'
export TERMCMD='alacritty -e'

export ALSA_MASTER='PCM'

export EDITOR='vim'
export PAGER='less'
export LESS='-Ri'

export QT_QPA_PLATFORMTHEME='qt5ct'
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

if [ ! "$XDG_RUNTIME_DIR" ]; then
	XDG_RUNTIME_DIR=/tmp/$(id -u)-runtime-dir; export XDG_RUNTIME_DIR;
	[ ! -d "$XDG_RUNTIME_DIR" ] && mkdir "$XDG_RUNTIME_DIR"
fi

