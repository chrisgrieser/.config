vim.pack.add {
	"https://github.com/lewis6991/async.nvim",
	"https://github.com/theprimeagen/refactoring.nvim",
}
--------------------------------------------------------------------------------

Keymap {
	"<leader>ri",
	function() return require("refactoring").inline_var() end,
	mode = { "n", "x" },
	expr = true,
	desc = "󰫧 Inline variable",
}
Keymap {
	"<leader>re",
	function() return require("refactoring").extract_var() end,
	mode = "x",
	expr = true,
	desc = "󰫧 Extract selection as variable",
}
Keymap {
	"<leader>rf",
	function() return require("refactoring").extract_func() end,
	mode = "x",
	expr = true,
	desc = " Extract function",
}
--------------------------------------------------------------------------------

require("refactoring").setup {
	show_success_message = true,
}
