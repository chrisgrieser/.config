return {
	{ -- emphasized headers & code blocks
		"lukas-reineke/headlines.nvim",
		ft = "markdown", -- can work in other fts, but I only use it in markdown
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			markdown = { fat_headlines = false },
		},
	},
	{
		"AckslD/nvim-FeMaco.lua",
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.keymap.set(
						"n",
						"<localleader>c",
						function() require("femaco.edit").edit_code_block() end,
						{ desc = " Edit Code Block", buffer = true }
					)
				end,
			})
		end,
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
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					vim.keymap.set(
						"n",
						"<localleader><localleader>",
						"<Plug>MarkdownPreview",
						{ desc = " Preview", buffer = true }
					)
				end,
			})
		end,
	},
}
