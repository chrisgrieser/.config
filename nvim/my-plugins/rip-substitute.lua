vim.pack.add { "https://github.com/chrisgrieser/nvim-rip-substitute" }
--------------------------------------------------------------------------------

vim.keymap.set(
	{ "n", "x" },
	"<leader>rs",
	function() require("rip-substitute").sub() end,
	{ desc = " rip-substitute" }
)

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
