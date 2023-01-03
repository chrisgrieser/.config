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
			local actions = require("diffview.actions")
			require("diffview").setup {
				-- https://github.com/sindrets/diffview.nvim#configuration
				enhanced_diff_hl = false, -- true = no red for deletes
				show_help_hints = false,
				file_history_panel = {
					win_config = { height = 5 },
				},
				keymaps = {
					view = {
						{ "n", "<D-w>", vim.cmd.tabclose, {} }, -- close tab instead of window
						{ "n", "<CR>", function () vim.cmd.wincmd("w") end, {} }, -- consistent with general buffer switcher
					},
					file_history_panel = {
						{ "n", "<D-w>", vim.cmd.tabclose, {} }, 
						{ "n", "<CR>", function () vim.cmd.wincmd("w") end, {} }, 
						{ "n", "?", actions.help("file_history_panel"), {} },
					},
				},
			}
		end,
	},
}
