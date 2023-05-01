-- make jsonc inherit json config
local jsonConfig = vim.fn.stdpath("config") .. "/after/ftplugin/json.lua"
vim.cmd.source(jsonConfig)
