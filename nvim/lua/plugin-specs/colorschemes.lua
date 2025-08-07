-- for separation placed in a different folder
local darkScheme = require("colorschemes." .. vim.g.darkColor)
local lightScheme = require("colorschemes." .. vim.g.lightColor)

-- disable the auto-activation of the colorscheme that is not needed on startup
local macOSMode = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait()
local bg = (macOSMode.stdout or ""):find("Dark") and "dark" or "light"
if bg == "dark" then
	lightScheme.config = nil
	lightScheme.priority = nil
else
	darkScheme.init = nil
	darkScheme.priority = nil
end

--------------------------------------------------------------------------------

return { darkScheme, lightScheme }
