vim.opt_local.listchars:remove("multispace")

-- use Tab to go to EoL
vim.keymap.set("i", "<Tab>", "<End>", { buffer = true })

vim.opt_local.spell = true
vim.keymap.set("n", "ge", "]s", { buffer = true })
vim.keymap.set("n", "gE", "[s", { buffer = true })
