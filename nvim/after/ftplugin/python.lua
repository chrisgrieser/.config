local bo = vim.bo
--------------------------------------------------------------------------------

-- make stuff compatible with `black`
bo.expandtab = true
bo.shiftwidth = 4
bo.tabstop = 4
bo.softtabstop = 4

-- fix habits
vim.cmd.inoreabbrev("<buffer> true True")
vim.cmd.inoreabbrev("<buffer> false False")

vim.cmd.inoreabbrev("<buffer> // #")
vim.cmd.inoreabbrev("<buffer> -- #")

--------------------------------------------------------------------------------

-- auto-convert string to f-string when typing `{..}`
vim.api.nvim_create_autocmd("InsertLeave", {
	buffer = 0,
	callback = function()
		local curLine = vim.api.nvim_get_current_line()
		local correctedLine = curLine:gsub([[(".*{.-}.*")]], "f%1"):gsub([[('.*{.-}.*')]], "f%1")
		vim.api.nvim_set_current_line(correctedLine)
	end,
})
