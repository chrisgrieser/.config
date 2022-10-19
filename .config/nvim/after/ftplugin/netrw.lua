require("utils")
--------------------------------------------------------------------------------
local opts = {buffer = true, remap = true} -- remap requiered, since netrw uses remaps already

keymap("", "h", "-", opts) -- up
keymap("", "l", "<CR>", opts) -- open
keymap("", ".", "gh", opts) -- hidden files
keymap("", "?", "<F1>", opts) -- help
keymap("", "<BS>", "<del>", opts) -- delete file
keymap("", "n", "%", opts) -- new file
keymap("", "<Esc>", ":q<CR>", opts) 
keymap("", "r", "R", opts) 

-- INFO there are also netrw options which need in remaining plugins

