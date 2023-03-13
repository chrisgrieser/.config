return {
	{
		"mg979/vim-visual-multi",
		keys = { { "<D-j>", mode = { "n", "x" }, desc = "Multi-Cursor" } },
	},
	{
		"cshuaimin/ssr.nvim", -- structural search & replace
		lazy = true,
		config = function()
			require("ssr").setup {
				keymaps = { close = "Q" },
			}
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "ssr",
				callback = function() vim.wo.sidescrolloff = 0 end,
			})
		end,
	},
	{
		"gabrielpoca/replacer.nvim",
		lazy = true,
	},
	{
		"ThePrimeagen/refactoring.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		config = function() require("refactoring").setup() end,
	},
}
