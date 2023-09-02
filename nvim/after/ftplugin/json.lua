local cmd = vim.cmd
local keymap = vim.keymap.set
local u = require("config.utils")
--------------------------------------------------------------------------------

-- hides quotes, making it more readable
vim.opt_local.conceallevel = 2 

--------------------------------------------------------------------------------

local function leaveVisualMode()
	local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
	vim.api.nvim_feedkeys(escKey, "nx", false)
end

-- escape stuff properly for VS Code Style snippet
keymap("n", "<localleader>e", function()
	u.normal("'[v']") -- select last paste
	leaveVisualMode() -- -> sets '<,'> marks
	cmd([['<,'>s/\\/\\\\/ge]]) -- escape the escaping backslashes
	cmd([['<,'>s/"/\\"/ge]]) -- escape the double quotes
	cmd([['<,'>s/^\(\s*\)\(.*\)/\1"\2",/e]]) -- surround non-whitespace with quotes and comma
	cmd([['>s/,$//e]]) -- remove trailing comma at last line
	u.normal("gv=") -- auto-indent everything
end, { desc = " Escape Code Snippet", buffer = true })


--------------------------------------------------------------------------------

-- convert to yaml
vim.keymap.set("n", "<localleader>y", function()
	vim.cmd("silent update")
	local filename = vim.fn.expand("%")
	local nameAsYaml = vim.fn.expand("%:r") .. ".yaml"
	local yaml = vim.fn.system { "yq", "--output-format=yaml", filename }
	if vim.v.shell_error ~= 0 then
		vim.notify(yaml, vim.log.levels.ERROR)
		return
	end
	local error = u.writeToFile(nameAsYaml, yaml, "w")
	if error then
		vim.notify(error, vim.log.levels.ERROR)
		return
	end
	vim.fn.system { "open", "-R", nameAsYaml }
end, { buffer = true, desc = " Convert to yaml" })

