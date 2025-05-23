# vi: ft=sh
# This file is read each time a login shell is started.

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

export TZ='America/Chicago'

[ "$0" = "-ash" ] && export ENV="$HOME/.ashrc"

HOSTNAME="$(uname -n)"; export HOSTNAME;

export WWW_HOME='https://duckduckgo.com/lite'

export SVDIR="$HOME/.config/service/"

export TERMINAL='footclient'
export TERMCMD="$TERMINAL"

export BEMENU_OPTS='-p "" --fn "Fira Code 10" --nf #ebdbb2 --tf #ebdbb2 --ff #ebdbb2 --hf #282828 --fb #282828 --nb #282828 --tb #282828 --hb #ebdbb2 --ab #282828 --af #ebdbb2 --cb #282828 --cf #ebdbb2'
export MENU='bemenu -i -l 10'

export MCO_HANDLER="$HOME/.mcohandler"

export ALSA_MASTER='Master'
export ALSA_CARD='CODEC'

if command -v vim > /dev/null 2>&1; then
	export EDITOR='vim'
else
	export EDITOR='vi'
fi

export NNN_TRASH=1
export NNN_OPTS=Ac

if less --help 2>&1 | head -n 1 | grep -qi busybox; then
	export PAGER='less -RI'
else
	export PAGER='less'
	export LESS='-Ris --save-marks'
fi

export SUDO='doas'

export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0

export GOPATH="$HOME/.local"

# needed for sway w/o elogind
[ "$XDG_RUNTIME_DIR" ] || export XDG_RUNTIME_DIR=$(mktemp -d /tmp/runtime-dir-XXXXXX)

