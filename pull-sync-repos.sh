#!/bin/zsh

set -e  # exit with 1 if any command fails

# pull dotfiles repo
THIS_LOCATION="$(dirname "$0")"
cd "$THIS_LOCATION"
git add -A
git pull

# pull Alfred repos
cd "Alfred.alfredpreferences/workflows"
cd "./shimmering-obsidian"
git pull
cd "../alfred-bibtex-citation-picker"
git pull
cd "../pdf-annotation-extractor-alfred"
git pull

