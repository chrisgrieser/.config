local bo = vim.bo
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

-- python standard
bo.expandtab = true
bo.shiftwidth = 4
bo.tabstop = 4
bo.softtabstop = 4

-- fix habits
abbr("<buffer> true True")
abbr("<buffer> false False")
abbr("<buffer> // #")
abbr("<buffer> -- #")

--------------------------------------------------------------------------------
