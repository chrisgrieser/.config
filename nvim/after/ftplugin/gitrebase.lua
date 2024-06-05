vim.opt_local.listchars:remove("multispace")

--------------------------------------------------------------------------------

vim.keymap.set("n", "<CR>", vim.cmd.wq, { buffer = true, desc = "Confirm" })

-- quting with error code = aborting commit
vim.keymap.set("n", "q", vim.cmd.cquit, { buffer = true, nowait = true })

-- Cycle Rebase Action
vim.keymap.set("n", "<Tab>", "<C-a>", { desc = "Cycle Action", buffer = true, remap = true })
vim.keymap.set("n", "<S-Tab>", "<C-x>", { desc = "Cycle Action", buffer = true, remap = true })
