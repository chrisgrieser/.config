require("utils")
--------------------------------------------------------------------------------

-- use 2 spaces instead of tabs
bo.shiftwidth = 2
bo.tabstop = 2
bo.softtabstop = 2
bo.expandtab = true

localOpt("listchars", "tab: >")

-- hides quotes in JSON, making it actually more readable
wo.conceallevel = 2

-- JSON-[b]eautify line/selection, requires `yq`
keymap("n", "<D-b>", ":.!yq -o=json<CR>", {buffer = true})
keymap("v", "<D-b>", ":'<,'>!yq -o=json<CR>", {buffer = true})

-- JSON-[m]inify selection, requires `yq`
keymap("v", "<D-m>", ":'<,'>!yq -I=0<CR>", {buffer = true})

