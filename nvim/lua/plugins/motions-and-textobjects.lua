return {
	{ -- highlights for ftFT
		"unblevable/quick-scope",
		keys = { "f", "F", "t", "T" },
		init = function() vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" } end,
	},
	{ -- display line numbers when using `:` to go to a line with
		"nacro90/numb.nvim",
		keys = ":",
		config = true,
	},
	{ -- CamelCase Motion plus
		"chrisgrieser/nvim-spider",
		dev = true,
	},

	-----------------------------------------------------------------------------

	{ -- tons of text objects
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "BufEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- tons of text objects
		"chrisgrieser/nvim-various-textobjs",
		lazy = true, -- loaded by keymaps
		dev = true,
	},
	{ -- remote textobj
		"mfussenegger/nvim-treehopper",
		dependencies = "nvim-treesitter/nvim-treesitter",
		lazy = true, -- loaded by keymaps
	},
}
