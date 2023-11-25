local u = require("config.utils")
--------------------------------------------------------------------------------

-- fix my habits
u.ftAbbr("//", "#")
u.ftAbbr("--", "#")

-- shome shell-filetypes override he makeprg
vim.opt_local.makeprg = "make --silent --warn-undefined-variables"
