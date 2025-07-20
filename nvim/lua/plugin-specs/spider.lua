return {
	"chrisgrieser/nvim-spider",
	keys = {
		{
			"e",
			"<cmd>lua require('spider').motion('e')<CR>",
			mode = { "n", "x", "o" },
			desc = "󰯊 end of subword",
		},
		{
			"b",
			"<cmd>lua require('spider').motion('b')<CR>",
			mode = { "n", "x" }, -- not `o`, since mapped as textobj
			desc = "󰯊 beginning of subword",
		},
		-- bla$ bla $ff$
		-- function $a = b$ formula
		{
			"E",
			function()
				require("spider").motion(
					"w",
					{ customPatterns = { patterns = { "%$" }, overrideDefault = false } }
				)
			end,
		},
	},
}
