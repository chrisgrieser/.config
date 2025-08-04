-- CONFIG
-- 1. names need to match files in `lua/plugin-specs/colorschemes/{name}.lua`
-- 2. name of the file is use for the `vim.cmd.colorscheme` command
local lightColorscheme = "dawnfox"
local darkColorscheme = "gruvbox-material"

--------------------------------------------------------------------------------

-- TOGGLE LIGHT/DARK
-- 1. Triggered on startup in `init.lua` (not here, since lazy.nvim didn't load yet)
-- 2. and via Hammerspoon on manual mode change (`OptionSet` autocmd doesn't work reliably)
vim.g.setColorscheme = function(init)
	if init then
		-- needs to be set manually, since `Neovide` does not set correctly
		-- https://github.com/neovide/neovide/issues/3066
		local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
		vim.o.background = (macOSMode.stdout or ""):find("Dark") and "dark" or "light"
	else
		-- reset so next theme isn't affected by previous one
		vim.cmd.highlight("clear")
	end
	local nextTheme = (vim.o.background == "light" and lightColorscheme or darkColorscheme)
	vim.cmd.colorscheme(nextTheme)
end

--------------------------------------------------------------------------------

-- ADD SPECS FOR LAZY.NVIM
-- files in the subfolder of `plugin-specs` are not automatically picked up by
-- `lazy.nvim`, thus need to be returned here
local themeSpecs = {
	require("plugin-specs.colorschemes." .. darkColorscheme),
	require("plugin-specs.colorschemes." .. lightColorscheme),
}

-- see https://lazy.folke.io/spec/lazy_loading#-colorschemes
themeSpecs[1].priority = 1000
themeSpecs[2].priority = 1000

return themeSpecs
