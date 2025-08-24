vim.bo.commentstring = "-- %s"
vim.opt_local.comments = { ":#", ":--" }

--------------------------------------------------------------------------------
-- ABBREVIATIONS
local abbr = require("config.utils").bufAbbrev

abbr("sleep", "delay")
abbr("//", "--")
