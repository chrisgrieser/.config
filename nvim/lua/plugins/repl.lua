--------------------------------------------------------------------------------

return {
	{ -- REPL
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>i", vim.cmd.IronRepl, desc = "󱠤 Toggle REPL" },
			{ "<leader>I", vim.cmd.IronRestart, desc = "󱠤 Restart REPL" },
			{ "ää", desc = "󱠤 Send Line to REPL" },
			{ "ä", mode = { "n", "x" }, desc = "󱠤 Send-to-REPL Operator" },
			{ "Ä", "ä$", desc = "󱠤 Send-to-REPL to EoL", remap = true },
		},
		main = "iron.core",
		opts = {
			keymaps = {
				send_line = "ää",
				visual_send = "ä",
				send_motion = "ä",
			},
			config = {
				repl_open_cmd = "horizontal bot 10 split",
				repl_definition = {
					sh = { command = { "zsh" } },
					typescript = { command = { "node" } },
					-- osascript is mac-specific
					javascript = { command = { "osascript", "-i", "-l", "JavaScript" } },
					applescript = { command = { "osascript", "-i", "-l", "AppleScript" } },
					python = {
						command = function ()
							local ipythonAvailable = vim.fn.executable("ipython") == 1
							local binary = ipythonAvailable and "ipython" or "python3"
							return { binary }
						end
					},
				},
			},
		},
	},
}
