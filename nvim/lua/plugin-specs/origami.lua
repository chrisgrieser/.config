return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	keys = {
		{
			"<leader>if",
			function() require("origami").inspectLspFolds("special") end,
			desc = " LSP special folds",
		},
	},
	opts = {
		foldtextWithLineCount = {
			enabled = true,
			template = "  󰘖 %s",
		},
		autoFold = {
			enabled = true,
			kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
		},
	},
}
