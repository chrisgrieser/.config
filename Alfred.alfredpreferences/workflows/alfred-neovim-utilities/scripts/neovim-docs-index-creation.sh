#!/usr/bin/env zsh
# shellcheck disable=2154

baseHelpURL="https://neovim.io/doc/user/"
baseRawURL="https://raw.githubusercontent.com/neovim/neovim/master/runtime/doc/"
#───────────────────────────────────────────────────────────────────────────────

workflow_location="$PWD"
mkdir -p "/tmp/neovim-help"
cd "/tmp/" || return 1

# DOWNLOAD
# echo "Downloading…" >&2
curl -sL 'https://api.github.com/repos/neovim/neovim/git/trees/master?recursive=1' |
	grep -Eo "runtime/doc/.*.txt" |
	cut -d/ -f3 |
	while read -r file; do
		echo -n "#"
		curl -sL "$baseRawURL$file" >"./neovim-help/$file"
	done

#───────────────────────────────────────────────────────────────────────────────

cd "./neovim-help" || return 1

# OPTIONS
echo "Options…" >&2
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
echo "Anchors…" >&2
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
echo "Sections…" >&2
sections=$(grep -Eo "\|[.0-9]*\|.*" usr_toc.txt |
	tr -d "|" |
	while read -r line; do
		file=$(echo "$line" | cut -c-2)
		title="$line"
		echo "${baseHelpURL}usr_$file.html#$title"
	done)

#───────────────────────────────────────────────────────────────────────────────

cd "$workflow_location" || return 1

echo "Writing index…" >&2
mkdir -p "./data"
echo "$vimoptions" >"./data/neovim-help-index-urls.txt"
echo "$anchors" >>"./data/neovim-help-index-urls.txt"
echo "$sections" >>"./data/neovim-help-index-urls.txt"
