require("config.utils")
--------------------------------------------------------------------------------

vim.opt_local.conceallevel = 2 -- hides quotes in JSON, making it actually more readable

-- https://mikefarah.gitbook.io/yq/usage/convert
Keymap("n", "<leader>b", ":.!yq -o=json<CR><CR>", { desc = "prettify JSON", buffer = true })
Keymap("x", "<leader>b", ":!yq -o=json<CR><CR>", { desc = "prettify JSON", buffer = true })
Keymap("x", "<leader>m", ":!yq -I=0<CR><CR>", { desc = "minify JSON", buffer = true })

-- when opening large files, start with some folds closed
if Fn.line("$") > 1000 then
	---@diagnostic disable-next-line: param-type-mismatch
	vim.defer_fn(function () require("ufo").closeFoldsWith(2) end, 1)
end

-- escape stuff properly for VS Code Style snippet
Keymap("n", "<leader>\\", function ()
	Normal("'[v']") -- select last paste
	LeaveVisualMode() -- -> sects '<,'> marks
	Cmd[['<,'>s/\\/\\\\/g]] -- escape the escaping backslashes
	Cmd[['<,'>s/"/\\"/g]] -- escape the double quotes
	Cmd[['<,'>s/\$/\\\\$/g]] -- escape the $ signs
	Cmd[['<,'>s/^\(\s*\)\(.*\)/\1"\2",/]] -- surround non-whitespace with quotes and comma
	Cmd[['>s/,$//]] -- remove trailing comma at last line
	Normal("gv=") -- auto-indent everything
end, { desc = "JSON: Escape for VS Code Snippet", buffer = true })
