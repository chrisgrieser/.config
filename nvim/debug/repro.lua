local spec = {
	{
		"chrisgrieser/nvim-rip-substitute",
		opts = {},
		keys = {
			{ "gs", ":lua require('rip-substitute').sub()<CR>", mode = { "n", "x" } },
		},
	},
}

--------------------------------------------------------------------------------
-- https://lazy.folke.io/developers#reprolua
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
