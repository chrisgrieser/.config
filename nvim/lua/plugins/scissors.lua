return { -- snippet management
	"chrisgrieser/nvim-scissors",
	dependencies = "nvim-telescope/telescope.nvim",
	init = function() vim.g.whichkeyAddGroup("<leader>n", "󰩫 Snippets") end,
	keys = {
		{ "<leader>nn", function() require("scissors").editSnippet() end, desc = "󰩫 Edit" },
			-- stylua: ignore
			{ "<leader>na", function() require("scissors").addNewSnippet() end, mode = { "n", "x" }, desc = "󰩫 Add" },
	},
	opts = {
		editSnippetPopup = {
			height = 0.5, -- between 0-1
			width = 0.7,
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

