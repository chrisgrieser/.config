local spec = {
	{
		"uga-rosa/ccc.nvim",
		opts = {
			highlighter = { auto_enable = true },
		},
	},
}
--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
