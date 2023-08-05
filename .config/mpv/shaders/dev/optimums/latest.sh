#!/bin/sh -e
#
# ./latest.sh file
#
# Returns the latest cfgopts from an optimum file
#

sed '/^$/d ; /^\#/d' "$1" | tail -n 1 | cut -f 1

