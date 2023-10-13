local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- editable quickfix list
		"gabrielpoca/replacer.nvim",
		opts = { rename_files = false },
		keys = {
			{ "<leader>fq", function() require("replacer").run() end, desc = " replacer" },
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
