local ns = vim.api.nvim_create_namespace("abc")

-- local overlayText = "XXXXXXXXXXXXXXXXXXXXXXXX"
vim.api.nvim_buf_set_extmark(0, ns, 0, 0, {
	conceal = "X",
})

local obj = {
	one = "1",
	two = "2",
	three = "3",
}

