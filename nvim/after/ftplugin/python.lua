local bo = vim.bo
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

-- python standard
bo.expandtab = true
bo.shiftwidth = 4
bo.tabstop = 4
bo.softtabstop = 4

vim.opt_local.listchars:append { tab = "󰌒 " } 
vim.opt_local.listchars:append { lead = " " } 
-- python inline comments are separated by two spaces via `black`, so multispace
-- only adds noise when displaying the dots for them
vim.opt_local.listchars:append { multispace = " " } 

-- extra trailing char
vim.keymap.set("n", "<leader>:", "mzA :<Esc>`z", { desc = " : to EoL", buffer = true })

-- fix habits
abbr("<buffer> true True")
abbr("<buffer> false False")
abbr("<buffer> // #")
abbr("<buffer> -- #")
abbr("<buffer> else else:")

--------------------------------------------------------------------------------
