vim.opt_local.listchars:remove("multispace")
vim.opt_local.spell = true

-- use Tab to go to EoL
vim.keymap.set("i", "<Tab>", "<End>", { buffer = true })
