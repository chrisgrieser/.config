return {
	{ -- REPL
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>tr", vim.cmd.IronRepl, desc = "󱠤 󰐊 Toggle REPL" },
			{ "<leader>tR", vim.cmd.IronRestart, desc = "󱠤 󰐊 Restart REPL" },
			{ "<leader>i", desc = "󱠤 󰐊 REPL: Send Line" },
		},
		config = function()
			require("iron.core").setup {
				config = {
					repl_open_cmd = require("iron.view").split.horizontal.belowright(8),
					repl_definition = {
						sh = { command = { "zsh" } },
						lua = { command = { "lua" } },
						typescript = { command = { "node" } },
						python = { command = { "python3" } },
						-- Applescript & JXA – using `-i` for the REPL
						javascript = { command = { "osascript", "-il", "JavaScript" } },
						applescript = { command = { "osascript", "-i" } },
					},
				},
				keymaps = {
					send_line = "<leader>i",
					visual_send = "<leader>i",
				},
			}
		end,
	},
	{
		'michaelb/sniprun',
		build = 'sh ./install.sh',
	},
	{ -- Emulate Jupyter Notebook Functionality
		"GCBallesteros/NotebookNavigator.nvim",
		keys = {
			{ "gn", function() require("notebook-navigator").move_cell("d") end },
			{ "gN", function() require("notebook-navigator").move_cell("u") end },
			{ "qn", function() require("notebook-navigator").add_cell_after("u") end },
			{ "<D-r>", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
			{ "<D-S-r>", "<cmd>lua require('notebook-navigator').run_and_move()<cr>" },
		},
		dependencies = { "numToStr/Comment.nvim", "Vigemus/iron.nvim" },
		main = "notebook-navigator",
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
		init = function()
			vim.keymap.set("n", "<leader>th", function()
				vim.cmd("en" .. "ew") -- separated due to unignorable codespell error…
				vim.api.nvim_buf_set_option(0, "filetype", "http")
				vim.api.nvim_buf_set_option(0, "buftype", "nowrite")
				vim.api.nvim_buf_set_name(0, "request")
				vim.fn.system("open https://github.com/rest-nvim/rest.nvim/tree/main/tests")
			end, { desc = "󰴚 Test HTTP request" })
		end,
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
		opts = {
			size = 10,
			direction = "horizontal",
			autochdir = true, -- when nvim changes pwd, will also change its pwd
		},
		keys = {
			{ "<leader>tt", vim.cmd.ToggleTerm, desc = "  ToggleTerm" },
		},
		-- loaded by commands in sh ftplugin
		cmd = { "ToggleTermSendCurrentLine", "ToggleTermSendVisualSelection" },
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "sh",
				callback = function()
					-- stylua: ignore
					vim.keymap.set("n", "<leader>i", vim.cmd.ToggleTermSendCurrentLine, { desc = "  REPL: Send Line", buffer = true })
					-- stylua: ignore
					vim.keymap.set("x", "<leader>i", vim.cmd.ToggleTermSendVisualSelection, { desc = "  REPL: Send Selection", buffer = true })
				end,
			})
		end,
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
