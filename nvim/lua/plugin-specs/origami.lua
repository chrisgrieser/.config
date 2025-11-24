return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	init = function()
		vim.opt.foldlevel = 99 -- disable vim's auto-fold
		vim.opt.foldlevelstart = 99
	end,
	opts = {
		foldtext = {
			padding = 2,
			lineCount = { template = "󰘖 %d" },
		},
	},
}
