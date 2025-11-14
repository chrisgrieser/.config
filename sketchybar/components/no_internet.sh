#!/usr/bin/env zsh


test_site="https://www.google.com/"
if curl --silent --head --fail "$test_site" >/dev/null ; then
	draw=false
else
	draw=true
fi

sketchybar --set "$NAME" drawing="$draw"
