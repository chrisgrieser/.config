require("config.utils")
--------------------------------------------------------------------------------

-- wo.conceallevel = 2 -- hides quotes in JSON, making it actually more readable

-- https://mikefarah.gitbook.io/yq/usage/convert
keymap("n", "<D-p>", ":.!yq -o=json<CR><CR>", {desc = "prettify JSON", buffer = true})
keymap("x", "<D-p>", ":!yq -o=json<CR><CR>", {desc = "prettify JSON", buffer = true})
keymap("x", "<D-m>", ":!yq -I=0<CR><CR>", {desc = "minify JSON", buffer = true})

