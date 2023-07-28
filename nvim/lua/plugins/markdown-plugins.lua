return {
	{ -- emphasized headers & code blocks
		"lukas-reineke/headlines.nvim",
		ft = "markdown", -- can work in other fts, but I only use it in markdown
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			markdown = {
				fat_headlines = false,
				dash_highlight = false, -- underscore-bold without content in between looks weird otherwise
			},
		},
	},
	{ -- auto-bullets for markdown-like filetypes
		"dkarter/bullets.vim",
		ft = "markdown",
		init = function() vim.g.bullets_delete_last_bullet_if_empty = 1 end,
	},
	{
		"malbertzard/inline-fold.nvim",
		ft = "markdown",
		opts = {
			queries = {
				defaultPlaceholder = "…",
				markdown = {
					{ pattern = '[]'}, 
				},
			},
		},
	},
	{ -- preview markdown
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = "cd app && npm install",
		init = function()
			vim.g.mkdp_preview_options = {
				disable_sync_scroll = 1,
			}
		end,
	},
	{ -- edit code blocks in their own buffer
		"dawsers/edit-code-block.nvim",
		cmd = { "EditCodeBlock", "EditCodeBlockSelection" },
		main = "ecb",
		opts = { wincmd = "split" },
		init = function()
			local u = require("config.utils")
			vim.keymap.set("n", "<leader>e", function()
				if vim.bo.filetype ~= "markdown" then
					vim.notify("Only markdown codeblocks can be edited without a selection.", u.warn)
					return
				end
				vim.cmd.EditCodeBlock()
			end, { desc = " Edit Embedded Code Block" })

			vim.keymap.set("x", "<leader>e", function()
				local fts = { "bash", "applescript", "vim", "javascript" }
				vim.ui.select(fts, { prompt = "Filetype:", kind = "simple" }, function(ft)
					if not ft then return end
					u.leaveVisualMode()
					vim.cmd("'<,'>EditCodeBlockSelection " .. ft)
				end)
			end, { desc = " Edit Embedded Selection" })
		end,
	},
}
