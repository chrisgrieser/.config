require("config.utils")
local newCommand = vim.api.nvim_create_user_command
--------------------------------------------------------------------------------

-- `:SwapDeleteAll` deletes all swap files
newCommand("SwapDeleteAll", function(_)
	local swapdir = VimDataDir .. "swap/"
	local out = fn.system([[rm -vf "]] .. swapdir .. [["* ]])
	vim.notify("Deleted:\n" .. out)
end, {})

-- `:ViewDir` opens the nvim view directory
newCommand("ViewDir", function(_)
	local viewdir = expand(vim.opt.viewdir:get())
	fn.system('open "' .. viewdir .. '"')
end, {})

-- `:PluginDir` opens the nvim data path, where mason and lazy install their stuff
newCommand("PluginDir", function(_) fn.system('open "' .. fn.stdpath("data") .. '"') end, {})

--------------------------------------------------------------------------------

