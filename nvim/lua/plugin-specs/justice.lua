return {
	"chrisgrieser/nvim-justice",
	keys = {
		{ "<leader>j", function() require("justice").select() end, desc = "󰖷 Just" },
	},
	opts = {
		recipes = {
			terminal = {
				name = { "release" }, -- my release scripts usually require version numbers as input
			},
		},
		window = {
			highlights = {
				quickSelect = "StandingOut",
			},
			keymaps = {
				runFirstRecipe = "j", -- <leader>jj = run first recipe
				dontUseForQuickKey = { "-", "_" },
			},
		},
	},
}
