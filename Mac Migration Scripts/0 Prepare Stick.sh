#!/bin/zsh

# change to target
STICK="/Volumes/CG_Stick"


# ----------------------------

# TODO Script to create 'pw.md'

cd "$STICK" || exit
dump

DOTFOLDER=~'/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/'

# Installation Scripts
cp -R "$DOTFOLDER/Mac Installation Scripts" .

# Keeweb
cp "$DOTFOLDER/log11.kdbx" .
cp "$DOTFOLDER/log11.key" .
cp -R '/Applications/MacPass.app' .
cp -R ~'/Library/Application Support/MacPass' .

# open folder afterwards
open .
