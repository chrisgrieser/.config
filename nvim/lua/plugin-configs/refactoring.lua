return {
	{ -- better `:substitute`
		"chrisgrieser/nvim-rip-substitute",
		keys = {
			{
				"<leader>fs",
				function() require("rip-substitute").sub() end,
				mode = { "n", "x" },
				desc = " rip-substitute",
			},
			{
				"<leader>fS",
				function() require("rip-substitute").rememberCursorWord() end,
				desc = " remember cword (rip-sub.)",
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
	},
	{ -- refactoring utilities
		"ThePrimeagen/refactoring.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		opts = { show_success_message = true },
		keys = {
			-- stylua: ignore start
			{ "<leader>fi", function() require("refactoring").refactor("Inline Variable") end, mode = { "n", "x" }, desc = "󱗘 Inline variable" },
			{ "<leader>fe", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "󱗘 Extract variable" },
			{ "<leader>fu", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "󱗘 Extract function" },
			-- stylua: ignore end
		},
	},
}
