require("config.utils")
--------------------------------------------------------------------------------

bo.shiftwidth = 2
bo.tabstop = 2
bo.softtabstop = 2
bo.expandtab = true

--------------------------------------------------------------------------------

-- Compile Karabiner Config
Keymap("n", "<leader>r", function()
	Cmd.update()
	local parentFolder = Expand("%:p:h")
	if parentFolder:find("/karabiner") then
		local karabinerBuildScp = vim.env.DOTFILE_FOLDER .. "/karabiner/build-karabiner-config.js"
		local result = Fn.system('osascript -l JavaScript "' .. karabinerBuildScp .. '"')
		result = result:gsub("\n$", "")
		vim.notify(result)
	else
		vim.notify("Not in Karabiner Directory.", LogWarn)
	end
end, { buffer = true, desc = " Compile Karabiner Config" })
