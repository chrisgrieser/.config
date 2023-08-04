local cmd = vim.cmd
local keymap = vim.keymap.set
local u = require("config.utils")
--------------------------------------------------------------------------------

-- hides quotes, making it more readable
vim.opt_local.conceallevel = 2 

-- escape stuff properly for VS Code Style snippet
keymap("n", "<leader>q", function()
	u.normal("'[v']") -- select last paste
	u.leaveVisualMode() -- -> sets '<,'> marks
	cmd([['<,'>s/\\/\\\\/ge]]) -- escape the escaping backslashes
	cmd([['<,'>s/"/\\"/ge]]) -- escape the double quotes
	cmd([['<,'>s/^\(\s*\)\(.*\)/\1"\2",/e]]) -- surround non-whitespace with quotes and comma
	cmd([['>s/,$//e]]) -- remove trailing comma at last line
	u.normal("gv=") -- auto-indent everything
end, { desc = " JSON: Escape Code Snippet", buffer = true })
