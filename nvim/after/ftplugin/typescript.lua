-- typescript uses same config as javascript ftplugin
local thisDir = vim.fn.expand("%:p:h")
cmd.source(thisDir.."/javascript.lua")
