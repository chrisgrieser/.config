return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = "nvim-lua/plenary.nvim",
	opts = { show_success_message = true },
	keys = {
		{
			"<leader>ri",
			function() require("refactoring").refactor("Inline Variable") end,
			mode = { "n", "x" },
			desc = "󰫧 Inline variable",
		},
		{
			"<leader>re",
			function()
				vim.cmd.normal { "viW", bang = true }
				require("refactoring").refactor("Extract Variable")
			end,
			desc = "󰫧 Extract cursorWORD as variable",
		},
		{
			"<leader>re",
			function() require("refactoring").refactor("Extract Variable") end,
			mode = "x",
			desc = "󰫧 Extract selection as variable",
		},
		{
			"<leader>rf",
			function() require("refactoring").refactor("Extract Function") end,
			mode = "x",
			desc = " Extract function",
		},
	},
}
