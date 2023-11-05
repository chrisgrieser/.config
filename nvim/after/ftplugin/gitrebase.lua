vim.opt_local.listchars:remove("multispace")

-- quit rebasing
vim.keymap.set("n", "q", vim.cmd.cquit, { buffer = true, desc = "Quit Rebase", nowait = true })

-- reminder about order
vim.defer_fn(
	function() vim.notify("top: past\nbottom: future", vim.log.levels.INFO, { title = "rebase" }) end,
	1
)
