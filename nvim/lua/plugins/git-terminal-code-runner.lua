return {
	{ -- Code Runner / Scratchpad
		"metakirby5/codi.vim",
		cmd = { "CodiNew", "Codi", "CodiExpand" },
		init = function ()
			vim.g.codi = {
				rightsplit = true,
			}
		end,
	},
	{ -- better embedded terminal (+ code runner for shell, somewhat)
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "ToggleTermSendVisualSelection" },
		config = function() require("toggleterm").setup() end,
	},
	{ -- git sign gutter & hunk textobj
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("gitsigns").setup {
				max_file_length = 7500,
				preview_config = { border = BorderStyle },
			}
		end,
	},
	{
		"TimUntersberger/neogit",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = "Neogit",
		init = function()
			-- HACK https://github.com/TimUntersberger/neogit/issues/405
			vim.api.nvim_create_augroup("neogit-additions", {})
			vim.api.nvim_create_autocmd("FileType", {
				group = "neogit-additions",
				pattern = "NeogitCommitMessage",
				command = "silent! set filetype=gitcommit",
			})
		end,
		config = function()
			require("neogit").setup {
				disable_insert_on_commit = false, -- false = start commit msgs in insert mode
				disable_commit_confirmation = true,
				disable_builtin_notifications = true, -- BUG does not seem to be working
				integrations = { diffview = true }, -- diffview plugin
				signs = {
					section = { "", "" },
					item = { "", "" },
				},
			}
		end,
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
						{ "n", "<CR>", function() vim.cmd.wincmd("w") end, {} }, -- consistent with general buffer switcher
					},
					file_history_panel = {
						{ "n", "<D-w>", vim.cmd.tabclose, {} },
						{ "n", "?", actions.help("file_history_panel"), {} },
						-- INFO "<cr>" needs to be lowercase to override the default behavior
						{ "n", "<cr>", function() vim.cmd.wincmd("w") end, {} },
						{ "n", "<S-CR>", function() vim.cmd.wincmd("w") end, {} },
					},
				},
			}
		end,
	},
}
