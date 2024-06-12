-- inherit all javascript settings
vim.cmd.source(vim.fn.stdpath("config") .. "/after/ftplugin/javascript.lua")

-- sets `errorformat` for quickfix lists
vim.cmd.compiler("tsc") 

--------------------------------------------------------------------------------
