require("config.utils")
local newCommand = vim.api.nvim_create_user_command
--------------------------------------------------------------------------------

-- `:SwapDeleteAll` deletes all swap files
newCommand("SwapDeleteAll", function(_)
	local swapdir = VimDataDir .. "swap/"
	local out = Fn.system([[rm -vf "]] .. swapdir .. [["* ]])
	vim.notify("Deleted:\n" .. out)
end, {})

-- `:ViewDir` opens the nvim view directory
newCommand("ViewDir", function(_)
	local viewdir = Expand(vim.opt.viewdir:get())
	Fn.system('open "' .. viewdir .. '"')
end, {})

-- `:PluginDir` opens the nvim data path, where mason and lazy install their stuff
newCommand("PluginDir", function(_) Fn.system('open "' .. Fn.stdpath("data") .. '"') end, {})

-- quicker evaluation
vim.cmd.cnoreabbrev("ii lua=")
