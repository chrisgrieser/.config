local u = require("config.utils")
local bo = vim.bo
--------------------------------------------------------------------------------

bo.tabstop = 2
bo.shiftwidth = 2
bo.expandtab = true
vim.opt_local.listchars:append {
}

--------------------------------------------------------------------------------

-- convert to json
vim.keymap.set("n", "<localleader>j", function()
	vim.cmd("silent update")
	local filename = vim.fn.expand("%")
	local nameAsJson = vim.fn.expand("%:r") .. ".json"
	local json = vim.fn.system { "yq", "--output-format=json", "explode(.)", filename }
	if vim.v.shell_error ~= 0 then
		u.notify("Error", json)
		return
	end
	local error = u.writeToFile(nameAsJson, json, "w")
	if error then
		u.notify("Error", error)
		return
	end
	vim.fn.system { "open", "-R", nameAsJson }
end, { buffer = true, desc = " Convert to JSON" })

--------------------------------------------------------------------------------
