# vi: ft=sh
# This file is read each time a login shell is started.

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

export TZ='America/Chicago'

[ "$0" = "-ash" ] && export ENV="$HOME/.ashrc"

HOSTNAME="$(uname -n)"; export HOSTNAME;

export WWW_HOME='https://duckduckgo.com/lite'

export SVDIR="$HOME/.config/service/"

export TERMINAL='alacritty'
export TERMCMD='alacritty -e'

export MCO_HANDLER="$HOME/.mcohandler"

export ALSA_MASTER='PCM'
export ALSA_CARD='CODEC'

if command -v vim > /dev/null 2>&1; then
	export EDITOR='vim'
else
	export EDITOR='vi'
fi

if less --help 2>&1 | head -n 1 | grep -qi busybox; then
	export PAGER='less -RI'
else
	export PAGER='less'
	export LESS='-Ri --save-marks'
fi

export SUDO='doas'

export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

export GOPATH="$HOME/.local"

export MAIL="$HOME/.maildir"

# needed for sway w/o elogind
if [ ! "$XDG_RUNTIME_DIR" ]; then
	XDG_RUNTIME_DIR=/tmp/$(id -u)-runtime-dir; export XDG_RUNTIME_DIR;
	[ ! -d "$XDG_RUNTIME_DIR" ] && mkdir "$XDG_RUNTIME_DIR"
	chmod -R 700 "$XDG_RUNTIME_DIR"
fi

# prompt the user for their gpg passphrase, so it can be cached for
# unattended use
tpm show blank

