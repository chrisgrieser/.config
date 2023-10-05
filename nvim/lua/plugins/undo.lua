return {
	{ -- undo history
		"mbbill/undotree",
		keys = {
			{ "<leader>ut", vim.cmd.UndotreeToggle, desc = "󰕌  Undotree" },
		},
		init = function()
			vim.g.undotree_WindowLayout = 3
			vim.g.undotree_DiffpanelHeight = 10
			vim.g.undotree_ShortIndicators = 1
			vim.g.undotree_SplitWidth = 30
			vim.g.undotree_DiffAutoOpen = 0
			vim.g.undotree_SetFocusWhenToggle = 1
			vim.g.undotree_HelpLine = 1

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "undotree",
				callback = function()
					vim.defer_fn(function()
						vim.keymap.set("n", "J", "6j", { buffer = true })
						vim.keymap.set("n", "K", "6k", { buffer = true })
					end, 1)
				end,
			})
		end,
	},
}
