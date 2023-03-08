require("config.utils")
--------------------------------------------------------------------------------

-- typescript uses same config as javascript ftplugin
local javascriptConfig = fn.stdpath("config") .. "/after/ftplugin/javascript.lua"
cmd.source(javascriptConfig)

-- setup quickfix list for npm, see also: https://vonheikemen.github.io/devlog/tools/vim-and-the-quickfix-list/
bo.makeprg = "npm run build"
bo.errorformat = " > %f:%l:%c: %trror: %m" 
	.. ",%-G%.%#" -- = ignore remaining lines

