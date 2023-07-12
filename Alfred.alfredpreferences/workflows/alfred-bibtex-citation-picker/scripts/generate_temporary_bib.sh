#!/bin/zsh
# shellcheck disable=SC2154
export PATH=/usr/local/bin:/opt/homebrew/bin/:$PATH

CSL=apa-6th-edition.csl
CITEKEY="$*"
LIBRARY="${bibtex_library_path/#\~/$HOME}"
DUMMYDOC="---
nocite: |
  @$CITEKEY
---"

if ! command -v pandoc &>/dev/null; then
	echo -n "You need to install pandoc for this feature."
else
	echo "$DUMMYDOC" |
		pandoc --citeproc --read=markdown --write=plain --csl="$CSL" --bibliography="$LIBRARY" |
		tr "\n" " " |
		sed "s/ $//"
fi
