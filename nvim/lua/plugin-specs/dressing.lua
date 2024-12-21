return {
	"stevearc/dressing.nvim",
	config = function(_, opts)
		require("dressing").setup(opts)
		-- use `snacks` for input, but do not disable `dressing`'s `input` since
		-- it's still needed for genghis
		vim.ui.input = require("snacks").input
	end,
	opts = {
		input = {
			start_mode = "insert",
			trim_prompt = true,
			border = vim.g.borderStyle,
			relative = "editor",
			mappings = {
				n = {
					["q"] = "Close",
					["<Up>"] = "HistoryPrev",
					["<Down>"] = "HistoryNext",
					-- prevent accidental closing due <BS> being mapped to :bprev
					["<BS>"] = "<Nop>",
				},
			},
		},
		select = { enabled = false }, -- using my own selector
	},
}
