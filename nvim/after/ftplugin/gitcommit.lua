vim.opt_local.listchars:remove("multispace")
vim.opt_local.spell = true
vim.opt_local.spelloptions = "camel"

--------------------------------------------------------------------------------

vim.keymap.set("i", "<Tab>", "<End>", { buffer = true })
vim.keymap.set("n", "<Tab>", "A", { buffer = true })

vim.keymap.set("n", "ge", "]s", { buffer = true })
vim.keymap.set("n", "gE", "[s", { buffer = true })

-- condition ensures this isn't a DressingInput buffer, which already has
-- mappings of its own
if vim.bo.buftype ~= "nofile" then
	vim.keymap.set("n", "<CR>", "ZZ", { buffer = true, desc = "Confirm" })
	-- quting with error code = aborting commit
	vim.keymap.set("n", "q", vim.cmd.cquit, { buffer = true, nowait = true, desc = "Abort" })
end

