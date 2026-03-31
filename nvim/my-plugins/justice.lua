vim.pack.add { "https://github.com/chrisgrieser/nvim-justice" }
--------------------------------------------------------------------------------

vim.keymap.set("n", "<leader>j", function() require("justice").select() end, { desc = "󰖷 Just" })

require("justice").setup {
	recipeModes = {
		terminal = {
			name = { "release" }, -- my release scripts usually require version numbers as input
		},
	},
	window = {
		recipeCommentMaxLen = 0, -- `0` = hide recipe comments
		highlightGroups = {
			quickKey = "StandingOut",
		},
		keymaps = {
			runFirstRecipe = "j", -- <leader>jj = run first recipe
			dontUseForQuickKey = { "-", "_" },
		},
	},
}
