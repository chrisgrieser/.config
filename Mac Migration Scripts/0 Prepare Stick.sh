#!/bin/zsh

# change to target
STICK="/Volumes/CG_Stick"

# ----------------------------

cd "$STICK" || exit 1
dump
DOTFILE_FOLDER="$(dirname "$0")"

cp -R "$DOTFILE_FOLDER/Mac Installation Scripts" .

cp ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Authentification/log11.kdbx" .
cp ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Authentification/log11.key" .
cp -R '/Applications/MacPass.app' .

open .
