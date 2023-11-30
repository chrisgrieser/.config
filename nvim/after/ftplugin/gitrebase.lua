vim.opt_local.listchars:remove("multispace")

-- reminder about order
vim.defer_fn(
	function()
		vim.notify_once("top: past\nbottom: future", vim.log.levels.INFO, { title = "rebase" })
	end,
	1
)
