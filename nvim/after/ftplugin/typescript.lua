local u = require("config.utils")
--------------------------------------------------------------------------------

-- add space
vim.bo.commentstring = "// %s" 

-- fix my habits
u.ftAbbr("cosnt", "const")
u.ftAbbr("local", "const")
u.ftAbbr("--", "//")
u.ftAbbr("~=", "!==")
u.ftAbbr("elseif", "else if")

--------------------------------------------------------------------------------

-- set errorformat to tsc, but keep `make` as makeprg
local maker = vim.o.makeprg
vim.cmd.compiler("tsc")
vim.o.makeprg = maker
