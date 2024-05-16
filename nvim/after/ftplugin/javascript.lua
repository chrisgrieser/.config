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
