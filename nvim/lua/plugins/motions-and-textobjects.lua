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
		lazy = true,
		init = function()
			-- stylua: ignore start
			vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "󱇫 e" })
			vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "󱇫 b" })
			-- stylua: ignore end
		end,
		opts = {
			skipInsignificantPunctuation = true,
		},
	},

{
	"chrisgrieser/nvim-spider",
	dev = true,
	init = function()
		vim.keymap.set(
			{ "n", "o", "x" },
			"w",
			"<cmd>lua require('spider').motion('w')<CR>",
			{ desc = "Spider-w" }
		)
		vim.keymap.set(
			{ "n", "o", "x" },
			"e",
			"<cmd>lua require('spider').motion('e')<CR>",
			{ desc = "Spider-e" }
		)
		vim.keymap.set(
			{ "n", "o", "x" },
			"b",
			"<cmd>lua require('spider').motion('b')<CR>",
			{ desc = "Spider-b" }
		)
		vim.keymap.set(
			{ "n", "o", "x" },
			"ge",
			"<cmd>lua require('spider').motion('ge')<CR>",
			{ desc = "Spider-ge" }
		)
	end,
	opts = {
		skipInsignificantPunctuation = true,
	},
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
