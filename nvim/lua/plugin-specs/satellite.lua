return {
	"lewis6991/satellite.nvim",
	event = "VeryLazy",
	init = function()
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			desc = "User: Change `SatelliteQuickfix` color",
			callback = function()
				vim.api.nvim_set_hl(0, "SatelliteQuickfix", { link = "DiagnosticSignInfo" })
				vim.api.nvim_set_hl(0, "SatelliteMark", { link = "@keyword.return" })
			end,
		})
	end,
	opts = {
		winblend = 10, -- only little transparency, since otherwise hard to see in some themes
		handlers = {
			cursor = { enable = false },
			marks = {
				enable = true,
				key = "<leader>m", -- key with which marks are created, needed to hook up satellite to it
			},
		},
	},
}
