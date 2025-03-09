return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = "nvim-lua/plenary.nvim",
	opts = { show_success_message = true },
	keys = {
		{
			"<leader>ri",
			function() return require("refactoring").refactor("Inline Variable") end,
			mode = { "n", "x" },
			expr = true,
			desc = "󰫧 Inline variable",
		},
		{
			"<leader>re",
			function()
				vim.cmd.normal { "viW", bang = true }
				return require("refactoring").refactor("Extract Variable")
			end,
			expr = true,
			desc = "󰫧 Extract cursorWORD as variable",
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
	},
}
