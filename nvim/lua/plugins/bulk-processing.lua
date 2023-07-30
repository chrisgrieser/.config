return {
	{ -- Multi Cursor
		"mg979/vim-visual-multi",
		keys = { { "<D-j>", mode = { "n", "x" }, desc = "󰆿 Multi-Cursor" } },
		init = function()
			vim.g.VM_set_statusline = 0 -- already using my version via lualine component
			vim.g.VM_show_warnings = 0
			vim.g.VM_silent_exit = 1
			-- https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
			vim.g.VM_maps = {
				["Find Under"] = "<D-j>", -- select word under cursor & enter visual-multi (normal) / add next occurrence (visual-multi)
				["Visual Add"] = "<D-j>", -- enter visual-multi (visual)
				["Skip Region"] = "<D-S-j>", -- skip current selection (visual-multi)
				["Find Operator"] = "s", -- operator, selects all regions found in the given textobj (visual-multi)
				["Reselect Last"] = "gV",
			}
		end,
	},
	-- TODO switch to multicursor.nvim once it's stable
	-- {
	-- 	"smoka7/multicursors.nvim",
	-- 	event = "VeryLazy",
	-- 	opts = true,
	-- 	keys = {
	-- 		{ "<D-j>", "<cmd>MCstart<CR>", desc = "󰆿 Multi-Select word under the cursor" },
	-- 	},
	-- },
	{ -- structural search & replace, alternative: https://ast-grep.github.io/guide/editor-integration.html
		"cshuaimin/ssr.nvim",
		keys = {
			-- stylua: ignore
			{ "<leader>fs", function() require("ssr").open() end, mode = { "n", "x" }, desc = "󱗘 Structural S&R" },
		},
		opts = {
			keymaps = { close = "Q" }, -- needs remap due conflict with commenting keymap
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "ssr",
				callback = function() vim.opt_local.sidescrolloff = 0 end,
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
					local strokeType = vim.fn.has("gui_running") and "underdotted" or "underline"
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
