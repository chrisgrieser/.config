-- toggle !important (useful for debugging selectors)
vim.keymap.set("n", "<leader>i", function()
	local line = vim.api.nvim_get_current_line()
	if line:find("!important") then
		line = line:gsub(" !important", "")
	else
		line = line:gsub(";?$", " !important;", 1)
	end
	vim.api.nvim_set_current_line(line)
end, { buffer = true, desc = " Toggle !important", nowait = true })

-- HACK workaround for `opt.exrc` not working
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.css",
	callback = function() vim.opt_local.exrc = true end,
})
