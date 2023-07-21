#!/usr/bin/env zsh

# WARN do not embed this file into the js file, otherwise it does revtrieve the
# proper oldfiles, since it then lacks information on the location of the shada
# file for some reason
temp=/tmp/oldfiles.txt
[[ -e "$temp" ]] && rm "$temp"
nvim -c "redir > $temp | echo v:oldfiles | redir end | q" &>/dev/null
tr "'" '"' <"$temp" # single quotes invalid in json
