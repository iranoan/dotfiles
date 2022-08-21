#!/bin/sh
# set -x
d=${0}
d=${d%/*}/
d="$( eval cd "${d%/*}" 2>/dev/null; pwd )/${d##*/}"

find "$d" -maxdepth 1 -regextype posix-extended -regex '.+/\.[A-Za-z0-9_.-]+$' | while read -r f ; do
	f="$( eval cd "${f%/*}" 2>/dev/null; pwd )/${f##*/}"
	l=$HOME/${f##*/}
	if [ "${f##*.}" = "swp" ]; then
		continue
	elif [ "$f" = "$d.git" ]; then
		continue
	elif [ "$f" = "$d.gitignore" ]; then
		continue
	elif [ -L "$l" ]; then
		if [ "$( readlink -f "$l" )" = "$f" ]; then
			continue
		fi
		rm "$l"
	elif [ -e "$l" ] ; then
		rm -r "$l"
	fi
	ln -s "$f" "$l"
done

if command -v tmux > /dev/null ; then # make tmux plugin directory
	mkdir -p ~/.tmux/plugins/
fi

exit 0
