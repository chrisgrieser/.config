return {
	{ -- automatically set right indent for file
		"Darazaki/indent-o-matic",
		event = "BufReadPre",
	},
	{ -- autopair brackets, quotes, and markup
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
	{ -- swapping of sibling nodes (works with more nodes than Iswap, but has no hint mode)
		"Wansmer/sibling-swap.nvim",
		lazy = true, -- loaded by keymaps
		dependencies = "nvim-treesitter/nvim-treesitter",
		opts = {
			use_default_keymaps = false,
			allowed_separators = {
				"..", -- lua string concatenation
				"*", -- multiplication
			},
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
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			plugins = {
				presets = { motions = false },
			},
			triggers_blacklist = {
				n = { "y" }, -- FIX "y" needed to fix weird delay occurring when yanking after a change
			},
			hidden = { "<Plug>" },
			window = {
				border = { "", "─", "", "" }, -- no border to the side to save space
				padding = { 0, 0, 0, 0 },
				margin = { 0, 0, 0, 0 },
			},
			layout = { -- of the columns
				height = { min = 4, max = 15 },
				width = { min = 30, max = 33 },
				spacing = 1,
			},
		},
	},
}
