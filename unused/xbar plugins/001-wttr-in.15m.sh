#!/bin/zsh

# https://github.com/matryer/xbar-plugins/blob/main/CONTRIBUTING.md#writing-plugins
# https://github.com/chubin/wttr.in#one-line-output


output="$(curl -s "https://wttr.in/Berlin?format=1" | tr -d "+")"

if [[ "$output" =~ "°" ]] ; then
	echo "$output"
	echo "---"
	curl -s "https://wttr.in/Berlin?format=4"
fi

