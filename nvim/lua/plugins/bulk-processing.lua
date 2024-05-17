return {
	{ -- global search & replace
		"MagicDuck/grug-far.nvim",
		external_dependencies = "rg",
		keys = {
			{ "<leader>fg", vim.cmd.GrugFar, desc = " Search & Replace Globally" },
		},
		opts = {
			keymaps = {
				replace = "<D-Enter>",
				qflist = "<D-s>",
				close = "q",
			},
		},
	},
	{ -- refactoring utilities
		"ThePrimeagen/refactoring.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		opts = { show_success_message = true },
		keys = {
			-- stylua: ignore start
			{"<leader>fi", function() require("refactoring").refactor("Inline Variable") end, mode = {"n", "x"}, desc = "󱗘 Inline Var" },
			{"<leader>fe", function() require("refactoring").refactor("Extract Variable") end, mode = "x", desc = "󱗘 Extract Var" },
			-- stylua: ignore end
		},
	},
}
