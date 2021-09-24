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

export BEMENU_OPTS='-p "" --fn "JetBrains Mono Nerd Font 10" --nf #ebdbb2 --tf #ebdbb2 --ff #ebdbb2 --hf #282828 --fb #282828 --nb #282828 --tb #282828 --hb #ebdbb2'
export MENU='bemenu -i -l 10'

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
[ "$XDG_RUNTIME_DIR" ] || export XDG_RUNTIME_DIR=$(mktemp -d /tmp/runtime-dir-XXXXXX)

# prompt the user for their gpg passphrase, so it can be cached for
# unattended use
tpm show blank

