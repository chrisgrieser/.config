require("config.utils")
--------------------------------------------------------------------------------

bo.expandtab = true
wo.listchars = "tab: >"

-- hides quotes in JSON, making it actually more readable
wo.conceallevel = 2

-- JSON-[b]eautify line/selection, requires `yq`
keymap("n", "<D-b>", ":.!yq -o=json<CR>", {desc = "prettify JSON", buffer = true})
keymap("v", "<D-b>", ":'<,'>!yq -o=json<CR>", {buffer = true})

-- JSON-[m]inify selection, requires `yq`
keymap("v", "<D-m>", ":'<,'>!yq -I=0<CR>", {buffer = true})
