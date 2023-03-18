require("config.utils")
--------------------------------------------------------------------------------

-- make stuff compatible with `black`
bo.expandtab = true
bo.shiftwidth = 4
bo.tabstop = 4
bo.softtabstop = 4

-- fix habits
iabbrev("<buffer> true True")
iabbrev("<buffer> false False")
