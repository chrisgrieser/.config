local spec = {
	{
		"chrisgrieser/nvim-rip-substitute",
		opts = {}, -- insert config here
		keys = {
			{ "gs", function() require("rip-substitute").sub() end, mode = { "n", "x" } },
		},
	},
}

--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-debug"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
--------------------------------------------------------------------------------
