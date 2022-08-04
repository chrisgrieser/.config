#!/usr/bin/env zsh

OBSI_CONFIG_PATH=~"/Library/Application Support/obsidian/"
VIM_UPDATE_LOCATION="https://gist.githubusercontent.com/kometenstaub/11d815a6cfc96100cbcb170ddba8c807/raw/"

killall Obsidian

cd "$OBSI_CONFIG_PATH" || return 1
ASAR=$(ls obsidian-*.asar)

npx asar extract "$ASAR" obsiasar
rm -f "$ASAR"
curl "$VIM_UPDATE_LOCATION" -o obsiasar/lib/codemirror/vim.js || return 1

npx asar pack obsiasar "$ASAR"
rm -rf obsiasar

open -a "Obsidian"
