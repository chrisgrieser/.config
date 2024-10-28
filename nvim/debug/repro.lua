-- save as `minimal-config.lua`
-- run via: `nvim -u minimal-config.lua`
--------------------------------------------------------------------------------
local spec = {
	{
		"NeogitOrg/neogit",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = "Neogit",
		opts = {},
	},
	{
		"chrisgrieser/nvim-origami",
		event = "VeryLazy",
		opts = true,
	},
}


--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
