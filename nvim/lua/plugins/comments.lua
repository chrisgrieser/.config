local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- comment
		"numToStr/Comment.nvim",
		keys = {
			{ "q", mode = { "n", "x" }, desc = " Comment Operator" },
			{ "Q", desc = " Append Comment at EoL" },
			{ "qo", desc = " Comment below" },
			{ "qO", desc = " Comment above" },
		},
		opts = {
			opleader = { line = "q", block = "<Nop>" },
			toggler = { line = "qq", block = "<Nop>" },
			extra = { eol = "Q", above = "qO", below = "qo" },
		},
	},
	{ -- docstrings / annotation comments
		"danymat/neogen",
		opts = true,
		keys = {
			{
				"qf",
				function() require("neogen").generate { type = "func" } end,
				desc = " Function Annotation",
			},
			{
				"qt",
				function() require("neogen").generate { type = "type" } end,
				desc = " Type Annotation",
			},
		},
	},
}
