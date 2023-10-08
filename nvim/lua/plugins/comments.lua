return {
	{ -- comment
		"numToStr/Comment.nvim",
		keys = {
			{ "q", mode = { "n", "x" }, desc = " Comment Operator" },
			{ "Q", desc = " Append Comment at EoL" },
			{ "qo", desc = " Comment below" },
			{ "qO", desc = " Comment above" },
		},
		config = function()
			require("Comment").setup {
				opleader = { line = "q", block = "<Nop>" },
				toggler = { line = "qq", block = "<Nop>" },
				extra = { eol = "Q", above = "qO", below = "qo" },
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			}
		end,
	},
	{ -- codeblock-aware comment string
		"JoosepAlviste/nvim-ts-context-commentstring",
		main = "ts_context_commentstring",
		opts = { enable = true, enable_autocmd = false },
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
				"qF",
				function() require("neogen").generate { type = "file" } end,
				desc = " File Annotation",
			},
			{
				"qt",
				function() require("neogen").generate { type = "type" } end,
				desc = " Type Annotation",
			},
		},
	},
}
