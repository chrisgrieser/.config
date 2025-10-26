local darkScheme = require("colorschemes." .. vim.g.darkColor)
local lightScheme = require("colorschemes." .. vim.g.lightColor)
--------------------------------------------------------------------------------

-- disable the auto-activation of the colorscheme that is not needed on startup
local bg
if vim.g.neovide and jit.os == "OSX" then -- neovide too slow in setting `background`
	local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
	bg = (macOSMode.stdout or ""):find("Dark") and "dark" or "light"
else
	bg = vim.o.background
end

if bg == "dark" then
	lightScheme.config = nil
	lightScheme.priority = nil
	lightScheme.lazy = true
else
	darkScheme.init = nil
	darkScheme.priority = nil
	darkScheme.lazy = true
end

--------------------------------------------------------------------------------

return { darkScheme, lightScheme }
