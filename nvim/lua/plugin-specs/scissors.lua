return {
	"chrisgrieser/nvim-scissors",
	dependencies = "nvim-telescope/telescope.nvim",
	init = function()
		vim.g.whichkeyAddSpec { "<leader>n", group = "󰩫 Snippets", mode = { "n", "x" } }
	end,
	keys = {
		{ "<leader>nn", function() require("scissors").editSnippet() end, desc = "󰩫 Edit" },
		{
			"<leader>na",
			function() require("scissors").addNewSnippet() end,
			mode = { "n", "x" },
			desc = "󰩫 Add",
		},
	},
	opts = {
		editSnippetPopup = {
			height = 0.55, -- between 0-1
			width = 0.75,
			border = vim.g.borderStyle,
			keymaps = {
				deleteSnippet = "<D-BS>",
				insertNextPlaceholder = "<D-t>",
			},
		},
		telescope = { alsoSearchSnippetBody = true },
		jsonFormatter = "yq",
	},
}

