local darkScheme = require("colorschemes." .. vim.g.darkColor)
local lightScheme = require("colorschemes." .. vim.g.lightColor)
--------------------------------------------------------------------------------

-- don't auto-activate the unneeded colorscheme on startup
local bg
if vim.g.neovide and jit.os == "OSX" then -- neovide too slow in setting `background`
	local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
	bg = (macOSMode.stdout or ""):find("Dark") and "dark" or "light"
else
	bg = vim.o.background
end

if vim.g.darkColor ~= vim.g.lightColor then
	if bg == "dark" then
		lightScheme.config = nil
		lightScheme.priority = nil
		lightScheme.lazy = true
	else
		darkScheme.init = nil
		darkScheme.priority = nil
		darkScheme.lazy = true
	end
end

--------------------------------------------------------------------------------

return { darkScheme, lightScheme }
