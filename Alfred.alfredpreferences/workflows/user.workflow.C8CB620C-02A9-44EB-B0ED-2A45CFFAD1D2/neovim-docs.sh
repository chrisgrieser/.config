#!/bin/zsh
baseHelpURL="https://neovim.io/doc/user/"
baseRawURL="https://raw.githubusercontent.com/neovim/neovim/master/runtime/doc/"

#-------------------------------------------------------------------------------

echo "Downloading doc files..."

mkdir "./neovim-help"
curl -s 'https://api.github.com/repos/neovim/neovim/git/trees/master?recursive=1' \
	| grep -Eo "runtime/doc/.*.txt" \
	| cut -d/ -f3 \
	| while read -r file ; do
		echo -n "#"
		curl -s "$baseRawURL$file" > "./neovim-help/$file"
	done

cd "./neovim-help" || exit 1

echo
echo "Parsing doc files..."

# Example: options.html#'formatoptions'
vimoptions=$(grep -Eo "'[A-Za-z]{2,}'" options.txt | sort -u | xargs -I {} echo "${baseHelpURL}options.html#'{}'")

# Example: map.html#mapleader
anchors=$(grep -REo "\*[:A-Za-z]+\*" | sort -u | tr -d "*" | sed 's/txt:/html#/' | cut -c3- | xargs -I {} echo "${baseHelpURL}{}")

# Example: usr_04.html#04.1
sections=$(grep -Eo "\|[.0-9]*\|.*" usr_toc.txt | tr -d "|" | while read -r line ; do
	file=$(echo "$line" | cut -c-2)
	sec=$(echo "$line" | tr $'\t' " ")
	echo "${baseHelpURL}usr_$file.html#$sec"
done)

echo "Writing Index & cleaning up..."
echo "$vimoptions" > ../url-list.txt
echo "$anchors" >> ../url-list.txt
echo "$sections" >> ../url-list.txt

cd ..
rm -r "./neovim-help"
