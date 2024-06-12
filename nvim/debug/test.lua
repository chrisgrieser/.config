vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("DressingInput", { clear = true }),
	pattern = "DressingInput",
	callback = function(ctx)
		local win = vim.api.nvim_get_current_win()
		local startWidth = vim.api.nvim_win_get_width(win)
		local pad = 3
		vim.api.nvim_create_autocmd("TextChangedI", {
			buffer = ctx.buf,
			callback = function()
				local lineLength = #vim.api.nvim_get_current_line() + pad
				local width = vim.api.nvim_win_get_width(win)
				if lineLength > width then vim.api.nvim_win_set_width(win, lineLength + pad) end
			end,
		})
	end,
})
