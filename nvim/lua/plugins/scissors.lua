vim.pack.add { "https://github.com/chrisgrieser/nvim-scissors" }
--------------------------------------------------------------------------------

vim.g.whichkeyAddSpec { "<leader>n", group = "󰩫 Snippets" }

require("config.utils").pluginKeymaps {
	{ "<leader>nn", function() require("scissors").editSnippet() end, desc = "󰩫 Edit" },
	{
		"<leader>na",
		function() require("scissors").addNewSnippet() end,
		mode = { "n", "x" },
		desc = "󰩫 Add",
	},
}

--------------------------------------------------------------------------------

require("scissors").setup {
	editSnippetPopup = {
		height = 0.55, -- between 0-1
		width = 0.75,
		keymaps = {
			deleteSnippet = "<leader>fd", -- same as `genghis` mapping for deleting file
			duplicateSnippet = "<leader>fw", -- same as `genghis` mapping for duplicating file
			insertNextPlaceholder = "<D-t>", -- same as inserting template string
		},
	},
	snippetSelection = {
		picker = "snacks",
		telescope = { alsoSearchSnippetBody = true },
	},
	jsonFormatter = "jq", -- `jq` pre-installed on newer macOS versions
}
