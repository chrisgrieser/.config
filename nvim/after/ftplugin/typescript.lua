-- inherit all javascript settings
vim.cmd.source(vim.fn.stdpath("config") .. "/after/ftplugin/javascript.lua")

-- sets correct `errorformat` quickfix-list
vim.cmd.compiler("tsc") 

--------------------------------------------------------------------------------
