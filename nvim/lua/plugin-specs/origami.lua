return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	init = function()
		vim.opt.foldlevel = 99 -- disable vim's auto-fold
		vim.opt.foldlevelstart = 99
	end,
	keys = {
		{ "h", function() require("origami").h() end, mode = { "n", "x" }, desc = "Origami h" },
		{ "H", function() require("origami").caret() end, mode = { "n", "x" }, desc = "Origami H" },
		{ "l", function() require("origami").l() end, mode = { "n", "x" }, desc = "Origami l" },
		{ "L", function() require("origami").dollar() end, mode = { "n", "x" }, desc = "Origami L" },
	},
	opts = {
		foldKeymaps = { setup = false }, -- setting on my own since I remap `H` and `L`
		foldtext = {
			padding = 2,
			lineCount = { template = "󰘖 %d" },
		},
	},
}
