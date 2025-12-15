return {
	"chrisgrieser/nvim-justice",
	keys = {
		{ "<leader>j", function() require("justice").select() end, desc = "󰖷 Just" },
	},
	init = function() vim.env.npm_config_fund = false end, -- disable funding nags
	opts = {
		recipeModes = {
			terminal = {
				name = { "release" }, -- my release scripts usually require version numbers as input
			},
		},
		window = {
			highlightGroups = {
				quickKey = "StandingOut",
			},
			keymaps = {
				runFirstRecipe = "j", -- <leader>jj = run first recipe
				dontUseForQuickKey = { "-", "_" },
			},
		},
	},
}
