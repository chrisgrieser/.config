vim.opt_local.listchars:remove("multispace")

vim.keymap.set("n", "q", vim.cmd.cquit, { buffer = true, desc = "Quit Commit", nowait = true })

