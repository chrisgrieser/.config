-- typescript uses same config as javascript ftplugin
local javascriptConfig = vim.fn.stdpath("config").."/after/ftplugin/javascript.lua"
vim.cmd.source(javascriptConfig)
