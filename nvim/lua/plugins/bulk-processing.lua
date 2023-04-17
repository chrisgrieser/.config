return {
	{ -- Multi Cursor
		"mg979/vim-visual-multi",
		keys = { { "<D-j>", mode = { "n", "x" }, desc = "󰆿 Multi-Cursor" } },
		-- already set via lualine component
		init = function() vim.g.VM_set_statusline = 0 end,
	},
	{ -- :substitute, but with lua pattern
		"chrisgrieser/nvim-alt-substitute",
		dev = true,
		event = "CmdlineEnter", -- loading with `cmd =` does not work with incremental preview
		config = true,
	},
	{ -- structural search & replace
		"cshuaimin/ssr.nvim",
		lazy = true,
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
	},
	{
		-- my fork, pending on PR: https://github.com/gabrielpoca/replacer.nvim/pull/12
		"chrisgrieser/replacer.nvim",
		lazy = true,
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
	{
		"ThePrimeagen/refactoring.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		config = true,
	},
	{
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

			local topSeparators = { left = " ", right = " " }

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
