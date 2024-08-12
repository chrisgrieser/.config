local qfHeight = 15

--------------------------------------------------------------------------------

return {
	{ -- editable quickfix
		"stevearc/quicker.nvim",
		keys = {
			{
				"<leader>q",
				function() require("quicker").toggle { focus = true, min_height = qfHeight } end,
				desc = " Toggle quickfix",
			},
		},
		opts = {
			keys = {
				{
					"<Tab>",
					function()
						require("quicker").expand()
						vim.api.nvim_win_set_height(0, math.floor(qfHeight * 2))
					end,
					desc = " Expand context",
				},
				{
					"<S-Tab>",
					function()
						require("quicker").collapse()
						vim.api.nvim_win_set_height(0, qfHeight)
					end,
					desc = " Collapse",
				},
				{ "<D-s>", "<cmd>update|close<CR>", desc = " Confirm changes" },
			},
			edit = { autosave = true },
			max_filename_width = function() return 23 end,
		},
	},
	{ -- better `:substitute`
		"chrisgrieser/nvim-rip-substitute",
		cmd = "RipSubstitute",
		keys = {
			{
				"<leader>fs",
				function() require("rip-substitute").sub() end,
				mode = { "n", "x" },
				desc = " substitute",
			},
			{
				"<leader>fc",
				function() require("rip-substitute").rememberCursorWord() end,
				desc = " remember cword",
			},
		},
		opts = {
			popupWin = {
				border = vim.g.borderStyle,
				hideSearchReplaceLabels = true,
			},
			prefill = {
				startInReplaceLineIfPrefill = true,
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
			{ "<leader>fi", function() require("refactoring").refactor("Inline Variable") end, mode = { "n", "x" }, desc = "󱗘 Inline Var" },
			{ "<leader>fe", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "󱗘 Extract Var" },
			{ "<leader>fu", function() require("refactoring").refactor("Extract Function") end, mode = "x", desc = "󱗘 Extract Func" },
			{ "<leader>fU", function() require("refactoring").refactor("Extract Function To File") end, mode = "x", desc = "󱗘 Extract Func to File" },
			-- stylua: ignore end
		},
	},
}
