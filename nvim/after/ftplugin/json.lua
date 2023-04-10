require("config.utils")
--------------------------------------------------------------------------------

vim.opt_local.conceallevel = 2 -- hides quotes in JSON, making it actually more readable

-- https://mikefarah.gitbook.io/yq/usage/convert
keymap("n", "<leader>b", ":.!yq -o=json<CR><CR>", { desc = "prettify JSON", buffer = true })
keymap("x", "<leader>b", ":!yq -o=json<CR><CR>", { desc = "prettify JSON", buffer = true })
keymap("x", "<leader>m", ":!yq -I=0<CR><CR>", { desc = "minify JSON", buffer = true })

-- when opening large files, start with some folds closed
if fn.line("$") > 1000 then
	---@diagnostic disable-next-line: param-type-mismatch
	vim.defer_fn(function () vim.opt_local.foldlevel = 1 end, 1)
end

-- escape stuff properly for VS Code Style snippet
keymap("n", "<leader>\\", function ()
	Normal("'[v']") -- select last paste
	LeaveVisualMode() -- -> sects '<,'> marks
	cmd[['<,'>s/\\/\\\\/g]] -- escape the escaping backslashes
	cmd[['<,'>s/"/\\"/g]] -- escape the double quotes
	cmd[['<,'>s/\$/\\\\$/g]] -- escape the $ signs
	cmd[['<,'>s/^\(\s*\)\(.*\)/\1"\2",/]] -- surround non-whitespace with quotes and comma
	cmd[['>s/,$//]] -- remove trailing comma at last line
	Normal("gv=") -- auto-indent everything
end, { desc = "JSON: Escape for VS Code Snippet", buffer = true })
