--# selene: allow(mixed_table) -- lazy.nvim uses them
local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{
		"GCBallesteros/NotebookNavigator.nvim",
		init = function() u.leaderSubkey("n", " Notebook") end,
		keys = {
			-- stylua: ignore start
			{ "gn", function() require("notebook-navigator").move_cell("d") end, desc = " Next cell" },
			{ "gN", function() require("notebook-navigator").move_cell("u") end, desc = " Prev cell" },
			{ "<leader>na", function() require("notebook-navigator").add_cell_after() end, desc = " Add cell after" },
			{ "<leader>nb", function() require("notebook-navigator").add_cell_before() end, desc = " Add cell before" },
			{ "<D-CR>", function() require("notebook-navigator").run_cell() end, desc = "  Run cell" },
			-- stylua: ignore end
		},
		opts = {
			syntax_highlight = true, -- hl of cell markers
			repl_provider = "iron",
		},
		dependencies = "Vigemus/iron.nvim",
	},
	{ -- REPL
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>nn", vim.cmd.IronRepl, desc = "󱠤 Toggle REPL" },
			{ "<leader>nr", vim.cmd.IronRestart, desc = "󱠤 Restart REPL" },
		},
		main = "iron.core",
		opts = {
			config = {
				repl_open_cmd = "horizontal bot 10 split",
				repl_definition = {
					sh = { command = { "zsh" } },
					lua = { command = { "lua" } },
					typescript = { command = { "node" } },
					javascript = { command = { "osascript", "-i", "-l", "JavaScript" } },
					applescript = { command = { "osascript", "-i", "-l", "AppleScript" } },
					python = {
						command = function()
							local ipythonAvailable = vim.fn.executable("ipython") == 1
							local binary = ipythonAvailable and "ipython" or "python3"
							return { binary }
						end,
					},
				},
			},
		},
	},
	{ -- better embedded terminal
		"akinsho/toggleterm.nvim",
		opts = {
			size = 11,
			direction = "horizontal",
			autochdir = true, -- when nvim changes pwd, will also change its pwd
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "toggleterm",
				callback = function()
					vim.opt_local.scrolloff = 0
					-- stylua: ignore
					vim.keymap.set("n", "q", vim.cmd.close, { buffer = true, nowait = true, desc = "Quit" })
				end,
			})
		end,
		keys = {
			{ "<leader>t", vim.cmd.ToggleTerm, desc = " ToggleTerm" },
			{ "<leader>T", vim.cmd.ToggleTermSendCurrentLine, desc = " ToggleTerm: Send Line" },
			{
				"<leader>T",
				vim.cmd.ToggleTermSendVisualSelection,
				mode = "x",
				desc = "  ToggleTerm: Send Sel",
			},
		},
	},
}
