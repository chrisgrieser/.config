vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/ThePrimeagen/refactoring.nvim",
}, { load = function() end }) -- lazy-loading via `:packadd` later
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

vim.defer_fn(function()
	vim.cmd.packadd("plenary.nvim")
	vim.cmd.packadd("refactoring.nvim")
	require("refactoring").setup { show_success_message = true }
end, 500)
