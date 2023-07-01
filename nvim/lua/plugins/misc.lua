return {
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
	{ -- undo history
		"mbbill/undotree",
		keys = {
			{ "<leader>ut", vim.cmd.UndotreeToggle, desc = "󰕌  Undotree" },
		},
		init = function()
			vim.g.undotree_WindowLayout = 3
			vim.g.undotree_DiffpanelHeight = 8
			vim.g.undotree_ShortIndicators = 1
			vim.g.undotree_SplitWidth = 30
			vim.g.undotree_DiffAutoOpen = 0
			vim.g.undotree_SetFocusWhenToggle = 1
			vim.g.undotree_DiffCommand = "delta"
			vim.g.undotree_HelpLine = 1

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "undotree",
				callback = function()
					vim.opt_local.list = false
					vim.keymap.set("n", "<D-w>", vim.cmd.UndotreeToggle, { buffer = true })
				end,
			})
		end,
	},
}
