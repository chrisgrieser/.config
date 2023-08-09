return {
	{
		"smoka7/multicursors.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "smoka7/hydra.nvim" },
		keys = {
			-- stylua: ignore
			{ "<D-j>", function() require("multicursors").start() end, mode = { "n", "v" }, desc = "󰆿 Multi-Cursor" },
		},
		config = function()
			local normal = require("multicursors.normal_mode")
			local extend = require("multicursors.extend_mode")
			require("multicursors").setup {
				hint_config = false,
				create_commands = false,
				normal_keys = {
					-- add next selection by using the same key again
					["<D-j>"] = { method = normal.find_next, opts = {} },
					-- use extend-mode-motions in normal mode
					["e"] = { method = extend.e_method, opts = {} },
					["b"] = { method = extend.b_method, opts = {} },
					["h"] = { method = extend.h_method, opts = {} },
					["l"] = { method = extend.l_method, opts = {} },
					["j"] = { method = extend.j_method, opts = {} },
					["k"] = { method = extend.k_method, opts = {} },
					["o"] = { method = extend.o_method, opts = {} },
					["H"] = { method = extend.caret_method, opts = {} },
					["L"] = { method = extend.dollar_method, opts = {} },
				},
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
	{ -- highlight word under cursor & batch renamer
		"nvim-treesitter/nvim-treesitter-refactor",
		event = "BufEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
		init = function()
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					-- Terminal does not support underdotted
					local strokeType = vim.fn.has("gui_running") == 1 and "underdotted" or "underline"
					vim.api.nvim_set_hl(0, "TSDefinition", { [strokeType] = true })
					vim.api.nvim_set_hl(0, "TSDefinitionUsage", { [strokeType] = true })
				end,
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

			-- INFO inserting needed to not disrupt existing lualine-segment
			local topSeparators = { left = "", right = "" }
			local lualineZ = require("lualine").get_config().tabline.lualine_z or {}
			local lualineY = require("lualine").get_config().tabline.lualine_y or {}
			table.insert(lualineZ, {
				require("recorder").recordingStatus,
				section_separators = topSeparators,
			})
			table.insert(lualineY, {
				require("recorder").displaySlots,
				section_separators = topSeparators,
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
