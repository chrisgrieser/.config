require("config.utils")
--------------------------------------------------------------------------------

vim.opt_local.conceallevel = 2 -- hides quotes in JSON, making it actually more readable

-- https://mikefarah.gitbook.io/yq/usage/convert
Keymap("n", "<D-p>", ":.!yq -o=json<CR><CR>", { desc = "prettify JSON", buffer = true })
Keymap("x", "<D-p>", ":!yq -o=json<CR><CR>", { desc = "prettify JSON", buffer = true })
Keymap("x", "<D-m>", ":!yq -I=0<CR><CR>", { desc = "minify JSON", buffer = true })

-- in large files, start with some folds closed
if Fn.line("$") > 1000 then
	---@diagnostic disable-next-line: param-type-mismatch
	vim.defer_fn(function () require("ufo").closeFoldsWith(2) end, 1)
end

-- escape stuff properly
Keymap("x", "<leader>\\", function ()
	LeaveVisualMode()
	Cmd[['<,'>s/\\/\\\\/g]] -- escape the escaping backslashes
	Cmd[['<,'>s/"/\\"/g]] -- escape the double quotes
	Cmd[['<,'>s/$/\\$/g]] -- escape the $ signs
	Cmd[['<,'>s/^\(\s*\)\(.*\)/\1"\2",/]] -- surround non-whitespace with quotes and comma
	Cmd[['>s/,$//]] -- remove trailing comma at last line
end, { desc = "JSON: for VS Code Snippet", buffer = true })
