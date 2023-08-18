return {
	{ -- highlights for ftFT
		"jinh0/eyeliner.nvim",
		keys = { "f", "F", "t", "T" },
		opts = { highlight_on_key = true, dim = false },
		init = function()
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = function()
					vim.api.nvim_set_hl(0, "EyelinerPrimary", { reverse = true })
					vim.api.nvim_set_hl(0, "EyelinerSecondary", { underline = true })
				end,
			})
		end,
	},
	{ -- better % (highlighting, matches across lines, match quotes)
		"andymass/vim-matchup",
		event = "BufReadPre", -- cannot load on key due to highlights
		dependencies = "nvim-treesitter/nvim-treesitter",
		init = function()
			vim.g.matchup_matchparen_offscreen = {} -- empty = disables
			vim.g.matchup_text_obj_enabled = 0

			vim.keymap.set("n", "m", "<Plug>(matchup-%)", { desc = "Goto Matching Bracket" })
		end,
	},
	{ -- display line numbers when using `:` to go to a line with
		"nacro90/numb.nvim",
		keys = ":",
		opts = true,
	},
	{ -- CamelCase Motion plus
		"chrisgrieser/nvim-spider",
		dev = true,
		opts = { skipInsignificantPunctuation = true },
		keys = {
			-- stylua: ignore
			{"e", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" }, desc = "󱇫 Spider e" },
			-- stylua: ignore
			{"b", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" }, desc = "󱇫 Spider b" },
		},
	},
	-----------------------------------------------------------------------------
	{ -- tons of text objects
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "BufReadPre", -- not later to ensure it loads in time properly
		dependencies = "nvim-treesitter/nvim-treesitter",
		init = function()
			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
			local next_hunk_repeat, prev_hunk_repeat =
				ts_repeat_move.make_repeatable_move_pair(, gs.prev_hunk)

			vim.keymap.set({ "n", "x", "o" }, "]h", next_hunk_repeat)
			vim.keymap.set({ "n", "x", "o" }, "[h", prev_hunk_repeat)
		end,
	},
	{ -- tons of text objects
		"chrisgrieser/nvim-various-textobjs",
		lazy = true,
		dev = true,
	},
}
