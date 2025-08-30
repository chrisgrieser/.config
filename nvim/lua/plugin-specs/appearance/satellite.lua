---@module "lazy.types"
---@type LazyPluginSpec
return {
	"lewis6991/satellite.nvim",
	event = "VeryLazy",
	opts = {
		current_only = true,
		winblend = 10, -- only little transparency, since otherwise hard to see in some themes
		handlers = {
			cursor = { enable = false },
			marks = {
				enable = true,
				key = "<leader>m", -- key with which marks are created, needed to hook up satellite to it
			},
		},
	},
	init = function()
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			desc = "User: Highlights for satellite.nvim",
			callback = function()
				vim.api.nvim_set_hl(0, "SatelliteQuickfix", { link = "DiagnosticSignInfo" })
				vim.api.nvim_set_hl(0, "SatelliteMark", { link = "StandingOut" })
			end,
		})

		vim.api.nvim_create_autocmd("OptionSet", {
			desc = "User: Hide satellite.nvim scrollbar when wrapping to keep text readable",
			pattern = "wrap",
			callback = function()
				if vim.v.option_type == "global" then
					local changeTo = vim.o.wrap and "Disable" or "Enable"
					vim.cmd("Satellite" .. changeTo)
				end
			end,
		})
	end,
}
