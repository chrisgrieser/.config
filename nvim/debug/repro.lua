-- INFO run via: `nvim -u minimal-config.lua -- foobar.js`
--------------------------------------------------------------------------------
local spec = {
	{
		"uga-rosa/ccc.nvim",
		opts = {
			highlighter = {
				auto_enable = true,
				lsp = false,
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function() require("lspconfig").cssls.setup {} end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim", opts = true },
		opts = {
			ensure_installed = { "css-lsp" },
			run_on_start = true,
		},
	},
}
--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }

