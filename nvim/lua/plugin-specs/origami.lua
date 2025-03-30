return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {
		foldtextWithLineCount = {
			template = "  󰘖 %s",
		},
		autoFold = {
			enabled = true,
			kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
		},
	},
}
