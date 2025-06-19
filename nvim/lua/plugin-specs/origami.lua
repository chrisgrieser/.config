return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	init = function()
		vim.opt.foldlevel = 99 -- disable vim's auto-fold
		vim.opt.foldlevelstart = 99
	end,
	opts = {
		foldtext = {
			lineCount = { template = "  󰘖 %d" },
		},
		autoFold = {
			kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
		},
	},
	keys = {
		-- stylua: ignore
		{ "<leader>if", function() require("origami").inspectLspFolds("special") end, desc = " LSP special folds" },
	},
}
