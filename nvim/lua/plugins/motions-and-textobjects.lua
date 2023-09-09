local u = require("config.utils")

--------------------------------------------------------------------------------

return {
	{ -- highlights for ftFT
		"jinh0/eyeliner.nvim",
		keys = { "f", "F", "t", "T" },
		opts = { highlight_on_key = true, dim = false },
		init = function()
			u.colorschemeMod("EyelinerPrimary", { reverse = true })
			u.colorschemeMod("EyelinerSecondary", { underline = true })
		end,
	},
	{ -- better % (highlighting, matches across lines, match quotes)
		"andymass/vim-matchup",
		event = "UIEnter", -- cannot load on key due to highlights
		keys = {
			{ "m", "<Plug>(matchup-%)", desc = "Goto Matching Bracket" },
		},
		dependencies = "nvim-treesitter/nvim-treesitter",
		init = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" } -- empty list to disable
			vim.g.matchup_text_obj_enabled = 0
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
			-- stylua: ignore,
			{ "e", function() require("spider").motion("e") end, mode = { "n", "o", "x" }, desc = "󱇫 Spider e" },
			-- stylua: ignore,
			{ "b", function() require("spider").motion("b") end, mode = { "n", "o", "x" }, desc = "󱇫 Spider b" },
		},
	},
	-----------------------------------------------------------------------------
	{ -- tons of text objects
		"nvim-treesitter/nvim-treesitter-textobjects",
		event = "BufReadPre", -- not later to ensure it loads in time properly
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- tons of text objects
		"chrisgrieser/nvim-various-textobjs",
		lazy = true,
		dev = true,
	},
}
