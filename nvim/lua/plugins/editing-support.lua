return {
	{ -- autopair 
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("nvim-autopairs").setup { check_ts = true } -- use treesitter
			local rule = require("nvim-autopairs.rule")
			local isNodeType = require("nvim-autopairs.ts-conds").is_ts_node

			require("nvim-autopairs").add_rules {
				rule("<", ">", "lua"):with_pair(isNodeType("string")), -- useful for keymaps
				rule('\\"', '\\"', "json"):with_pair(), -- escaped double quotes
				rule("*", "*", "markdown"):with_pair(), -- italics
				rule("__", "__", "markdown"):with_pair(), -- bold

				-- before: () =>|		after: () => { | }
				rule("%(.*%)%s*%=>$", " {  }", { "typescript", "javascript" })
					:use_regex(true)
					:set_end_pair_length(2),
				-- WARN adding a rule with <space> as *ending* trigger will disable space
				-- triggering `:abbrev` abbreviations
			}

			-- add brackets to cmp completions, e.g. "function" -> "function()"
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{ -- autopair, but for keywords
		"RRethy/nvim-treesitter-endwise",
		event = "BufEnter",
		dependencies = "nvim-treesitter/nvim-treesitter",
	},
	{ -- AI Support
		"aduros/ai.vim",
		cmd = "AI",
		init = function()
			-- INFO requires openai api key from .zshenv
			vim.g.ai_context_before = 10
			vim.g.ai_context_after = 10
			vim.g.ai_completions_model = "gpt-3.5-turbo" -- https://platform.openai.com/docs/models/gpt-3-5
			vim.g.ai_edits_model = "gpt-3.5-turbo"
			vim.g.ai_temperature = 0 -- -0 with 1 meaning high randomness
			vim.g.ai_indicator_text = "󱙺"
			vim.g.ai_no_mappings = 1 -- disable default mappings (which overwrite <C-a> in Normal mode…)
		end,
	},
	{ -- case conversion
		"johmsalas/text-case.nvim",
		lazy = true, -- loaded by keymaps
		commit = "2cbe6b6", -- https://github.com/johmsalas/text-case.nvim/issues/40
	},
	{ -- Jump out of scope in insert mode
		"abecodes/tabout.nvim",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = "InsertEnter",
		opts = {
			act_as_shift_tab = true,
			ignore_beginning = true,
			tabouts = {
				{ open = "'", close = "'" },
				{ open = '"', close = '"' },
				{ open = "`", close = "`" },
				{ open = "(", close = ")" },
				{ open = "[", close = "]" },
				{ open = "{", close = "}" },
				{ open = "*", close = "*" }, -- markdown italics (multi-char not supported by tabout)
				{ open = "<", close = ">" }, -- tags / keybindings in lua
			},
		},
	},
	{ -- swapping of sibling nodes (works with more nodes than Iswap, but has no hint mode)
		"Wansmer/sibling-swap.nvim",
		lazy = true, -- loaded by keymaps
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			use_default_keymaps = false,
			allowed_separators = { "..", "*" }, -- multiplication & lua string concatenation
			highlight_node_at_cursor = true,
			ignore_injected_langs = true,
			allow_interline_swaps = true,
			interline_swaps_witout_separator = false,
		},
	},
	{ -- split-join
		"Wansmer/treesj",
		dependencies = "nvim-treesitter/nvim-treesitter",
		cmd = "TSJToggle",
		opts = {
			use_default_keymaps = false,
			cursor_behavior = "start", -- start|end|hold
			max_join_length = 180,
		},
	},
	{ -- clipboard history / killring
		"gbprod/yanky.nvim",
		event = "BufReadPost",
		opts = {
			ring = {
				history_length = 10,
				cancel_event = "update", -- move|update
			},
			highlight = {
				on_yank = false, -- using for nicer highlights via vim.highlight.on_yank()
				on_put = true,
				timer = 400,
			},
		},
	},
	{ -- auto-bullets for markdown-like filetypes
		"dkarter/bullets.vim",
		ft = { "markdown", "text" },
		init = function() vim.g.bullets_delete_last_bullet_if_empty = 1 end,
	},
	{ -- :substitute, but with lua pattern / js regex
		"chrisgrieser/nvim-alt-substitute",
		dev = true,
		cmd = { "S", "AltSubstitute" },
		opts = true,
	},
	{ -- automatically set right indent for file
		"Darazaki/indent-o-matic",
		event = "BufReadPre",
	},
	{ -- key chord hints
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			plugins = {
				presets = { motions = false },
			},
			triggers_blacklist = {
				n = { "y" }, -- FIX "y" needed to fix weird delay occurring when yanking after a change
			},
			-- INFO ignore a mapping by giving it the label "which_key_ignore", not
			-- by using the "hidden" key here
			hidden = { "<Plug>", "^:lua " },
			window = {
				border = { "", BorderHorizontal, "", "" }, -- only horizontal border to save space
				padding = { 0, 0, 0, 0 },
				margin = { 0, 0, 0, 0 },
			},
			layout = { -- of the columns
				height = { min = 4, max = 15 },
				width = { min = 30, max = 33 },
				spacing = 2,
			},
		},
	},
}
