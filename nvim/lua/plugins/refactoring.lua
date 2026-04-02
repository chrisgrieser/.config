vim.pack.add {
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/ThePrimeagen/refactoring.nvim",
}
--------------------------------------------------------------------------------

require("config.utils").pluginKeymaps {
	{
		"<leader>ri",
		function() return require("refactoring").refactor("Inline Variable") end,
		mode = { "n", "x" },
		expr = true,
		desc = "󰫧 Inline variable",
	},
	{
		"<leader>re",
		function() return require("refactoring").refactor("Extract Variable") end,
		mode = "x",
		expr = true,
		desc = "󰫧 Extract selection as variable",
	},
	{
		"<leader>rf",
		function() return require("refactoring").refactor("Extract Function") end,
		mode = "x",
		expr = true,
		desc = " Extract function",
	},
}

--------------------------------------------------------------------------------

require("refactoring").setup { show_success_message = true }
