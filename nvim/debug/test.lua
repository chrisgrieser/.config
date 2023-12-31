
-- NVIM-SCISSORS DEMO

vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		print("foobar")
	end,
})
