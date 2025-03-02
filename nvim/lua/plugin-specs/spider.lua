return {
	"chrisgrieser/nvim-spider",
	keys = {
		{
			"e",
			"<cmd>lua require('spider').motion('e')<CR>",
			mode = { "n", "x", "o" },
			desc = "󱇫 end of subword",
		},
		{
			"b",
			"<cmd>lua require('spider').motion('b')<CR>",
			mode = { "n", "x" }, -- not `o`, since mapped as textobj
			desc = "󱇫 beginning of subword",
		},
		{ "1", "<cmd>lua require('spider').motion('w')<CR>" },
	},
}
