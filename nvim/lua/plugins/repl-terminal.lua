return {
	{ -- better embedded terminal
		"akinsho/toggleterm.nvim",
		opts = {
			size = 10,
			direction = "horizontal",
			autochdir = true, -- when nvim changes pwd, will also change its pwd
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "toggleterm",
				callback = function() vim.opt_local.scrolloff = 0 end,
			})
		end,
		keys = {
			{ "<leader>t", vim.cmd.ToggleTerm, desc = "  ToggleTerm" },
			{
				"<leader>ii",
				vim.cmd.ToggleTermSendCurrentLine,
				ft = "sh",
				desc = "  ToggleTerm: Send Line",
			},
			{
				"<leader>ii",
				vim.cmd.ToggleTermSendVisualSelection,
				ft = "sh",
				mode = "x",
				desc = "  ToggleTerm: Send Sel",
			},
		},
	},
	{ -- REPL
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>it", vim.cmd.IronRepl, desc = "󱠤 Toggle REPL" },
			{ "<leader>ir", vim.cmd.IronRestart, desc = "󱠤 Restart REPL" },
			{ "<leader>ii", desc = "󱠤 Send Line to REPL" },
			{ "<leader>i", mode = { "n", "x" }, desc = "󱠤 Send-to-REPL Operator" },
		},
		main = "iron.core",
		opts = {
			keymaps = {
				send_line = "<leader>ii",
				visual_send = "<leader>i",
				send_motion = "<leader>i",
			},
			config = {
				repl_open_cmd = "horizontal bot 10 split",
				repl_definition = {
					-- not used, since using toggleterm for that
					-- sh = { command = { "zsh" } },
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
}
