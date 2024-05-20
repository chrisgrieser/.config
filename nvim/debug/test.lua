-- BOB

vim.notify("test", vim.log.levels.INFO, {
	title = "test",
	animate = false,
	on_open = function(winnr) vim.api.nvim_win_set_width(winnr, 80) end,
})
