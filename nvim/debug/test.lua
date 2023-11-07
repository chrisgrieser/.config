vim.notify("foobar\nbaz", vim.log.levels.INFO, {
	title = "test",
	on_open = function(win)
		local ns = vim.api.nvim_create_namespace("tinygit.commit_notify")
		vim.api.nvim_win_set_hl_ns(win, ns)

		vim.fn.matchadd("foo", [[foo]])
		vim.api.nvim_set_hl(ns, "foo", { link = "Number" })
	end,
})
