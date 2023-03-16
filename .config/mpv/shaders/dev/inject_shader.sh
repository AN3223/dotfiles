#!/bin/sh -e

# adds a bunch of spaces for easier processing
sed 's/[[:space:](;]/& /g' | ./inject_shader "$@" | sed 's/  / /g; s/( /(/g'

