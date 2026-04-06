vim.pack.add { "https://github.com/chrisgrieser/nvim-spider" }
--------------------------------------------------------------------------------

Keymap {
	"e",
	"<cmd>lua require('spider').motion('e')<CR>",
	mode = { "n", "x", "o" },
	desc = "󰯊 end of subword",
}
Keymap {
	"b",
	"<cmd>lua require('spider').motion('b')<CR>",
	mode = { "n", "x" }, -- not `o`, since we use a different textobject for that
	desc = "󰯊 beginning of subword",
}
