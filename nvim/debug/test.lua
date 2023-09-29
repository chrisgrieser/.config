local bufnr = vim.api.nvim_create_buf(false, true)

local ui = vim.api.nvim_list_uis()

vim.api.nvim_open_win(bufnr, false, {
	relative = "editor",
	width = 15,
	height = 5,
	anchor = "NE",
	style = "minimal",
})
