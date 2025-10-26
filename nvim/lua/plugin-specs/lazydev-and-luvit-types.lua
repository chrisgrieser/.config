return {
	{
		"folke/lazydev.nvim",
		commit = "e28ce52",
		enabled = false,
		ft = "lua",
		opts = {
			library = {
				-- luvit types when `vim.uv` is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },

				-- global debugging function `Chainsaw`
				{ path = "nvim-chainsaw/lua/chainsaw/nvim-debug.lua", words = { "Chainsaw" } },
			},
		},
	},
	{
		"Bilal2453/luvit-meta",
		lazy = false, -- only needed for emmyrc.json to point to `vim.uv` typing
		enabled = vim.g.useEmmyluaLsp,
	},
}
