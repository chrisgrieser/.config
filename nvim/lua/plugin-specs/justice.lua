return {
	"chrisgrieser/nvim-justice",
	keys = {
		{ "<leader>j", function() require("justice").select() end, desc = "󰖷 Just" },
	},
	opts = {
		highlights = {
			quickSelect = "StandingOut",
		},
		keymaps = {
			runFirstRecipe = "j", -- <leader>jj = run first recipe
			dontUseForQuickKey = { "-", "_" },
		},
		recipes = {
			terminal = {
				name = { "release" }, -- my release scripts usually require version numbers as input
			},
		},
	},
}
