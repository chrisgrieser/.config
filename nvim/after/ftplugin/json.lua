require("config.utils")
--------------------------------------------------------------------------------

bo.expandtab = true
wo.listchars = "tab: >"
wo.conceallevel = 2 -- hides quotes in JSON, making it actually more readable

keymap("n", "<D-p>", ":.!yq -o=json<CR>", {desc = "prettify JSON", buffer = true})
keymap("v", "<D-p>", ":'<,'>!yq -o=json<CR>", {desc = "prettify JSON", buffer = true})
keymap("v", "<D-m>", ":'<,'>!yq -I=0<CR>", {desc = "minify JSON", buffer = true})
