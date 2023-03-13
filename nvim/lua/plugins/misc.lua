return {
	{
		"iamcco/markdown-preview.nvim",
		ft = "markdown",
		build = "cd app && npm install",
	},
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
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
					vim.keymap.set("n", "<D-w>", ":UndotreeToggle<CR>", { buffer = true })
					vim.opt_local.listchars = "space: "
				end,
			})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			vim.opt.timeoutlen = 600 -- duration until which-key is shown
			require("which-key").setup {
				plugins = {
					presets = {
						operators = true,
						motions = false,
					},
				},
				triggers_blacklist = {
					n = { "y" }, -- FIX "y" needed to fix weird delay occurring when yanking after a change
				},
				hidden = {},
				window = {
					border = { "", "─", "", "" }, -- no border to the side to save space
					padding = { 0, 0, 0, 0 },
					margin = { 0, 0, 0, 0 },
				},
				layout = { -- of the columns
					height = { min = 4, max = 17 },
					width = { min = 22, max = 33 },
					spacing = 1,
				},
			}
		end,
	},
}
