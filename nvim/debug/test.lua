local ns = vim.api.nvim_create_namespace("ysi")
-- vim.highlight.range(0, ns, "IncSearch", { 0, 0 }, { 1, 0 })

-- local overlayText = "XXXXXXXXXXXXXXXXXXXXXXXX"
vim.api.nvim_buf_set_extmark(0, ns, 0, 0, {
	conceal = "X",
})
