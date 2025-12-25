-- DOCS https://github.com/lewis6991/satellite.nvim
--------------------------------------------------------------------------------

return {
	"lewis6991/satellite.nvim",
	event = "VeryLazy",
	opts = {
		current_only = false,
		winblend = 25, -- only little transparency, since otherwise hard to see in some themes
		handlers = {
			cursor = { enable = false },
			marks = {
				enable = true,
				key = "<Nop>", -- stop satellite.nvim from adding delays to my `m` keybind
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
	end,
}
