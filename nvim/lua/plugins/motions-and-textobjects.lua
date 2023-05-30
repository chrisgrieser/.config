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
	{ -- better % (highlighting & matches across lines)
		"andymass/vim-matchup",
		lazy = false, -- cannot be properly lazy-loaded
		dependencies = "nvim-treesitter/nvim-treesitter",
		init = function ()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
			vim.g.matchup_text_obj_enabled = 0
		end,
	},
	{ -- CamelCase Motion plus
		"chrisgrieser/nvim-spider",
		dev = true,
		lazy = true, -- loaded by keymaps
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
