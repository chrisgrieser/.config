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
				pattern = "octo",
				callback = function()
					vim.keymap.set("i", "@", "@<C-x><C-o>", { silent = true, buffer = true })
					vim.keymap.set("i", "#", "#<C-x><C-o>", { silent = true, buffer = true })
					vim.keymap.set(
						"n",
						"<leader>gu",
						"<leader>öu",
						{ silent = true, buffer = true, remap = true, desc = " Open in browser" }
					)
				end,
			})

			local ok, whichKey = pcall(require, "which-key")
			if ok then whichKey.register { ["<leader>ö"] = { name = "  Octo" } } end
		end,
		opts = {
			-- https://github.com/pwntester/octo.nvim#%EF%B8%8F-configuration
			ui = { use_signcolumn = true }, -- pending: https://github.com/pwntester/octo.nvim/issues/80

			issues = { order_by = { field = "UPDATED_AT" } }, -- COMMENTS|CREATED_AT|UPDATED_AT
			pull_requests = { order_by = { field = "UPDATED_AT" } },

			mappings = {
				issue = {
					close_issue = { lhs = "<leader>öc", desc = " Close issue" },
					reopen_issue = { lhs = "<leader>öo", desc = " Reopen issue" },
					reload = { lhs = "<leader>öi", desc = " Reload issue" },
					open_in_browser = { lhs = "<leader>öu", desc = " Open in browser" },
					copy_url = { lhs = "<leader>öU", desc = " Copy URL" },
					add_comment = { lhs = "<leader>öc", desc = " Add comment" },
					delete_comment = { lhs = "<leader>öC", desc = " Delete comment" },
					next_comment = { lhs = "gc", desc = " Goto next comment" },
					prev_comment = { lhs = "gC", desc = " Goto prev comment" },
					add_label = { lhs = "<space>öl", desc = " Add label" },
					remove_label = { lhs = "<space>öL", desc = " Remove label" },

					react_hooray = { lhs = "<leader>örp", desc = " Toggle 🎉" },
					react_heart = { lhs = "<leader>örh", desc = " Toggle ❤️" },
					react_eyes = { lhs = "<leader>öre", desc = " Toggle 👀" },
					react_thumbs_up = { lhs = "<leader>ör+", desc = " Toggle 👍" },
					react_thumbs_down = { lhs = "<leader>ör-", desc = " Toggle 👎" },
					react_rocket = { lhs = "<leader>örr", desc = " Toggle 🚀" },
					react_laugh = { lhs = "<leader>örl", desc = " Toggle 😄" },
					react_confused = { lhs = "<leader>örc", desc = " Toggle 😕" },
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
