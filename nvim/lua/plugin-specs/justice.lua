return {
	"chrisgrieser/nvim-justice",
	keys = {
		{ "<leader>j", function() require("justice").select() end, desc = "󰖷 Just" },
	},
	opts = {
		keymaps = {
			runFirstRecipe = "j", -- <leader>jj = run first recipe
		},
	},
}
