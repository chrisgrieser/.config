vim.pack.add { "https://github.com/chrisgrieser/nvim-rip-substitute" }
--------------------------------------------------------------------------------

require("config.utils").pluginKeymaps {
	{
		"<leader>rs",
		function() require("rip-substitute").sub() end,
		mode = { "n", "x" },
		desc = " rip-substitute",
	},
}

--------------------------------------------------------------------------------

require("rip-substitute").setup {
	popupWin = {
		hideSearchReplaceLabels = true,
		hideKeymapHints = true,
	},
	keymaps = {
		insertModeConfirmAndSubstituteInBuffer = "<CR>",
	},
	editingBehavior = {
		autoCaptureGroups = true,
	},
	debug = false,
}

--------------------------------------------------------------------------------
