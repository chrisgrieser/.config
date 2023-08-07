local bo = vim.bo
--------------------------------------------------------------------------------

-- make stuff compatible with `black`
bo.expandtab = true
bo.shiftwidth = 4
bo.tabstop = 4
bo.softtabstop = 4

-- fix habits
vim.cmd.inoreabbrev("<buffer> true True")
vim.cmd.inoreabbrev("<buffer> false False")

vim.cmd.inoreabbrev("<buffer> // #")
vim.cmd.inoreabbrev("<buffer> -- #")

