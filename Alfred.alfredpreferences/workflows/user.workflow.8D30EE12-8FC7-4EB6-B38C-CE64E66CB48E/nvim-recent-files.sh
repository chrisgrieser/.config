#!/bin/zsh

temp=/tmp/oldfiles.txt
[[ -e "$temp" ]] && rm "$temp"
nvim -c "redir > $temp | silent oldfiles | redir end | q"

cut -d" " -f2 "$temp" | while read -r line; do # only output existing files
	[[ ! -f "$line" ]] || echo "$line"
done
