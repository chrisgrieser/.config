return {
	{ -- better `:substitute`
		"chrisgrieser/nvim-rip-substitute",
		cmd = "RipSubstitute",
		keys = {
			{
				"<leader>rs",
				function() require("rip-substitute").sub() end,
				mode = { "n", "x" },
				desc = " substitute (rip-sub)",
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
			prefill = {
				startInReplaceLineIfPrefill = true,
				alsoPrefillReplaceLine = false,
			},
			keymaps = {
				insertModeConfirm = "<CR>",
			},
			editingBehavior = {
				autoCaptureGroups = true,
			},
		},
	},
	{ -- refactoring utilities
		"ThePrimeagen/refactoring.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		opts = { show_success_message = true },
		keys = {
			-- stylua: ignore start
			{ "<leader>ri", function() require("refactoring").refactor("Inline Variable") end, mode = { "n", "x" }, desc = "󱗘 Inline Var" },
			{ "<leader>re", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "󱗘 Extract Var" },
			{ "<leader>ru", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "󱗘 Extract Func" },
			{ "<leader>rU", function() require("refactoring").refactor("Extract Function To File") end, mode = "x", desc = "󱗘 Extract Func to File" },
			-- stylua: ignore end
		},
	},
}
