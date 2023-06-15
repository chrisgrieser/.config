local u = require("config.utils")
--------------------------------------------------------------------------------

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
	{ -- better % (highlighting, matches across lines, match quotes)
		"andymass/vim-matchup",
		lazy = false, -- cannot be properly lazy-loaded
		dependencies = "nvim-treesitter/nvim-treesitter",
		init = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
			vim.g.matchup_text_obj_enabled = 0
		end,
	},
	{ -- CamelCase Motion plus
		"chrisgrieser/nvim-spider",
		dev = true,
		lazy = true, -- loaded by keymaps
		opts = { skipInsignificantPunctuation = true },
		init = function()
			-- stylua: ignore
			vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", { desc = "󱇫 e" })
			-- stylua: ignore
			vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", { desc = "󱇫 b" })
		end,
	},
	{ -- better marks
		"tomasky/bookmarks.nvim",
		event = "VimEnter", -- cannot be loaded on keymaps due to the bookmark signs
		opts = {
			sign_priority = 8, --set bookmark sign priority to cover other sign
			save_file = u.vimDataDir .. "/bookmarks",
			signs = {
				add = { text = "󰃀" },
			},
		},
	},
	-----------------------------------------------------------------------------
	{ -- tons of text objects
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "BufReadPre", -- to ensure it properly loads
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- tons of text objects
		"chrisgrieser/nvim-various-textobjs",
		lazy = true, -- loaded by keymaps
		dev = true,
	},
}
