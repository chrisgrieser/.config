require("config.utils")
--------------------------------------------------------------------------------

-- make stuff compatible with `black`
bo.expandtab = true
bo.shiftwidth = 4
bo.tabstop = 4
bo.softtabstop = 4

-- fix habits
Iabbrev("<buffer> true True")
Iabbrev("<buffer> false False")
