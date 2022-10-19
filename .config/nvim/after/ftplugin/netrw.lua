require("utils")
-- https://vonheikemen.github.io/devlog/tools/using-netrw-vim-builtin-file-explorer/
--------------------------------------------------------------------------------
local opts = {buffer = true, remap = true} -- remap requiered, since netrw uses remaps already

keymap("", "h", "-", opts) -- up
keymap("", "l", "<CR>", opts) -- open
keymap("", ".", "gh", opts) -- hidden files
keymap("", "?", "<F1>", opts) -- help
keymap("", "<BS>", "<del>", opts) -- delete file
keymap("", "n", "%", opts) -- new file
keymap("", "N", "d", opts) -- new directory
keymap("", "<Esc>", ":q<CR>", opts) 
keymap("", "r", "R", opts) 
keymap("", "P", "<C-w>z", opts) -- close preview window

-- INFO there are also netrw options which need in remaining plugins

