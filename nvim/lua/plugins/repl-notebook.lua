return {
	{ -- REPL
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>it", vim.cmd.IronRepl, desc = "󱠤 Toggle REPL" },
			{ "<leader>ir", vim.cmd.IronRestart, desc = "󱠤 Restart REPL" },
			{ "<leader>ii", desc = "󱠤 Send Line" },
			{ "<leader>ii", mode = "x", desc = "󱠤 Send Selection" },
			{ "<leader>i#", desc = "󱠤 Send Operator" },
		},
		init = function()
			local ok, whichKey = pcall(require, "which-key")
			if ok then whichKey.register { ["<leader>i"] = { name = " 󱠤 Iron-REPL" } } end
		end,
		config = function()
			require("iron.core").setup {
				config = {
					repl_open_cmd = require("iron.view").split.horizontal.belowright(8),
					repl_definition = {
						sh = { command = { "zsh" } },
						lua = { command = { "lua" } },
						typescript = { command = { "node" } },
						python = { command = { "python3" } },
						javascript = { command = { "osascript", "-i", "-l", "JavaScript" } },
						applescript = { command = { "osascript", "-i", "-l", "AppleScript" } },
					},
				},
				keymaps = {
					send_line = "<leader>ii",
					visual_send = "<leader>ii",
					send_motion = "<leader>i#",
				},
			}
		end,
	},
	{ -- Emulate Jupyter Notebook Functionality
		"GCBallesteros/NotebookNavigator.nvim",
		keys = {
			{ "gn", function() require("notebook-navigator").move_cell("d") end, desc = " Next Cell" },
			{ "gN", function() require("notebook-navigator").move_cell("u") end, desc = " Prev Cell" },
			{
				"qn",
				function() require("notebook-navigator").add_cell_after("u") end,
				desc = " Add Cell",
			},
			{ "<D-r>", "<cmd>lua require('notebook-navigator').run_cell()<cr>", desc = " Run Cell" },
			{
				"<D-m>",
				"<cmd>lua require('notebook-navigator').run_and_move()<cr>",
				desc = " Run Cell & Goto Next",
			},
		},
		dependencies = { "numToStr/Comment.nvim", "Vigemus/iron.nvim" },
		main = "notebook-navigator",
		opts = {
			cell_markers = {
				python = "# %%",
				sh = "# %%",
				lua = "-- %%",
				javascript = "// %%",
				typescript = "// %%",
			},
		},
	},
	{ -- HTTP requester (e.g., test APIs)
		"rest-nvim/rest.nvim",
		ft = "http",
		dependencies = "nvim-lua/plenary.nvim",
		init = function()
			local a = vim.api
			local keymap = vim.keymap.set

			a.nvim_create_user_command("Rest", function()
				vim.cmd.tabnew()
				a.nvim_buf_set_option(0, "filetype", "http")
				a.nvim_buf_set_option(0, "buftype", "nofile")
				a.nvim_buf_set_name(0, "HTTP Request")
				-- stylua: ignore start
				keymap("n", "<leader>r", "<Plug>RestNvim", { desc = "󰴚 Run Request under cursor", buffer = true })
				keymap("n", "<leader>la", "<Plug>RestNvimLast", { desc = "󰴚 Re-run the last request", buffer = true })
				keymap( "n", "<leader>e", function() 
					vim.fn.system { "open", "https://github.com/rest-nvim/rest.nvim/tree/main/tests" }
				end, { desc = "󰴚 Show example requests", buffer = true })
				vim.notify([[ BINDINGS
,r   run request under cursor
,la  run last request again
,e   show examples for syntax]],
					vim.log.levels.INFO, { timeout = 10000 })
				-- stylua: ignore end
			end, {})
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
						return vim.fn.system { "rome", "format", "--stdin-file-path", "foo.json", body }
					end,
					-- prettier already needed since it's the only proper yaml formatter
					html = function(body) return vim.fn.system { "prettier", "--parser=html", body } end,
				},
			},
		},
	},
}
