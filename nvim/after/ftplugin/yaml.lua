
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true


--------------------------------------------------------------------------------

-- convert to json
vim.keymap.set("n", "<leader>j", function()
	vim.fn.system({"yq", vim.fn.expand("%")})
	vim.cmd("silent update")
	local parentFolder = vim.fn.expand("%:p:h")
	if parentFolder:find("/karabiner") then
		local karabinerBuildScp = vim.env.DOTFILE_FOLDER .. "/karabiner/build-karabiner-config.js"
		local result = vim.fn.system('osascript -l JavaScript "' .. karabinerBuildScp .. '"')
		result = result:gsub("\n$", "")
		vim.notify(result)
	else
		vim.notify("Not in Karabiner Directory.", vim.log.levels.WARN)
	end
end, { buffer = true, desc = " Compile Karabiner Config" })

--------------------------------------------------------------------------------

-- Compile Karabiner Config
vim.keymap.set("n", "<leader>r", function()
	vim.cmd("silent update")
	local parentFolder = vim.fn.expand("%:p:h")
	if parentFolder:find("/karabiner") then
		local karabinerBuildScp = vim.env.DOTFILE_FOLDER .. "/karabiner/build-karabiner-config.js"
		local result = vim.fn.system('osascript -l JavaScript "' .. karabinerBuildScp .. '"')
		result = result:gsub("\n$", "")
		vim.notify(result)
	else
		vim.notify("Not in Karabiner Directory.", vim.log.levels.WARN)
	end
end, { buffer = true, desc = " Compile Karabiner Config" })
