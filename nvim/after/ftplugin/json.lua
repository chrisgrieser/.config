require("config.utils")
--------------------------------------------------------------------------------

opt_local.conceallevel = 2 -- hides quotes in JSON, making it actually more readable

-- https://mikefarah.gitbook.io/yq/usage/convert
keymap("n", "<D-p>", ":.!yq -o=json<CR><CR>", { desc = "prettify JSON", buffer = true })
keymap("x", "<D-p>", ":!yq -o=json<CR><CR>", { desc = "prettify JSON", buffer = true })
keymap("x", "<D-m>", ":!yq -I=0<CR><CR>", { desc = "minify JSON", buffer = true })

-- in large files, start with some folds closed
if fn.line("$") > 1000 then
	---@diagnostic disable-next-line: param-type-mismatch
	vim.defer_fn(function () require("ufo").closeFoldsWith(2) end, 1)
end

