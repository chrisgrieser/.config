#!/bin/zsh

# pull dotfiles repo
THIS_LOCATION="$(dirname "$0")"
cd "$THIS_LOCATION" || exit 1
git pull

# pull Alfred repos
echo "---"
cd "Alfred.alfredpreferences/workflows/user.workflow.41B90DCD-A99E-4943-A19A-E91859557FB0/" || exit 1
git pull
echo "---"
cd "../user.workflow.D02FCDA1-EA32-4486-B5A6-09B42C44677C/" || exit 1
git pull
echo "---"
cd "../user.workflow.765354AA-49F0-4CB1-8DB0-EA4BE2DB09F8/" || exit 1
git pull
