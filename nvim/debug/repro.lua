local spec = {
	{
		"chrisgrieser/nvim-rip-substitute",
		opts = {},
		keys = {
			{
				"gs",
				function() require("rip-substitute").sub() end,
				mode = { "n", "x" },
				desc = " rip substitute",
			},
		},
	},
}

--------------------------------------------------------------------------------
-- https://lazy.folke.io/developers#reprolua
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
