return {
	"chrisgrieser/nvim-rip-substitute",
	keys = {
		{
			"<leader>rs",
			function() require("rip-substitute").sub() end,
			mode = { "n", "x" },
			desc = " rip-substitute",
		},
		{
			"<leader>rS",
			function() require("rip-substitute").rememberCursorWord() end,
			desc = " remember cword (rip-sub)",
		},
	},
	opts = {
		popupWin = {
			border = vim.g.borderStyle,
			hideSearchReplaceLabels = true,
		},
		keymaps = { insertModeConfirm = "<CR>" },
		editingBehavior = { autoCaptureGroups = true },
	},
}
