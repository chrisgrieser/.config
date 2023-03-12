require("config.utils")
--------------------------------------------------------------------------------

bo.shiftwidth = 2
bo.tabstop = 2
bo.softtabstop = 2
bo.expandtab = true
opt_local.listchars = "tab: >,multispace:·,leadmultispace: "

--------------------------------------------------------------------------------

-- Compile Karabiner Config
keymap("n", "<leader>r", function()
	cmd.update()
	local parentFolder = expand("%:p:h")
	if parentFolder:find("/karabiner") then
		local karabinerBuildScp = vim.env.DOTFILE_FOLDER .. "/karabiner/build-karabiner-config.js"
		local result = fn.system('osascript -l JavaScript "' .. karabinerBuildScp .. '"')
		result = result:gsub("\n$", "")
		vim.notify(result)
	end
end, { buffer = true, desc = " Compile Karabiner Config" })
