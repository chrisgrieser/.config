--# selene: allow(mixed_table) -- lazy.nvim uses them
local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- Jupyter Notebook Emulation
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
		opts = { syntax_highlight = true }, -- hl of cell markers
		dependencies = "Vigemus/iron.nvim", -- repl provider
	},
	{ -- REPL
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>nn", vim.cmd.IronRepl, desc = "󱠤 Toggle" },
			{ "<leader>nr", vim.cmd.IronRestart, desc = "󱠤 Restart" },
			{ "<leader>nl", function() require("iron.core").send_line() end, desc = "󱠤 Run Line" },
			-- HACK to be able to set everything in `keys`, using the raw functions
			-- provided by iron instead of mapping via opts.keymaps from iron
			{
				"<leader>ni",
				function() require("iron.core").send(nil, string.char(03)) end,
				desc = "󱠤 Interrupt",
			},
			{
				"<leader>nc",
				function() require("iron.core").send(nil, string.char(12)) end,
				desc = "󱠤 Clear",
			},
		},
		config = function()
			local view = require("iron.view")
			require("iron.core").setup {
				config = {
					repl_open_cmd = view.split("30%", { winhighlight = "Normal:NormalFloat" }),
					repl_definition = {
						sh = { command = { "zsh" } },
						typescript = { command = { "node" } },
						javascript = { command = { "osascript", "-i", "-l", "JavaScript" } }, 
						applescript = { command = { "osascript", "-i", "-l", "AppleScript" } },
						python = {
							command = function()
								-- INFO using bypthon, since other REPLs have issues
								-- with docstrings & indentation
								local alternativeRepl = "bypthon"
								local venvPython = u.determineVenv()
								local binary
								if venvPython then
									local venvAltRepl = venvPython:gsub("python$", alternativeRepl)
									vim.notify("🪚 venvAltRepl: " .. tostring(venvAltRepl))
									local altAvailable = vim.fn.executable(venvAltRepl) == 1
									vim.notify("🪚 altAvailable: " .. tostring(altAvailable))
									binary = altAvailable and venvAltRepl or venvPython
								else
									local altAvailable = vim.fn.executable(alternativeRepl) == 1
									binary = altAvailable and alternativeRepl or "python3"
								end

								return { binary }
							end,
						},
					},
				},
			}
		end,
	},
}
