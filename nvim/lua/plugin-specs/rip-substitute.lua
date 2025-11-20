return {
	"chrisgrieser/nvim-rip-substitute",
	keys = {
		{
			"<leader>rs",
			function() require("rip-substitute").sub() end,
			mode = { "n", "x" },
			desc = " rip-substitute",
		},
	},
	opts = {
		popupWin = {
			hideSearchReplaceLabels = true,
			hideKeymapHints = true,
		},
		keymaps = {
			insertModeConfirm = "<CR>",
		},
		editingBehavior = {
			autoCaptureGroups = true,
		},
		debug = false,
	},
}
