local u = require("config.utils")
local bo = vim.bo
--------------------------------------------------------------------------------

bo.shiftwidth = 2
bo.tabstop = 2
bo.softtabstop = 2
bo.expandtab = true

vim.opt_local.listchars:append { tab = "󰌒 " } 
vim.opt_local.listchars:append { lead = " " } 

--------------------------------------------------------------------------------

-- convert to json
vim.keymap.set("n", "<localleader>j", function()
	vim.cmd("silent update")
	local filename = vim.fn.expand("%")
	local nameAsJson = vim.fn.expand("%:r") .. ".json"
	local json = vim.fn.system { "yq", "--output-format=json", "explode(.)", filename }
	if vim.v.shell_error ~= 0 then
		vim.notify(json, vim.log.levels.ERROR)
		return
	end
	local error = u.writeToFile(nameAsJson, json, "w")
	if error then
		vim.notify(error, vim.log.levels.ERROR)
		return
	end
	vim.fn.system { "open", "-R", nameAsJson }
end, { buffer = true, desc = " Convert to JSON" })

--------------------------------------------------------------------------------
