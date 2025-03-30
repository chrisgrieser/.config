return {
	"chrisgrieser/nvim-origami",
	event = "VeryLazy",
	opts = {
		keepFoldsAcrossSessions = false, -- would require `nvim-ufo`
		foldtextWithLineCount = {
			enabled = true,
			template = "  󰘖 %s",
		},
	},
}
