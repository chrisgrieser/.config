return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- luvit types when `vim.uv` is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"Bilal2453/luvit-meta",
		lazy = false, -- only needed for emmyrc.json to point to `vim.uv` typing
		enabled = vim.g.useEmmyluaLsp,
	},
}
