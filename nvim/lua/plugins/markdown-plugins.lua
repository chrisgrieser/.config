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
		init = function() vim.g.bullets_delete_last_bullet_if_empty = 1 end,
	},
	{ -- preview markdown
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_preview_options = { disable_sync_scroll = 0 }
			u.setupFiletypeKeymap(
				"markdown",
				"n",
				"<localleader><localleader>",
				"<Plug>MarkdownPreview",
				{ desc = " Preview" }
			)
		end,
	},
}
