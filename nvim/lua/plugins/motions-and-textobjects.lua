return {
	{ -- highlights for ftFT
		"unblevable/quick-scope",
		keys = { "f", "F", "t", "T" },
		init = function() vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" } end,
	},
	{ -- CamelCase Motion plus
		"chrisgrieser/nvim-spider",
		lazy = true, -- loaded by keybinds
		dev = true,
	},

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
}
