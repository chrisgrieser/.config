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
		debug = vim.uv.fs_stat(vim.g.localRepos .. "/nvim-rip-substitute"),
	},
}
