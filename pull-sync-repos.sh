#!/bin/zsh

# pull dotfiles repo
THIS_LOCATION="$(dirname "$0")"
cd "$THIS_LOCATION" || exit 1
git pull || exit 1

# pull Alfred repos
cd "Alfred.alfredpreferences/workflows" || exit 1
cd "./shimmering-obsidian" || exit 1
git pull || exit 1
cd "../alfred-bibtex-citation-picker" || exit 1
git pull || exit 1
cd "../pdf-annotation-extractor-alfred" || exit 1
git pull || exit 1

# INFO: not using 'set -e' so that more meaningful output msgs are created
