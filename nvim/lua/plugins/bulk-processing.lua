return {
	{
		"mg979/vim-visual-multi",
		keys = { { "<D-j>", mode = { "n", "x" }, desc = "Multi-Cursor" } },
	},
	{
		"cshuaimin/ssr.nvim", -- structural search & replace
		lazy = true,
		config = function()
			require("ssr").setup {
				keymaps = { close = "Q" },
			}
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
		dev = true,
		init = function()
			-- save & quit via "q"
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "replacer",
				callback = function()
					-- stylua: ignore
					vim.keymap.set( "n", "q", vim.cmd.write, { desc = " Finish replacing", buffer = true, nowait = true })
				end,
			})
		end,
	},
	{
		"ThePrimeagen/refactoring.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		config = function() require("refactoring").setup() end,
	},
	{
		"chrisgrieser/nvim-recorder", 
		dev = true,
		keys = {
			{ "9", desc = "/ Continue/Play" },
			{ "8", desc = "/ Breakpoint" },
			{ "0", desc = " Start/Stop Recording" },
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

			local topSeparators = vim.g.neovide and { left = "", right = "" } or { left = "", right = "" }

			-- INFO inserting needed, to not disrupt existing lualine-segment set by dap
			local lualineZ = require("lualine").get_config().winbar.lualine_z or {}
			local lualineY = require("lualine").get_config().winbar.lualine_y or {}
			table.insert(lualineZ, 
				{ require("recorder").recordingStatus, section_separators = topSeparators }
			)
			table.insert(lualineY, 
				{ require("recorder").displaySlots, section_separators = topSeparators }
			)

			require("lualine").setup {
				winbar = {
					lualine_y = lualineY,
					lualine_z = lualineZ,
				},
			}
		end,
	},
}
