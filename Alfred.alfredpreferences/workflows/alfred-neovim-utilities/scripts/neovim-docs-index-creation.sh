#!/usr/bin/env zsh

baseHelpURL="https://neovim.io/doc/user/"
baseRawURL="https://raw.githubusercontent.com/neovim/neovim/master/runtime/doc/"
dataLocation="./data"
#───────────────────────────────────────────────────────────────────────────────

[[ -d "$dataLocation" ]] || mkdir -p "$dataLocation/neovim-help"
cd "$dataLocation" || return 1

# DOWNLOAD

echo "Downloading doc files…"
curl -s 'https://api.github.com/repos/neovim/neovim/git/trees/master?recursive=1' |
	grep -Eo "runtime/doc/.*.txt" |
	cut -d/ -f3 |
	while read -r file; do
		echo -n "#"
		curl -s "$baseRawURL$file" >"./neovim-help/$file"
	done

#───────────────────────────────────────────────────────────────────────────────

cd "./neovim-help" || return 1
echo "Parsing doc files…"

# OPTIONS
echo "Options…"
vimoptions=$(grep -Eo "\*'[.A-Za-z-]{2,}'\*(.*'.*')?" options.txt |
	tr -d "*'" |
	while read -r line; do
		opt=$(echo "$line" | cut -d" " -f1)
		if [[ "$line" =~ " " ]]; then
			synonyms=",$(echo "$line" | cut -d" " -f2-)"
		else
			synonyms=""
		fi
		echo "${baseHelpURL}options.html#'$opt',$synonyms"
	done)

# ANCHORS
echo "Anchors…"
anchors=$(grep -REo "\*([()_.:A-Za-z-]+|[0-9E]+)\*(.*\*.*\*)?" |
	tr -d "*" |
	sed 's/txt:/html#/' |
	cut -c3- |
	while read -r line; do
		url=$(echo "$line" | cut -d" " -f1 | sed 's/:/%3A/')
		if [[ "$line" =~ " " ]]; then
			synonyms=",$(echo "$line" | cut -d" " -f2-)"
		else
			synonyms=""
		fi
		echo "${baseHelpURL}$url,$synonyms"
	done)

# SECTIONS
echo "Sections…"
sections=$(grep -Eo "\|[.0-9]*\|.*" usr_toc.txt |
	tr -d "|" |
	while read -r line; do
		file=$(echo "$line" | cut -c-2)
		title="$line"
		echo "${baseHelpURL}usr_$file.html#$title"
	done)

#───────────────────────────────────────────────────────────────────────────────

echo "Writing Index & cleaning up…"
cd .. # back to `$dataLocation`

echo "$vimoptions" >"url-list.txt"
echo "$anchors" >>"url-list.txt"
echo "$sections" >>"url-list.txt"

echo "$(wc -l "url-list.txt" | tr -d ' ') entries."
rm -r "./neovim-help"
