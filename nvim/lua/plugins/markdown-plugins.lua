return {
	{ -- emphasized headers & code blocks
		"lukas-reineke/headlines.nvim",
		ft = "markdown", -- can work in other fts, but I only use it in markdown
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			markdown = {
				fat_headlines = false,
				dash_string = "─",
			},
		},
	},
	{ -- auto-bullets for markdown-like filetypes
		"dkarter/bullets.vim",
		ft = "markdown",
		keys = {
			{ "o", "<Plug>(bullets-newline)", ft = "markdown" },
			{ "<CR>", "<Plug>(bullets-newline)", mode = "i", ft = "markdown" },
			{ "<Tab>", "<Plug>(bullets-demote)", mode = { "i", "n", "x" }, ft = "markdown" },
			{ "<S-Tab>", "<Plug>(bullets-promote)", mode = { "i", "n", "x" }, ft = "markdown" },
		},
		init = function()
			vim.g.bullets_set_mappings = 0 -- using my own
			vim.g.bullets_delete_last_bullet_if_empty = 1
			vim.g.bullets_enable_in_empty_buffers = 0
		end,
	},
	{ -- preview markdown
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		keys = {
			{ "<D-r>", "<Plug>MarkdownPreview", ft = "markdown", desc = " Preview" },
		},
		init = function() vim.g.mkdp_filetypes = { "markdown" } end,
	},
}
