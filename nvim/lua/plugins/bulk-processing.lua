local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- global search & replace
		"MagicDuck/grug-far.nvim",
		external_dependencies = "rg",
		keys = {
			{ "<leader>fg", vim.cmd.GrugFar, desc = " Search & Replace Globally" },
		},
		opts = {
			extraRgArgs = "", -- for example to always display context lines around matches
			keymaps = {
				replace = "<Enter>",
				qflist = "<D-s>",
				close = "q",
			},
		},
	},
	{ -- Multi Cursor
		"mg979/vim-visual-multi",
		keys = {
			{ "<D-j>", mode = { "n", "x" }, desc = "󰆿 Multi-Cursor (Cursor Word)" },
			{ "<D-a>", mode = { "n", "x" }, desc = "󰆿 Multi-Cursor (All)" },
		},
		init = function()
			vim.g.VM_set_statusline = 0 -- using my version via lualine component
			vim.g.VM_show_warnings = 0
			vim.g.VM_silent_exit = 1
			vim.g.VM_quit_after_leaving_insert_mode = 1 -- can use "reselect last" to restore
			-- DOCS https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
			vim.g.VM_maps = {
				-- Enter Visual-Multi-Mode
				["Find Under"] = "<D-j>", -- select word under cursor
				["Visual Add"] = "<D-j>",
				["Select All"] = "<D-a>",
				["Reselect Last"] = "gV",
				["Visual All"] = "<D-a>",

				-- Visual-Multi-Mode Mappings
				["Find Next"] = "<D-j>",
				["Find Prev"] = "<D-J>",
				["Skip Region"] = "n", -- [n]o & find next
				["Remove Region"] = "N", -- [N]o & goto prev
				["Find Operator"] = "s", -- operator, selects all regions found in textobj

				["Motion $"] = "L", -- consistent with my mappings
				["Motion ^"] = "H",
			}
		end,
		config = function()
			u.addToLuaLine("sections", "lualine_z", function()
				if not vim.b["VM_Selection"] or not vim.b["VM_Selection"].Regions then return "" end
				return ("󰇀 %s"):format(#vim.b.VM_Selection.Regions)
			end)
		end,
	},
	{ -- refactoring utilities
		"ThePrimeagen/refactoring.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		opts = { show_success_message = true },
		keys = {
			-- stylua: ignore start
			{"<leader>fi", function() require("refactoring").refactor("Inline Variable") end, mode = {"n", "x"}, desc = "󱗘 Inline Var" },
			{"<leader>fe", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "󱗘 Extract Var" },
			{"<leader>fI", function() require("refactoring").refactor("Inline Function") end, desc = "󱗘 Inline Func" },
			{"<leader>fE", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "󱗘 Extract Func" },
			{"<leader>fF", function() require("refactoring").refactor("Extract Function To File") end, mode = "x", desc = "󱗘 Extract Func to File" },
			-- stylua: ignore end
		},
	},
	{ -- better macros
		"chrisgrieser/nvim-recorder",
		keys = {
			{ "0", desc = "  Start/Stop Recording" },
			{ "9", desc = " /  Continue/Play" },
			{ "8", desc = " /  Breakpoint" },
		},
		opts = {
			clear = true,
			logLevel = vim.log.levels.TRACE,
			mapping = {
				startStopRecording = "0",
				playMacro = "9",
				switchSlot = "<C-0>",
				editMacro = "c0",
				yankMacro = "y0",
				deleteAllMacros = "d0",
				addBreakPoint = "8",
			},
			dapSharedKeymaps = true,
			performanceOpts = { countThreshold = 101 },
		},
	},
}
