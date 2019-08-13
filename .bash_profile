# This file is read each time a login shell is started.

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

xdg-user-dirs-update
. ~/.config/user-dirs.dirs

export PATH="$HOME/.firejail/:$HOME/bin/:$HOME/.local/bin/:$HOME/.cargo/bin/:/var/lib/snapd/snap/bin/:$PATH"

export WINDOWMANAGER="i3"

export TERMINAL="termite"
export TERMCMD="termite_exec"

export RANGER_LOAD_DEFAULT_RC="FALSE"

export EDITOR="vim"

export QT_QPA_PLATFORMTHEME="qt5ct"

export LESS="-Ri"

