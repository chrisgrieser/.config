local bo = vim.bo
local abbr = vim.cmd.inoreabbrev
--------------------------------------------------------------------------------

-- python standard
bo.expandtab = true
bo.shiftwidth = 4
bo.tabstop = 4
bo.softtabstop = 4

-- fix habits
abbr("<buffer> true True")
abbr("<buffer> false False")
abbr("<buffer> // #")
abbr("<buffer> -- #")

--------------------------------------------------------------------------------

-- auto-convert string to f-string when typing `{..}`
-- TODO better using treesitter: https://www.reddit.com/r/neovim/comments/tge2ty/python_toggle_fstring_using_treesitter/
vim.api.nvim_create_autocmd("InsertLeave", {
	buffer = 0,
	callback = function()
		local curLine = vim.api.nvim_get_current_line()
		local correctedLine = curLine:gsub([[(".*{.-}.*")]], "f%1"):gsub([[('.*{.-}.*')]], "f%1")
		vim.api.nvim_set_current_line(correctedLine)
	end,
})
