vim.pack.add { "https://github.com/lewis6991/satellite.nvim" }
--------------------------------------------------------------------------------

require("satellite").setup {
	current_only = true,
	handlers = {
		cursor = { enable = false },
		marks = { enable = false }, -- buggy
	},

	-- effectively hide scrollbar, since using neovide's scrollbar
	-- PENDING -- effectively hide scrollbar, since using neovide's scrollbar
	winblend = 100,
}

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
	desc = "User: Highlights for satellite.nvim",
	callback = function()
		vim.api.nvim_set_hl(0, "SatelliteQuickfix", { link = "DiagnosticSignInfo" })
		vim.api.nvim_set_hl(0, "SatelliteMark", { link = "StandingOut" })
	end,
})
