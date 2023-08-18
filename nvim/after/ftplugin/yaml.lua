local u = require("config.utils")
--------------------------------------------------------------------------------

vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true

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
end, { buffer = true, desc = " Convert to JSON" })

--------------------------------------------------------------------------------

-- Compile Karabiner Config
vim.keymap.set("n", "<localleader><localleader>", function()
	vim.cmd("silent update")
	local parentFolder = vim.fn.expand("%:p:h")
	if parentFolder:find("/karabiner") then
		local karabinerBuildScp = vim.env.DOTFILE_FOLDER .. "/karabiner/build-karabiner-config.js"
		local result = vim.fn.system { "osascript", "-l", "JavaScript", karabinerBuildScp }
		result = result:gsub("\n$", "")
		vim.notify(result)
	else
		vim.notify("Not in Karabiner Directory.", vim.log.levels.WARN)
	end
end, { buffer = true, desc = " Compile Karabiner Config" })
