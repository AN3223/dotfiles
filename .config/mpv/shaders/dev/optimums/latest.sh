#!/bin/sh -e
#
# ./latest.sh [FILE]...
#
# Returns the latest cfgopts from optimum files
# 
# Also returns the scores when multiple files are passed, for 
# comparisons.
#

for file; do
	if [ "$#" -gt 1 ]; then
		printf '%s: ' "$file"
		sed '/^$/d ; /^\#/d' "$file" | tail -n 1
	else
		sed '/^$/d ; /^\#/d' "$file" | tail -n 1 | cut -f 1
	fi
done

