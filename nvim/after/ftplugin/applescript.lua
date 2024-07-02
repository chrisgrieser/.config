vim.bo.commentstring = "-- %s"
vim.opt_local.comments = { ":#", ":--" }

vim.opt_local.formatoptions:append("r") -- `<CR>` in insert mode
vim.opt_local.formatoptions:append("o") -- `o` in normal mode

--------------------------------------------------------------------------------
-- ABBREVIATIONS
local abbr = require("config.utils").bufAbbrev

abbr("sleep", "delay")
abbr("//", "--")
