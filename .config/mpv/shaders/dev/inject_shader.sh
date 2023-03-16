#!/bin/sh -e

# adds a bunch of spaces for easier processing
sed 's/[[:space:](;]/& /g' | ./inject_shader "$@"

