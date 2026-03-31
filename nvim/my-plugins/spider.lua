vim.pack.add { "https://github.com/chrisgrieser/nvim-spider" }
--------------------------------------------------------------------------------

vim.keymap.set(
	{ "n", "x", "o" },
	"e",
	"<cmd>lua require('spider').motion('e')<CR>",
	{ desc = "󰯊 end of subword" }
)
vim.keymap.set(
	{ "n", "x", "o" },
	"b",
	"<cmd>lua require('spider').motion('b')<CR>",
	{ desc = "󰯊 beginning of subword" }
)
