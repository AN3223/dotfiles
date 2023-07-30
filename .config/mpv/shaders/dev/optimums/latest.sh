#!/bin/sh -e
# Returns the latest cfgopts from a optimum file

sed '/^$/d ; /^\#/d' "$1" | tail -n 1 | cut -f 1

