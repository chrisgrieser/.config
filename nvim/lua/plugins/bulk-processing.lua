local u = require("config.utils")
--------------------------------------------------------------------------------

return {
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
				["Reselect Last"] = "gV",
				["Visual Add"] = "<D-j>",
				["Select All"] = "<D-a>",
				["Visual All"] = "<D-a>",

				-- Visual-Multi-Mode Mappings
				["Find Next"] = "<D-j>",
				["Skip Region"] = "n", -- [n]o & find next
				["Remove Region"] = "N", -- [N]o & goto prev
				["Find Operator"] = "s", -- operator, selects all regions found in textobj
				["Motion $"] = "L", -- use my HL motions here as well
				["Motion ^"] = "H",
			}
		end,
		config = function()
			u.addToLuaLine("tabline", "lualine_z", function()
				---@diagnostic disable-next-line: undefined-field
				if not vim.b.VM_Selection or not vim.b.VM_Selection.Regions then return "" end
				return ("󰇀 Visual-Multi (%s)"):format(#vim.b.VM_Selection.Regions)
			end)
		end,
	},
	{ -- editable quickfix list
		"gabrielpoca/replacer.nvim",
		opts = { rename_files = false },
		keys = {
			{ "<leader>fq", function() require("replacer").run() end, desc = " Replacer" },
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "replacer",
				callback = function()
					-- stylua: ignore
					vim.keymap.set("n", "q", vim.cmd.close, { desc = "Abort replacements", buffer = true, nowait = true })
					-- stylua: ignore
					vim.keymap.set("n", "<CR>", vim.cmd.write, { desc = "Confirm replacements", buffer = true, nowait = true })
				end,
			})
		end,
	},
	{ -- refactoring utilities
		"ThePrimeagen/refactoring.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		opts = true,
		keys = {
			-- stylua: ignore start
			{"<leader>fi", function() require("refactoring").refactor("Inline Variable") end, mode = {"n", "x"}, desc = "󱗘 Inline Var" },
			{"<leader>fe", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "󱗘 Extract Var" },
			{"<leader>fu", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "󱗘 Extract Func" },
			-- stylua: ignore end
		},
	},
	{ -- better macros
		"chrisgrieser/nvim-recorder",
		keys = {
			{ "0", desc = " Start/Stop Recording" },
			{ "9", desc = "/ Continue/Play" },
			{ "8", desc = "/ Breakpoint" },
		},
		config = function()
			require("recorder").setup {
				clear = true,
				logLevel = vim.log.levels.TRACE,
				mapping = {
					startStopRecording = "0",
					playMacro = "9",
					switchSlot = "<C-0>",
					editMacro = "c0",
					yankMacro = "y0",
					addBreakPoint = "8",
				},
				dapSharedKeymaps = true,
				performanceOpts = { countThreshold = 10 },
			}
			u.addToLuaLine("tabline", "lualine_z", require("recorder").recordingStatus)
			u.addToLuaLine("tabline", "lualine_y", require("recorder").displaySlots)
		end,
	},
}
