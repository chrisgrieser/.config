require("utils")
--------------------------------------------------------------------------------
local opts = {buffer = true, remap = true} -- remap requiered, since netrw uses remaps already

keymap("", "h", "-", opts)
keymap("", "l", "<CR>", opts)


g.netrw_list_hide= '.*\\.DS_Store$,^./$' -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner
g.netrw_liststyle = 3 -- tree style

