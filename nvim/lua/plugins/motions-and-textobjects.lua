local u = require("config.utils")
local spooky = "x" -- key triggering remote textobj
--------------------------------------------------------------------------------

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
			vim.g.matchup_matchparen_offscreen = {} -- empty = disables
			vim.g.matchup_text_obj_enabled = 0
		end,
	},
	{ -- CamelCase Motion plus
		"chrisgrieser/nvim-spider",
		dev = true,
		opts = { skipInsignificantPunctuation = true },
		keys = {
			-- stylua: ignore
			{"e", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" }, desc = "󱇫 Spider-e" },
			-- stylua: ignore
			{"b", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" }, desc = "󱇫 Spider-b" },
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
	{ -- distant textobjects
		"ggandor/leap-spooky.nvim",
		keys = { { spooky, mode = { "o" }, desc = "󱡔 Load Leap Spooky" } },
		dependencies = { "ggandor/leap.nvim" },
		init = function()
			local textobjRemaps = vim.deepcopy(u.textobjectRemaps)
			for remap, original in pairs(textobjRemaps) do
				vim.keymap.set(
					"o",
					spooky .. "a" .. remap,
					spooky .. "a" .. original,
					{ desc = "󱡔 Distant outer " .. original, remap = true }
				)
				vim.keymap.set(
					"o",
					spooky .. "i" .. remap,
					spooky .. "i" .. original,
					{ desc = "󱡔 Distant inner " .. original, remap = true }
				)
			end
		end,
		opts = {
			affixes = {
				magnetic = { window = nil, cross_window = nil }, -- magnetic = move to object after operation
				remote = { window = spooky, cross_window = nil },
			},
			prefix = true, -- false: `ixw`, true: `xiw`
			paste_on_remote_yank = true,
		},
	},
}
