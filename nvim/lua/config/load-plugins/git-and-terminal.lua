return {
	{
		"TimUntersberger/neogit",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = "Neogit",
		config = function()
			require("neogit").setup {
				disable_insert_on_commit = false, -- false = start commit msgs in insert mode
				disable_commit_confirmation = false,
				integrations = { diffview = true }, -- diffview plugin
				signs = {
					section = { "", "" },
					item = { "", "" },
				},
			}
		end,
	},
	{ -- only coderunner with virtual text
		"metakirby5/codi.vim",
		cmd = { "Codi", "CodiNew", "CodiExpand" },
	},
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "ToggleTermSendVisualSelection" },
		config = function() require("toggleterm").setup() end,
	},
	{
		"sindrets/diffview.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = { "DiffviewFileHistory", "DiffviewOpen" },
		config = function()
			require("diffview").setup {
				file_history_panel = {
					win_config = { height = 5 },
				},
			}
		end,
	},
}
