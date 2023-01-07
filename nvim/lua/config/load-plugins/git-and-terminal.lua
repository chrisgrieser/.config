return {
	{
		"TimUntersberger/neogit",
		dependencies = "nvim-lua/plenary.nvim",
		init = function ()
			vim.api.nvim_create_augroup("neogit-additions", {})
			vim.api.nvim_create_autocmd("FileType", {
				group = "neogit-additions",
				pattern = "NeogitCommitMessage";
				command = "silent! set filetype=gitcommit",
			})
		end,
		cmd = "Neogit",
		config = function()
			require("neogit").setup {
				disable_insert_on_commit = false, -- false = start commit msgs in insert mode
				disable_commit_confirmation = false,
				disable_builtin_notifications = false,
				integrations = { diffview = true }, -- diffview plugin
				signs = {
					section = { "", "" },
					item = { "", "" },
				},
			}
			augroup("neogit-additions", {})
			autocmd("NeogitCommitComplete", {
				group = "neogit-additions",
				callback = function()
					
				end
			})
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
		init = function()
			-- HACK since for whatever reason, adding this as a keymap below does not work
			vim.api.nvim_create_augroup("diffview-fix", {})
			vim.api.nvim_create_autocmd("FileType", {
				group = "diffview-fix",
				pattern = "DiffviewFileHistory",
				callback = function() vim.keymap.set("n", "<CR>", "<C-w>w", { buffer = true }) end,
			})
		end,
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
					},
				},
			}
		end,
	},
}
