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
	},
	{ -- refactoring utilities
		"ThePrimeagen/refactoring.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		opts = { show_success_message = true },
		keys = {
			{
				"<leader>fi",
				function() require("refactoring").refactor("Inline Variable") end,
				mode = { "n", "x" },
				desc = "󰫧 Inline variable",
			},
			{
				"<leader>fe",
				function()
					vim.cmd.normal { "viW", bang = true }
					require("refactoring").refactor("Extract Variable")
				end,
				desc = "󰫧 Extract cursorWORD as variable",
			},
			{
				"<leader>fe",
				function() require("refactoring").refactor("Extract Variable") end,
				mode = "x",
				desc = "󰫧 Extract selection as variable",
			},
			{
				"<leader>fu",
				function() require("refactoring").refactor("Extract Function") end,
				mode = "x",
				desc = " Extract function",
			},
		},
	},
}
