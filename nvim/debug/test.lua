--------------------------------------------------------
-- nvim-scissors demo
--------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		print("hello world")
	end,
})
