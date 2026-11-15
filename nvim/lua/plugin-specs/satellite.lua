vim.pack.add { "https://github.com/lewis6991/satellite.nvim" }
--------------------------------------------------------------------------------

require("satellite").setup {
	current_only = true,
	handlers = {
		cursor = { enable = false },
		marks = { enable = false }, -- buggy
	},

	-- hide scrollbar when using neovide's
	winblend = vim.g.neovide_system_scrollbar and 100 or 25,
}

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
	desc = "User: Highlights for satellite.nvim",
	callback = function()
		vim.api.nvim_set_hl(0, "SatelliteQuickfix", { link = "DiagnosticSignInfo" })
		vim.api.nvim_set_hl(0, "SatelliteMark", { link = "StandingOut" })
	end,
})
