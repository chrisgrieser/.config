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
		"chrisgrieser/replacer.nvim",
		lazy = true,
		dev = true,
		init = function()
			-- save & quit via "q"
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "replacer",
				callback = function()
					-- stylua: ignore
					vim.keymap.set( "n", "q", vim.cmd.write, { desc = " Finish replacing", buffer = true, nowait = true })
				end,
			})
		end,
	},
	{
		"ThePrimeagen/refactoring.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		config = function() require("refactoring").setup() end,
	},
}
