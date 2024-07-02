vim.bo.commentstring = "// %s" -- add space

--------------------------------------------------------------------------------

-- ABBREVIATIONS
local abbr = require("config.utils").bufAbbrev

abbr("cosnt", "const")
abbr("local", "const")
abbr("--", "//")
abbr("~=", "!==")
abbr("elseif", "else if")
abbr("()", "() =>") -- quicker arrow function

--------------------------------------------------------------------------------
