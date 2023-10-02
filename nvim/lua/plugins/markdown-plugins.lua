local u = require("config.utils")
--------------------------------------------------------------------------------

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
		init = function()
			vim.g.bullets_delete_last_bullet_if_empty = 1
			vim.g.bullets_enable_in_empty_buffers = 0
			vim.g.bullets_set_mappings = 0
			u.ftKeymap("markdown", "n", "o", "<Plug>(bullets-newline)")
			u.ftKeymap("markdown", "i", "<CR>", "<Plug>(bullets-newline)")
		end,
	},
	{ -- preview markdown
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_preview_options = { disable_sync_scroll = 0 }
			u.ftKeymap(
				"markdown",
				"n",
				"<localleader><localleader>",
				"<Plug>MarkdownPreview",
				{ desc = " Preview" }
			)
		end,
	},
}
