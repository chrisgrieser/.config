return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {
		foldtextWithLineCount = {
			enabled = false,
			template = "  󰘖 %s",
		},
		autoFold = {
			enabled = true,
			kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
		},
	},
}
