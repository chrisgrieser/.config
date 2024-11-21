local M = {}
--------------------------------------------------------------------------------

local lightTheme = require("plugin-configs.themes")[1].colorscheme
local darkTheme = require("plugin-configs.themes")[2].colorscheme
local lightOpacity = require("plugin-configs.themes")[1].opacity
local darkOpacity = require("plugin-configs.themes")[2].opacity

-- Triggered via hammerspoon, as `OptionSet` autocmd does not work reliabely here
function M.set()
	if vim.env.NO_PLUGINS then return end
	-- resets colors, so a theme is not affected by a previous themes colors
	vim.cmd.highlight("clear")

	vim.cmd.colorscheme(vim.o.background == "dark" and darkTheme or lightTheme)
	vim.g.neovide_transparency = vim.o.background == "dark" and darkOpacity or lightOpacity
end

-- initialize
-- (dark mode not detected via `vim.o.background`, as Neovide does not set it in time)
local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
vim.o.background = macOSMode.stdout:find("Dark") and "dark" or "light"
M.set()

--------------------------------------------------------------------------------
return M
