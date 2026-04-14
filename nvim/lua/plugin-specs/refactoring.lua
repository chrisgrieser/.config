vim.pack.add {
	-- WARN plenary.nvim is deprecated https://github.com/ThePrimeagen/refactoring.nvim/issues/518
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/ThePrimeagen/refactoring.nvim",
}
--------------------------------------------------------------------------------

Keymap {
	"<leader>ri",
	function() return require("refactoring").refactor("Inline Variable") end,
	mode = { "n", "x" },
	expr = true,
	desc = "󰫧 Inline variable",
}
Keymap {
	"<leader>re",
	function() return require("refactoring").refactor("Extract Variable") end,
	mode = "x",
	expr = true,
	desc = "󰫧 Extract selection as variable",
}
Keymap {
	"<leader>rf",
	function() return require("refactoring").refactor("Extract Function") end,
	mode = "x",
	expr = true,
	desc = " Extract function",
}
--------------------------------------------------------------------------------

-- lazy-load, since it eagerly loads all modules
vim.defer_fn(function()
	require("refactoring").setup {
		show_success_message = true,
	}
end, 500)
