#!/bin/sh
# This file is read each time a login shell is started.

. ~/.shrc

# Sway doesn't start w/o this
if [ -z "$XDG_RUNTIME_DIR" ]; then
	XDG_RUNTIME_DIR="/tmp/$(id -u)-runtime-dir"; export XDG_RUNTIME_DIR;
	[ ! -d "$XDG_RUNTIME_DIR" ] && mkdir --mode=0700 "$XDG_RUNTIME_DIR"
fi

