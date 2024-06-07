local win = vim.api.nvim_open_win(0, true, {
	relative = "editor",
	row = 0,
	col = 80,
	width = 20,
	height = 10,
	title = "test",
	border = "single",
})

vim.api.nvim_win_set_config(win, { title = "foobar" })
