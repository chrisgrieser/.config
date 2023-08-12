return {
	{
		"pwntester/octo.nvim",
		cmd = "Octo",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		init = function()
			-- autocomplete for @ and #
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "octo", "NeogitCommitMessage" },
				callback = function()
					vim.keymap.set("i", "@", "@<C-x><C-o>", { silent = true, buffer = true })
					vim.keymap.set("i", "#", "#<C-x><C-o>", { silent = true, buffer = true })
				end,
			})
		end,
		opts = {
			-- https://github.com/pwntester/octo.nvim#%EF%B8%8F-configuration
			ui = { use_signcolumn = true }, -- show "modified" marks on the sign column
			mappings = {
				issue = {
					close_issue = { lhs = "<leader>ic", desc = " close issue" },
					reopen_issue = { lhs = "<leader>io", desc = " reopen issue" },
					list_issues = { lhs = "<leader>gi", desc = " list open issues on same repo" },
					reload = { lhs = "<D-r>", desc = " reload issue" },
					open_in_browser = { lhs = "<leader>gu", desc = " open issue in browser" },
					copy_url = { lhs = "<leader>gU", desc = " copy url to system clipboard" },
					add_comment = { lhs = "<leader>ca", desc = " add comment" },
					delete_comment = { lhs = "<leader>cd", desc = " delete comment" },
					next_comment = { lhs = "gc", desc = " go to next comment" },
					prev_comment = { lhs = "gC", desc = " go to previous comment" },
					react_hooray = { lhs = "<leader>rp", desc = " add/remove 🎉 reaction" },
					react_heart = { lhs = "<leader>rh", desc = " add/remove ❤️ reaction" },
					react_eyes = { lhs = "<leader>re", desc = " add/remove 👀 reaction" },
					react_thumbs_up = { lhs = "<leader>r+", desc = " add/remove 👍 reaction" },
					react_thumbs_down = { lhs = "<leader>r-", desc = " add/remove 👎 reaction" },
					react_rocket = { lhs = "<leader>rr", desc = " add/remove 🚀 reaction" },
					react_laugh = { lhs = "<leader>rl", desc = " add/remove 😄 reaction" },
					react_confused = { lhs = "<leader>rc", desc = " add/remove 😕 reaction" },
				},
			},
		},
	},
	{ -- git sign gutter & hunk textobj
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		opts = { max_file_length = 7500 },
	},
	{ -- git client
		"NeogitOrg/neogit",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = "Neogit",
		opts = {
			disable_insert_on_commit = "auto", -- insert only if commit msg empty
			disable_commit_confirmation = true,
			disable_builtin_notifications = true,
			remember_settings = true,
			signs = {
				section = { "", "" },
				item = { "", "" },
				hunk = { "", "" },
			},
			mappings = {
				status = { ["<D-w>"] = "Close" },
			},
		},
	},
	{ -- diff / merge
		"sindrets/diffview.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = { "DiffviewFileHistory", "DiffviewOpen" },
		config = function() -- needs config, for access to diffview.actions in mappings
			require("diffview").setup {
				-- https://github.com/sindrets/diffview.nvim#configuration
				enhanced_diff_hl = false, -- true = no red for deletes
				show_help_hints = false,
				file_history_panel = {
					win_config = { height = 5 },
				},
				hooks = {
					diff_buf_read = function()
						-- set buffername, mostly for tabline (lualine)
						pcall(function() vim.api.nvim_buf_set_name(0, "Diffview") end)
					end,
				},
				keymaps = {
					view = {
						{ "n", "<D-w>", vim.cmd.tabclose, {} }, -- close tab instead of window
						{ "n", "<S-CR>", function() vim.cmd.wincmd("w") end, {} }, -- consistent with general buffer switcher
					},
					file_history_panel = {
						{ "n", "<D-w>", vim.cmd.tabclose, {} },
						{ "n", "?", require("diffview.actions").help("file_history_panel"), {} },
						{ "n", "<S-CR>", function() vim.cmd.wincmd("w") end, {} },
					},
				},
			}
		end,
	},
}
