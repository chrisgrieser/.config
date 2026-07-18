vim.pack.add { "https://github.com/jinh0/eyeliner.nvim" }
--------------------------------------------------------------------------------

require("eyeliner").setup {
	highlight_on_key = true,
	dim = true,
	max_length = 500,
	disabled_buftypes = {},
}

--------------------------------------------------------------------------------
