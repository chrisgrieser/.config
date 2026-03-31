vim.pack.add { "https://github.com/lewis6991/satellite.nvim" }
--------------------------------------------------------------------------------

require("satellite.nvim").setup {
	current_only = false,
	winblend = 25, -- only little transparency, since otherwise hard to see in some themes
	handlers = {
		cursor = { enable = false },
		marks = {
			enable = true,
			-- Stop satellite.nvim from adding delays to my `m` keybind. Requires
			-- a string, but do not use `""` or `<Nop>`, since they break things
			-- like whichkey, use a throwaway like ¶ if nothing fits.
			key = "<leader>m",
		},
	},
}

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
	desc = "User: Highlights for satellite.nvim",
	callback = function()
		vim.api.nvim_set_hl(0, "SatelliteQuickfix", { link = "DiagnosticSignInfo" })
		vim.api.nvim_set_hl(0, "SatelliteMark", { link = "StandingOut" })
	end,
})
