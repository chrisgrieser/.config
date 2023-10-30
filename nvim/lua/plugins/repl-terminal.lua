return {
	{ -- better embedded terminal
		"akinsho/toggleterm.nvim",
		opts = {
			size = 10,
			direction = "horizontal",
			autochdir = true, -- when nvim changes pwd, will also change its pwd
		},
		keys = {
			{ "<leader>t", vim.cmd.ToggleTerm, desc = "  ToggleTerm" },
			{ "<leader>ii", vim.cmd.ToggleTermSendCurrentLine, desc = "  ToggleTerm: Send Line" },
			{ "<leader>ii", vim.cmd.ToggleTermSendVisualSelection, mode = "x", desc = "  ToggleTerm: Send Sel" },
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
