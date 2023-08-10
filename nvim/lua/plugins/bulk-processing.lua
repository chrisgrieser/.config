local lualineTopSeparators = { left = "", right = "" }

--------------------------------------------------------------------------------

return {
	-- TODO using vimscript multi-cursors, pending https://github.com/smoka7/multicursors.nvim/issues/31
	{ -- Multi Cursor
		"mg979/vim-visual-multi",
		keys = { { "<D-j>", mode = { "n", "x" }, desc = "󰆿 Multi-Cursor" } },
		init = function()
			vim.g.VM_set_statusline = 0 -- already using my version via lualine component
			vim.g.VM_show_warnings = 0
			vim.g.VM_silent_exit = 1
			-- DOCS https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
			vim.g.VM_maps = {
				-- NORMAL/VISUAL_MODE -> enter Visual-Multi
				["Find Under"] = "<D-j>", -- select word under cursor
				["Reselect Last"] = "gV",
				["Visual Add"] = "<D-j>", -- visual: visual-multi with current selection

				-- VISUAL-MULTI-MODE
				-- add next occurrence
				["Skip Region"] = "q", -- skip & find next
				["Remove Region"] = "Q", -- remove & find previous
				["Find Operator"] = "s", -- operator, selects all regions found in textobj
			}

			-- INFO inserting only on load to ensure lazy-loading
			local lualineZ = require("lualine").get_config().tabline.lualine_z or {}
			table.insert(lualineZ, {
				function()
					if not vim.b.VM_Selection then return "" end ---@diagnostic disable-line: undefined-field
					local cursors = vim.b.VM_Selection.Regions
					if not cursors then return "" end
					return "󰇀 " .. tostring(#cursors)
				end,
				section_separators = lualineTopSeparators,
			})

			require("lualine").setup {
				tabline = { lualine_z = lualineZ },
			}
		end,
	},
	-- {
	-- 	"smoka7/multicursors.nvim",
	-- 	dependencies = { "nvim-treesitter/nvim-treesitter", "smoka7/hydra.nvim" },
	-- 	keys = {
	-- 		-- stylua: ignore
	-- 		{ "<D-j>", function() require("multicursors").start() end, mode = { "n", "v" }, desc = "󰆿 Multi-Cursor" },
	-- 	},
	-- 	config = function()
	-- 		local normal = require("multicursors.normal_mode")
	-- 		local extend = require("multicursors.extend_mode")
	-- 		require("multicursors").setup {
	-- 			nowait = true,
	-- 			hint_config = false,
	-- 			create_commands = false,
	-- 			-- methods listed here https://github.com/smoka7/multicursors.nvim/blob/main/lua/multicursors/config.lua
	-- 			normal_keys = {
	-- 				-- add next selection by using the same key again
	-- 				["<D-j>"] = { method = normal.find_next, opts = {} },
	-- 				-- use extend-mode-motions in normal mode
	-- 				["e"] = { method = extend.e_method, opts = {} },
	-- 				["b"] = { method = extend.b_method, opts = {} },
	-- 				["h"] = { method = extend.h_method, opts = {} },
	-- 				["l"] = { method = extend.l_method, opts = {} },
	-- 				["j"] = { method = extend.j_method, opts = {} },
	-- 				["k"] = { method = extend.k_method, opts = {} },
	-- 				["o"] = { method = extend.o_method, opts = {} },
	-- 				["H"] = { method = extend.caret_method, opts = {} },
	-- 				["L"] = { method = extend.dollar_method, opts = {} },
	-- 				["c"] = { method = normal.change, opts = { nowait = true } },
	-- 				["d"] = { method = normal.delete, opts = { nowait = true } },
	-- 			},
	-- 		}
	--
	-- 		-- INFO inserting only on load to ensure lazy-loading of hydra.nvim
	-- 		local lualineZ = require("lualine").get_config().tabline.lualine_z or {}
	-- 		table.insert(lualineZ, {
	-- 			function()
	-- 				local ok, hydra = pcall(require, "hydra.statusline")
	-- 				if not (ok and hydra.is_active()) then return "" end
	-- 				local modeName = hydra.get_name():gsub("MC ", "Multi-")
	-- 				return "󰇀 " .. modeName
	-- 			end,
	-- 			section_separators = lualineTopSeparators,
	-- 		})
	--
	-- 		require("lualine").setup {
	-- 			tabline = { lualine_z = lualineZ },
	-- 		}
	-- 	end,
	-- },
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
		event = "BufReadPre",
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
