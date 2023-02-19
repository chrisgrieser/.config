return {
	{
		"chrisgrieser/nvim-recorder", 
		dev = false,
		keys = {
			{ "9", nil, desc = "/ Continue/Play" },
			{ "8", nil, desc = "/ Breakpoint" },
			{ "0", nil, desc = " Start/Stop Recording" },
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

			local topSeparators = isGui() and { left = "", right = "" } or { left = "", right = "" }

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
