local text = [[
staging blubb
*refactor*(scope): test message
*Pushing*
]]


vim.notify(text, vim.log.levels.INFO, {
	title = "title",
	on_open = function(win)
		local buf = vim.api.nvim_win_get_buf(win)
		vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
		vim.api.nvim_win_set_option(win, "conceallevel", 2)
	end
})
