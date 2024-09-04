-- INFO run via: `nvim -u minimal-config.lua -- foobar.js`
--------------------------------------------------------------------------------
local spec = {
	{
		"williamboman/mason.nvim",
		opts = {},
		dependencies = {
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					ensure_installed = { "lua_ls" },
					run_on_start = true,
				},
			},
			"williamboman/mason-lspconfig.nvim",
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function() require("lspconfig").lua_ls.setup {} end,
	},
}
--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
