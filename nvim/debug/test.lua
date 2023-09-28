local text = [[
staging blubb
*refactor*(scope): test message
*Pushing*
]]

vim.notify(text, vim.log.levels.INFO, {
	title = "title",
	on_open = function(win)
		local buf = vim.api.nvim_win_get_buf(win)
		local winNs = 4
		vim.api.nvim_win_set_hl_ns(win, winNs)
		local lastLine = vim.api.nvim_buf_line_count(buf)

		vim.api.nvim_buf_add_highlight(buf, winNs, "ErrorMsg", lastLine - 2, 0, -1)
	end,
})
