local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")
--------------------------------------------------------------------------------

vim.opt_local.conceallevel = 2 -- hides quotes in JSON, making it actually more readable

-- https://mikefarah.gitbook.io/yq/usage/convert
keymap("n", "<localleader>b", ":.!yq -o=json<CR><CR>", { desc = "Prettify Line JSON", buffer = true })
keymap("x", "<localleader>b", ":!yq -o=json<CR><CR>", { desc = "Prettify Selection JSON", buffer = true })
keymap("x", "<localleader>m", ":!yq -I=0<CR><CR>", { desc = "Minify Selection JSON", buffer = true })

-- when opening large files, start with some folds closed
if fn.line("$") > 400 then
	vim.defer_fn(function ()
		require("ufo").closeFoldsWith(1) -- = fold level one
	end, 1)
end

-- escape stuff properly for VS Code Style snippet
keymap("n", "<localleader>q", function ()
	u.normal("'[v']") -- select last paste
	u.leaveVisualMode() -- -> sects '<,'> marks
	cmd[['<,'>s/\\/\\\\/ge]] -- escape the escaping backslashes
	cmd[['<,'>s/"/\\"/ge]] -- escape the double quotes
	-- cmd[['<,'>s/\$/\\\\$/ge]] -- escape the $ signs
	cmd[['<,'>s/^\(\s*\)\(.*\)/\1"\2",/e]] -- surround non-whitespace with quotes and comma
	cmd[['>s/,$//e]] -- remove trailing comma at last line
	u.normal("gv=") -- auto-indent everything
end, { desc = "JSON: Escape for VS Code Snippet", buffer = true })
