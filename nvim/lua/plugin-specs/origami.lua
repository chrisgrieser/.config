return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	init = function ()
		vim.opt.foldlevel = 99 -- do not auto-fold
		vim.opt.foldlevelstart = 99
	end,
	keys = {
		{
			"<leader>if",
			function() require("origami").inspectLspFolds("special") end,
			desc = " LSP special folds",
		},
	},
	opts = {
		autoFold = {
			enabled = true,
			kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
		},
	},
}
