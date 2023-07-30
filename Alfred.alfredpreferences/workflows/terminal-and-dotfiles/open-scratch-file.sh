#!/usr/bin/env zsh

touch "$WD/scratch.txt" # WD defined in .zshenv
open "$WD/scratch.txt"

sleep 0.2 # wait till file open

# paste from system clipboard
nvim --server "/tmp/nvim_server.pipe" --remote-send '"+p'
