vim.opt_local.list = false

vim.defer_fn(
	function() vim.notify("top: past\nbottom: future", vim.log.levels.INFO, { title = "rebase" }) end,
	1
)
