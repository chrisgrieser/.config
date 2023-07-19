return {
	{ -- REPL
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>it", vim.cmd.IronRepl, desc = "󱠤 Toggle REPL" },
			{ "<leader>ir", vim.cmd.IronRestart, desc = "󱠤 Restart REPL" },
			{ "<leader>ii", desc = "󱠤 REPL: Send Line" },
		},
		init = function ()
			require("which-key").register { mode = { "n" }, ["<leader>i"] = { name = " 󱠤 REPL (Iron)" } }
		end,
		config = function()
			require("iron.core").setup {
				config = {
					repl_open_cmd = require("iron.view").split.horizontal.belowright(8),
					repl_definition = {
						-- using ToggleTerm as REPL for zsh
						lua = { command = { "lua" } },
						typescript = { command = { "node" } },
						python = { command = { "python3" } },
						javascript = { command = { "osascript", "-i", "-l", "JavaScript" } },
						applescript = { command = { "osascript", "-i" } },
					},
				},
				keymaps = {
					send_line = "<leader>ii",
					visual_send = "<leader>ii",
				},
			}
		end,
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
			{ "<leader>t", vim.cmd.ToggleTerm, desc = "  ToggleTerm" },
		},
		cmd = { "ToggleTermSendCurrentLine", "ToggleTermSendVisualSelection" },
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "sh",
				callback = function()
					-- stylua: ignore
					vim.keymap.set("n", "<leader>ii", vim.cmd.ToggleTermSendCurrentLine, { desc = " REPL: Send Line", buffer = true })
					-- stylua: ignore
					vim.keymap.set("x", "<leader>ii", vim.cmd.ToggleTermSendVisualSelection, { desc = " REPL: Send Selection", buffer = true })
				end,
			})
		end,
	},
}
