#!/bin/zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

cd ../../..

subl "obsidian.vimrc"
subl "Sublime User Folder/.neovintageousrc"

sleep 2.0
subl --command "set_layout {\"cols\": [0.0, 0.5, 1.0], \"rows\": [0.0, 1.0], \"cells\": [[0, 0, 1, 1], [1, 0, 2, 1]]  }"
sleep 0.1
subl --command "focus_neighboring_group"
sleep 0.1
subl --command "move_to_neighboring_group"
