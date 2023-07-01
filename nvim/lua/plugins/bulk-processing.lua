return {
	{ -- Multi Cursor
		"mg979/vim-visual-multi",
		keys = { { "<D-j>", mode = { "n", "x" }, desc = "󰆿 Multi-Cursor" } },
		-- already set via lualine component
		init = function()
			-- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
			-- overridden inside snippet for snippetjumping
			vim.g.VM_maps = {
				["Find Under"] = "<D-j>", -- select word under cursor & enter visual-multi (normal) / add next occurrence (visual-multi)
				["Visual Add"] = "<D-j>", -- enter visual-multi (visual)
				["Skip Region"] = "<D-S-j>", -- skip current selection (visual-multi)
			}
			vim.g.VM_set_statusline = 0
		end,
	},
	{ -- structural search & replace
		"cshuaimin/ssr.nvim",
		keys = {
			-- stylua: ignore
			{ "<leader>fs", function() require("ssr").open() end, mode = { "n", "x" }, desc = "󱗘 Structural S&R" },
		},
		opts = {
			keymaps = { close = "Q" }, -- needs remap due conflict with commenting otherwise
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
					local stroke = vim.fn.has("gui_running") and "underdotted" or "underline"
					vim.api.nvim_set_hl(0, "TSDefinition", { [stroke] = true })
					vim.api.nvim_set_hl(0, "TSDefinitionUsage", { [stroke] = true })
				end,
			})
		end,
	},
	{ -- editable quickfix list
		-- my fork, pending on PR: https://github.com/gabrielpoca/replacer.nvim/pull/12
		"gabrielpoca/replacer.nvim",
		keys = {
			-- stylua: ignore
			{ "<leader>fq", function() require("replacer").run { rename_files = true } end, desc = "󱗘  replacer.nvim" },
		},
		-- add keymaps for quicker closing + confirmation
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
			-- stylua: ignore
			{"<leader>fi", function() require("refactoring").refactor("Inline Variable") end, mode = {"n", "x"}, desc = "󱗘 Inline Var" },
			-- stylua: ignore
			{"<leader>fe", function() require("refactoring").refactor("Extract Variable") end, mode = {"n", "x"}, desc = "󱗘 Extract Var" },
		},
	},
	{ -- :substitute but with lua regex
		"chrisgrieser/nvim-alt-substitute",
		keys = {
			{
				"<leader>ff",
				function() return ":S /" .. vim.fn.expand("<cword>") .. "//g<Left><Left>" end,
				mode = { "n", "x" },
				desc = "󱗘 :AltSubstitute (word under cursor)",
				expr = true,
			},
		},
		opts = true,
		dev = true,
	},
	{ -- better macros
		"chrisgrieser/nvim-recorder",
		dev = true,
		keys = {
			{ "9", desc = "/ Continue/Play" },
			{ "8", desc = "/ Breakpoint" },
			{ "0", desc = " Start/Stop Recording" },
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
			}

			local topSeparators = { left = "", right = "" }

			-- INFO inserting needed, to not disrupt existing lualine-segment
			local lualineZ = require("lualine").get_config().tabline.lualine_z or {}
			local lualineY = require("lualine").get_config().tabline.lualine_y or {}
			table.insert(
				lualineZ,
				{ require("recorder").recordingStatus, section_separators = topSeparators }
			)
			table.insert(lualineY, { require("recorder").displaySlots, section_separators = topSeparators })

			require("lualine").setup {
				tabline = {
					lualine_y = lualineY,
					lualine_z = lualineZ,
				},
			}
		end,
	},
}
