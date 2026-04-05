#!/usr/bin/env zsh

# open "$1"
# PENDING https://github.com/neovide/neovide/issues/3444#issuecomment-4188793273
open -a "Neovide"
while ! pgrep -xq "neovide"; do sleep 0.1; done
sleep 0.5
nvim --server '/tmp/nvim_server.pipe' --remote-send "<cmd>edit $1<CR>"
