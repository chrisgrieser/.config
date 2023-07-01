return {
	{ -- REPL
		"Vigemus/iron.nvim",
		lazy = true,
		main = "icon.core",
		opts = {
			config = {
				highlight_last = "IronLastSent",
				repl_definition = {
					sh = { command = { "zsh" } },
					lua = { command = { "lua" } },
					typescript = { command = { "node" } },
					javascript = { command = { "node" } },
					python = { command = { "python3" } },
				},
			},
		},
	},
	{ -- Emulate Jupyter Notebook Functionality
		"GCBallesteros/NotebookNavigator.nvim",
		keys = {
			{ "gc", function() require("notebook-navigator").move_cell("d") end },
			{ "gC", function() require("notebook-navigator").move_cell("u") end },
			{ "<D-R>", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
			{ "<D-R-s>", "<cmd>lua require('notebook-navigator').run_and_move()<cr>" },
		},
		dependencies = { "numToStr/Comment.nvim", "Vigemus/iron.nvim" },
		event = "VeryLazy",
		opts = {
			cell_markers = {
				python = "# %%",
				sh = "# %%",
				lua = "-- %%",
				javascript = "// %%",
			},
		},
	},
	{ -- HTTP requester (e.g., test APIs)
		"rest-nvim/rest.nvim",
		ft = "http",
		dependencies = "nvim-lua/plenary.nvim",
		opts = {
			result_split_horizontal = true,
			encode_url = true, -- Encode URL before making request
			result = {
				show_url = false,
				show_http_info = true,
				show_headers = false,
				formatters = {
					-- rome cannot format stdin yet
					json = function(body)
						return vim.fn.system("rome format --stdin-file-path='foo.json'", body)
					end,
					-- prettier already needed since it's the only proper yaml formatter
					html = function(body) return vim.fn.system("prettier --parser=html", body) end,
				},
			},
		},
	},
	{ -- better embedded terminal
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "ToggleTermSendVisualSelection" },
		opts = {
			size = 12,
			direction = "horizontal",
			autochdir = true, -- when nvim changes pwd, will also change its pwd
		},
	},
	{ -- git sign gutter & hunk textobj
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		opts = {
			max_file_length = 7500,
			preview_config = { border = require("config.utils").border_style },
		},
	},
	{ -- git client
		"TimUntersberger/neogit",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = "Neogit",
		init = function()
			-- HACK https://github.com/TimUntersberger/neogit/issues/405
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "NeogitCommitMessage",
				command = "silent! set filetype=gitcommit",
			})
		end,
		opts = {
			disable_insert_on_commit = false, -- false = start commit msgs in insert mode
			disable_commit_confirmation = true,
			disable_builtin_notifications = true, -- BUG does not seem to be working
			integrations = { diffview = true }, -- diffview plugin
			signs = {
				section = { "", "" },
				item = { "", "" },
			},
			mappings = {
				status = {
					["<D-w>"] = "close",
				},
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
