local ns = vim.api.nvim_create_namespace("test")
vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
local lnum = 2

vim.api.nvim_buf_set_extmark(0, ns, lnum, 0, {
	line_hl_group = "DiffAdd",
})

