return {
	{
		"folke/lazydev.nvim",
		cond = not vim.g.use_emmylua,
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the "word" `vim.uv` is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },

				-- global debugging function `Chainsaw`
				{ path = "nvim-chainsaw/lua/chainsaw/nvim-debug.lua", words = { "Chainsaw" } },
			},
		},
	},
	{
		"Bilal2453/luvit-meta",
		lazy = false, -- only need it locally for emmylua to have vim.uv typing
		cond = vim.g.use_emmylua,
	},
}
