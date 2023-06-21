local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- highlights for ftFT
		"jinh0/eyeliner.nvim",
		enabled = false,
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
	{ -- better search
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			search = {
				forward = true,
				wrap = true, -- when `false`, find only matches in the given direction
				-- Each mode will take ignorecase and smartcase into account.
				-- * exact: exact match
				-- * search: regular search
				-- * fuzzy: fuzzy search
				-- * fun(str): custom function that returns a pattern
				--   For example, to only match at the beginning of a word:
				--   mode = function(str)
				--     return "\\<" .. str
				--   end,
				mode = "fuzzy",
				incremental = false, -- behave like `incsearch`
			},
			jump = {
				history = false, -- add pattern to search history
				register = false, -- add pattern to search register
				nohlsearch = false, -- clear highlight after jump
			},
			highlight = {
				label = {
					-- add a label for the first match in the current window.
					-- you can always jump to the first match with `<CR>`
					current = false,
					-- show the label after the match
					after = true, ---@type boolean|number[]
					-- show the label before the match
					before = false, ---@type boolean|number[]
					-- position of the label extmark
					style = "overlay", ---@type "eol" | "overlay" | "right_align" | "inline"
				},
				backdrop = true, -- show a backdrop with hl FlashBackdrop
				matches = true, -- Highlight the search matches
				priority = 5000, -- extmark priority
				groups = {
					match = "FlashMatch",
					current = "FlashCurrent",
					backdrop = "FlashBackdrop",
					label = "FlashLabel",
				},
			},
			modes = {
				-- a regular search with `/` or `?`
				search = {
					enabled = true, -- enable flash for search
					highlight = { backdrop = false },
					jump = { history = true, register = true, nohlsearch = true },
				},
				char = { enabled = false }, -- don't modify FfTt motions
				-- options used for treesitter selections
				treesitter = {
					highlight = {
						label = { before = true, after = true, style = "inline" },
						backdrop = false,
						matches = false,
					},
				},
			},
		},
		keys = {
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end },
		},
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
