vim.pack.add { "https://github.com/lewis6991/satellite.nvim" }
--------------------------------------------------------------------------------

require("satellite").setup {
	current_only = false,
	winblend = 25, -- only little transparency, since otherwise hard to see in some themes
	handlers = {
		cursor = { enable = false },
		marks = { enable = false }, -- buggy
	},
}

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
	desc = "User: Highlights for satellite.nvim",
	callback = function()
		vim.api.nvim_set_hl(0, "SatelliteQuickfix", { link = "DiagnosticSignInfo" })
		vim.api.nvim_set_hl(0, "SatelliteMark", { link = "StandingOut" })
	end,
})
