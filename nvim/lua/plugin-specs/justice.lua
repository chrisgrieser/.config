return {
	"chrisgrieser/nvim-justice",
	keys = {
		{ "<leader>j", function() require("justice").select() end, desc = "󰖷 Just" },
	},
	opts = {
		recipes = {
			ignore = {
				name = {},
				comment = {},
			},
			streaming = {
				name = { "download" },
				comment = { "streaming", "curl" },
			},
			quickfix = {
				name = { "%-qf$" },
				comment = { "quickfix" },
			},
			terminal = {
				name = { "release" },
				comment = { "in the terminal" },
			},
		},
		keymaps = {
			closeWin = { "q", "<Esc>", "<D-w>" },
			quickSelect = { "j", "f", "d", "s", "a" },
		},
	},
}
