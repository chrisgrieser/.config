local u = require("config.utils")
--------------------------------------------------------------------------------

-- fix my habits
u.ftAbbr("//", "#")
u.ftAbbr("--", "#")
u.ftAbbr("delay", "sleep")
u.ftAbbr("const", "local")

-- FIX some shell-filetypes override makeprg
vim.opt_local.makeprg = "make --silent --warn-undefined-variables"
