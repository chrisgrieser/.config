local lualineTopSeparators = { left = "", right = "" }

--------------------------------------------------------------------------------

return {
	{ -- Multi Cursor
		"mg979/vim-visual-multi",
		keys = {
			{ "<D-j>", mode = { "n", "x" }, desc = "󰆿 Multi-Cursor" },
			{ "<D-a>", mode = { "n", "x" }, desc = "󰆿 Multi-Cursor" },
		},
		init = function()
			vim.g.VM_set_statusline = 0 -- already using my version via lualine component
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
				["Find Next"] = "y", -- [y]es & find next
				["Skip Region"] = "n", -- [n]o & find next
				["Find Operator"] = "s", -- operator, selects all regions found in textobj
				["Motion $"] = "L", -- use my HL motions here as well
				["Motion ^"] = "H",
			}
		end,
		config = function()
			-- INFO inserting to not override the existing lualine segments
			local lualineZ = require("lualine").get_config().tabline.lualine_z or {}
			table.insert(lualineZ, {
				function()
					if not vim.b.VM_Selection then return "" end ---@diagnostic disable-line: undefined-field
					local cursors = vim.b.VM_Selection.Regions
					if not cursors then return "" end
					return "󰇀 Visual-Multi (" .. tostring(#cursors) .. ")"
				end,
				section_separators = lualineTopSeparators,
			})

			require("lualine").setup {
				tabline = { lualine_z = lualineZ },
			}
		end,
	},
	{ -- structural search & replace
		"cshuaimin/ssr.nvim",
		keys = {
			-- stylua: ignore
			{ "<leader>fs", function() require("ssr").open() end, mode = { "n", "x" }, desc = "󱗘 Structural S&R" },
		},
		opts = { border = require("config.utils").borderStyle },
		config = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "ssr",
				callback = function() vim.opt_local.sidescrolloff = 1 end,
			})
		end,
	},
	{ -- editable quickfix list
		"gabrielpoca/replacer.nvim",
		opts = { rename_files = false },
		keys = {
			{ "<leader>fq", function() require("replacer").run() end, desc = "󱗘  replacer.nvim" },
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
			{"<leader>fe", function() require("refactoring").refactor("Extract Variable") end, mode = {"x"}, desc = "󱗘 Extract Var" },
			{"<leader>fu", function() require("refactoring").refactor("Extract Function") end, mode = {"x"}, desc = "󱗘 Extract Func" },
			-- stylua: ignore end
		},
	},
	{ -- better macros
		"chrisgrieser/nvim-recorder",
		dev = true,
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
				performanceOpts = { countThreshold = 5 },
			}

			-- INFO inserting only on load to ensure lazy-loading
			local lualineZ = require("lualine").get_config().tabline.lualine_z or {}
			local lualineY = require("lualine").get_config().tabline.lualine_y or {}
			table.insert(lualineZ, {
				require("recorder").recordingStatus,
				section_separators = lualineTopSeparators,
			})
			table.insert(lualineY, {
				require("recorder").displaySlots,
				section_separators = lualineTopSeparators,
			})

			require("lualine").setup {
				tabline = {
					lualine_y = lualineY,
					lualine_z = lualineZ,
				},
			}
		end,
	},
}
