return {
	"chrisgrieser/nvim-justice",
	keys = {
		{ "<leader>j", function() require("justice").select() end, desc = "󰖷 Just" },
	},
	opts = {
		recipes = {
			ignore = {
				name = { "release", "^_" },
				comment = { "interactive" },
			},
			streaming = {
				name = { "download" },
				comment = { "streaming", "curl" },
			},
			quickfix = {
				name = { "%-qf$" },
				comment = { "quickfix" },
			},
		},
		window = { border = vim.g.borderStyle },
		keymaps = {
			closeWin = { "q", "<Esc>", "<D-w>" },
			quickSelect = { "j", "f", "d", "s", "a" },
		},
	},
}
