#!/bin/sh -e
#
# ./latest.sh file [plane]
#
# Returns the latest cfgopts from an optimum file. If "plane" is 
# specified then this script will treat "file" as a path to a shader and 
# attempt to map that path to the appropriate optimum path.
#

file="$1"
if [ "$2" ]; then
	file="$1"
	file="${file#../}"
	file="${file%.*}"
	case "$file" in
		*/*) ;;
		*)
			file="DEFAULT/$file" ;;
	esac
	file="optimums/$file/$2"
fi

sed '/^$/d ; /^\#/d' "$file" | tail -n 1 | cut -f 1

